// Copyright © ICS 2024 from aiPhad.com

import Foundation

public protocol SettingsBundleReading {
    var entries: [any SettingEntry] { get }
    var findable: [any SettingSearchable] { get }
    func resetDefaults() async
}

public struct SettingsBundleReader: SettingsBundleReading {
    
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
        guard Self.shared == nil else { return }
        SettingsBundleReader(repository: repository,
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
        
        if let settingsAvailable = unwrapSpecifiers(fileName: rootFileName,
                                                    parent: nil) {
            entries = settingsAvailable
            findable = parseSearchables(settings: settingsAvailable)
            Self.shared = self
        } else {
            preconditionFailure("unable to unwrap results from file \(rootFileName). Please review any error on file.\nConsole output may contain useful information about the problem on file.")
            return nil
        }
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
extension SettingsBundleReader {
    
    /// Intent to put in just 1 place the parsing of the objects able to be searched
    /// - Parameter settings: entries to be parsed
    /// - Returns: the list os entries from "settings" that are compliant with SettingSearchable
    private func parseSearchables(settings: [any SettingEntry]) -> [any SettingSearchable] {
        var resultsSearchable = [any SettingSearchable]()
        
        settings.forEach { entry in
            switch entry {
            case let childSpecifier as Specifier.ChildPane:
                let searchable = parseSearchables(settings: childSpecifier.characteristic.entries)
                resultsSearchable.append(contentsOf: searchable)
            case let groupSpecifier as Specifier.Group:
                let searchable = parseSearchables(settings: groupSpecifier.characteristic.entries)
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
    private func unwrapSpecifiers(fileName: String, parent: String?) -> [any SettingEntry]? {
        guard let settingsURL = Bundle.main.url(
            forResource: fileName,
            withExtension: Constants.plistFile,
            subdirectory: Constants.bundleFile(bundleFileName)
        ),
              let settings = NSDictionary(contentsOf: settingsURL),
              let preferences = settings[Constants.preferences] as? [NSDictionary] else {
            return nil
        }
        
        return unwrapEntries(preferences, parent: parent)
    }
    
    /// Intent to be used as a the second part of the previous function, but in fact is used recursively
    /// not only by the itself, but also by other functions
    /// - Parameter entries: list of NSDictionaries, used to build the output
    /// - Returns: List of Settings entries with inner entries already built
    private func unwrapEntries(_ entries: [NSDictionary], parent: String?) -> [any SettingEntry] {
        var entries = entries
        var results = [any SettingEntry]()
        
        while !entries.isEmpty {
            if let entry = entries.first {
                if let entryToReturn = unwrapEntry(dictionary: entry, parent: parent) {
                    entries.removeFirst()
                    if entryToReturn.type == .group,
                       let entryToReturn = entryToReturn as? Specifier.Group {
                        // Type group will be shown as if they were a section.
                        // Strategy entries after open aGroup will be considered
                        // as inner entries till a new Group is found or
                        // reaches the end of the list and in this case is "closed"
                        var innerEntries = [any SettingEntry]()
                        
                        while !entries.isEmpty {
                            if let dict = entries.first, 
                                let sectionEntry = unwrapEntry(dictionary: dict,
                                                               parent: entryToReturn.specifierPath) {
                                
                                if sectionEntry.type != .group {
                                    innerEntries.append(sectionEntry)
                                    entries.removeFirst()
                                } else {
                                    break
                                }
                            } else {
                                entries.removeFirst()
                            }
                        }
                        entryToReturn.characteristic.entries = innerEntries
                        results.append(entryToReturn)
                    } else {
                        results.append(entryToReturn)
                    }
                } else {
                    entries.removeFirst()
                }
            }
        }
        
        return results
    }
    
    /// SettingEntry builder. Function used recursively
    /// - Parameter dictionary: dictionary supposedly representable of a settings specifier entry
    /// - Returns: returns a Setting Specifier model (ready to be used by a Specifier UI component)
    private func unwrapEntry(dictionary: NSDictionary, parent: String?) -> (any SettingEntry)? {
        do {
            let dataEntry = try JSONSerialization.data(withJSONObject: dictionary)
            
            guard let type = dictionary["Type"] as? String,
                  let specifierType = Specifier.Kind(rawValue: type) else {
                print("unable to decode type: \(dictionary["Type"] ?? "no type")")
                return nil
            }
        
            return try settingsEntryDataDecode(dataEntry, type: specifierType, parent: parent)
        } catch {
            print("Failed to decode JSON \(error)")
            print("Unable to decode \nentry: \(dictionary)\n one or more required fields missing or not compliant")
            assertionFailure("Search for: \"Settings Application Schema Reference\", or if everything is as expected please open a bug on MyRWSettings")
            return nil
        }
    }
    
    /// Function not only responsible for providing a SettingEntry from the Type parameter, but it is also used recursively to unwrap the inner objects present under "group"(s) or "childPane"(s)
    /// - Parameters:
    ///   - dataEntry: Data object used by JSONDecoder to unwrap the Specifier
    ///   - type: describe a type of specifier
    /// - Returns: returns a setting specifier model from a JSON decoded data object
    private func settingsEntryDataDecode(_ dataEntry: Data, type: Specifier.Kind, parent: String?) throws -> (any SettingEntry)? {
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = repository
        let toReturn: (any PathIdentifier)?
        
        switch type {
        case .childPane:
            let childPane = try decoder.decode(Specifier.ChildPane.self, from: dataEntry)
            childPane.appendPath(parent)
            let innerEntries = unwrapSpecifiers(fileName: childPane.characteristic.fileName,
                                                parent: childPane.specifierPath)
            childPane.characteristic.entries = innerEntries ?? []
            toReturn = childPane
        case .group:
            toReturn = try decoder.decode(Specifier.Group.self, from: dataEntry)
        case .multiValue:
            toReturn = try decoder.decode(Specifier.MultiValue.self, from: dataEntry)
        case .textField:
            toReturn = try decoder.decode(Specifier.TextField.self, from: dataEntry)
        case .toggleSwitch:
            toReturn = try decoder.decode(Specifier.ToggleSwitch.self, from: dataEntry)
        case .radio:
            toReturn = try decoder.decode(Specifier.Radio.self, from: dataEntry)
        case .slider:
            toReturn = try decoder.decode(Specifier.Slider.self, from: dataEntry)
        case .titleValue:
            toReturn = nil
        }
        
        if toReturn?.type != .childPane {
            toReturn?.appendPath(parent)
        }
        
        return toReturn
    }
}

extension SettingsBundleReader {
    
    // MARK: Constants
    private enum Constants {
        static let preferences = "PreferenceSpecifiers"
        static let plistFile = "plist"
        static func bundleFile(_ fileName: String) -> String {
            "\(fileName).bundle"
        }
    }
}
