// Copyright © ICS 2024 from aiPhad.com

import Foundation

typealias UnwrappedRawEntriesAndParsedEntry = (rawEntries: [NSDictionary], parsedEntry: (any SettingEntry)?)

public protocol SettingsBundleReading {
    var entries: [any SettingEntry] { get }
    var findable: [any SettingSearchable] { get }
    func resetDefaults() async
}

public struct SettingsBundleReaderRefactor: SettingsBundleReading {
    // MARK: Public

    public var entries: [any SettingEntry] = []
    public var findable: [any SettingSearchable] = []
    
    // MARK: Internal

    var repository: RepositoryStorable
    static var shared: SettingsBundleReading?
    
    // MARK: Private

    private var rootFileName: String
    private var bundleFileName: String
    
    /// Setup is responsible for launch the unwrap of all objects and the corresponding relationships
    /// - Parameters:
    ///   - userDefaults: by default "UserDefaults.standard" also possible to inject some object compliant with RepositoryStorable
    ///   - rootFileName: name of the "root" plist file on the bundle. Default is "Root"
    ///   - bundleFileName: "Settings.bundle" name of the main *.*bundle folder. Default Settings.bundle
    public static func setup(repository: RepositoryStorable = UserDefaults.standard,
                             rootFileName: String = "Root",
                             bundleFileName: String = "Settings") {
        guard SettingsBundleReader.shared == nil else { return }
        SettingsBundleReaderRefactor(repository: repository,
                             rootFileName: rootFileName,
                             bundleFileName: bundleFileName)
    }
    
    @discardableResult
    init?(repository: RepositoryStorable,
          rootFileName: String,
          bundleFileName: String) {
        self.repository = repository
        self.rootFileName = rootFileName
        self.bundleFileName = bundleFileName
        entries = unwrapSpecifiers(fileName: rootFileName, parent: nil)
        findable = parseSearchableEntries(settings: entries)
        SettingsBundleReader.shared = self
    }
    
    public func resetDefaults() async {
        Task {
            findable.forEach {
                $0.resetSpecifier()
            }
        }
    }
}

// MARK: Unwrapping creating relationships between objects

extension SettingsBundleReaderRefactor {
    /// Intent to put in just 1 place the parsing of the objects able to be searched
    /// - Parameter settings: entries to be parsed
    /// - Returns: the list os entries from "settings" that are compliant with SettingSearchable
    private func parseSearchableEntries(settings: [any SettingEntry]) -> [any SettingSearchable] {
        var resultsSearchable = [any SettingSearchable]()
        
        settings.forEach { entry in
            switch entry {
            case let childSpecifier as Specifier.ChildPane:
                let searchable = parseSearchableEntries(settings: childSpecifier.characteristic.entries)
                resultsSearchable.append(contentsOf: searchable)
            case let groupSpecifier as Specifier.Group:
                let searchable = parseSearchableEntries(settings: groupSpecifier.characteristic.entries)
                resultsSearchable.append(contentsOf: searchable)
            default:
                if let cast = entry as? (any SettingSearchable) {
                    resultsSearchable.append(cast)
                }
            }
        }
        
        return resultsSearchable
    }
    
    /// Transform a simple plist file to a final list of "SettingEntry" objects
    /// - Parameter fileName: name of the file to be unwrapped without extension (plist is the only value valid)
    /// - Returns: The list on entries possible to be parse from the file provided
    private func unwrapSpecifiers(fileName: String, parent: String?) -> [any SettingEntry] {
        guard let settingsURL = Bundle.main.url(
            forResource: fileName,
            withExtension: Constants.plistFile,
            subdirectory: Constants.bundleFile(bundleFileName)
        ),
            let settings = NSDictionary(contentsOf: settingsURL),
            let preferences = settings[Constants.preferences] as? [NSDictionary] else {
            return []
        }
        
        return unwrap(entries: preferences, parent: parent)
    }
    
    /// Holds reference for initial entries array, and it will iteratively be responsible to filter tge final array of results, defining always what entry should be parsed next, by function settingsEntryDataDecodeFirst...
    /// - Parameters:
    ///   - entries: all entries available for being parsed
    ///   - parent: entity of setting that holds the path for this list of entries
    /// - Returns: a list of Settings entries view models ready to be rendered by UI
    private func unwrap(entries: [NSDictionary], parent: String?) -> [any SettingEntry] {
        var entries = entries
        var results = [any SettingEntry]()
        
        while !entries.isEmpty {
            let result = settingsEntryDataDecodeFirst(in: entries, parent: parent)
            entries = result.rawEntries
            if let parsedEntry = result.parsedEntry {
                results.append(parsedEntry)
            }
        }
        
        return results
    }
    
    /// Works as a complement to the previous function "unwrap(entries...", the first holds the total amount of results while this function intents to unwrap the each Setting Entry and return it together with the amount of entries not yet unwrapped.
    /// - Parameters:
    ///   - entries: all existing entries to be unwrapped
    ///   - parent: previous object that hold the the reference to this list of entries
    /// - Returns: a tuple with the total amount of entries not yet unwrapped (raw value) together with the entries ready to be rendered by UI
    private func settingsEntryDataDecodeFirst(in entries: [NSDictionary], parent: String?) -> UnwrappedRawEntriesAndParsedEntry {
        var entries = entries
        
        guard let dictionary = entries.first else {
            return (entries, nil)
        }
        
        do {
            let dataEntry = try JSONSerialization.data(withJSONObject: dictionary)
            
            guard let type = dictionary[Constants.keyType] as? String,
                  let specifierType = Specifier.Kind(rawValue: type) else {
                print("unable to decode type: \(dictionary[Constants.keyType] ?? "no type")")
                return (entries, nil)
            }
            
            entries.removeFirst()
            
            let decoder = JSONDecoder()
            decoder.userInfo[Specifier.repository] = repository
            let toReturn: (any PathIdentifier)?
            
            switch specifierType {
            case .childPane:
                let childPane = try decoder.decode(Specifier.ChildPane.self, from: dataEntry)
                childPane.appendPath(parent)
                let innerEntries = unwrapSpecifiers(fileName: childPane.characteristic.fileName,
                                                    parent: childPane.specifierPath)
                childPane.characteristic.entries = innerEntries
                toReturn = childPane
            case .group:
                // Type group will be shown as if they were a section.
                // Strategy: entries after open a Group will be considered
                // as inner entries till a new Group is found or
                // reaches the end of the list and in this case is "closed"
                let group = try decoder.decode(Specifier.Group.self, from: dataEntry)
                group.appendPath(parent)
                var groupEntries = entries.filterGroupEntries()
                entries.removeFirst(groupEntries.count)
                
                var innerEntries = [any SettingEntry]()
                
                while !groupEntries.isEmpty {
                    let result = settingsEntryDataDecodeFirst(in: groupEntries,
                                                              parent: group.specifierPath)
                    groupEntries = result.rawEntries
                    if let parsedEntry = result.parsedEntry {
                        innerEntries.append(parsedEntry)
                    }
                }
                
                group.characteristic.entries = innerEntries
                toReturn = group
            case .multiValue:
                toReturn = try decoder.decode(Specifier.MultiValue.self, from: dataEntry)
                toReturn?.appendPath(parent)
            case .textField:
                toReturn = try decoder.decode(Specifier.TextField.self, from: dataEntry)
                toReturn?.appendPath(parent)
            case .toggleSwitch:
                toReturn = try decoder.decode(Specifier.ToggleSwitch.self, from: dataEntry)
                toReturn?.appendPath(parent)
            case .radio:
                toReturn = try decoder.decode(Specifier.Radio.self, from: dataEntry)
                toReturn?.appendPath(parent)
            case .slider:
                toReturn = try decoder.decode(Specifier.Slider.self, from: dataEntry)
                toReturn?.appendPath(parent)
            case .titleValue:
                toReturn = nil
            }
            
            return (entries, toReturn)
        } catch {
            print("Failed to decode JSON \(error)")
            print("Unable to decode \nentry: \(dictionary)\n one or more required fields missing or not compliant")
            assertionFailure("Search for: \"Settings Application Schema Reference\", or if everything is as expected please open a bug on MyRWSettings")
            return (entries, nil)
        }
    }
}

extension SettingsBundleReaderRefactor {
    // MARK: Constants

    private enum Constants {
        static let keyType = "Type"
        static let preferences = "PreferenceSpecifiers"
        static let plistFile = "plist"
        static func bundleFile(_ fileName: String) -> String {
            "\(fileName).bundle"
        }
    }
}
