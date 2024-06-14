// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    public class Radio: SettingSearchable {
        @Published public internal(set) var characteristic: Characteristic
        public var id: UUID = .init()
        public let type: Kind = .radio
        public let title: String
        public let footerText: String?
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        public var specifierKey: String {
            characteristic.key
        }
        
        private(set) var shouldReset: Bool = true
        
        internal init(id: UUID = .init(), title: String, footerText: String? = nil, characteristic: Characteristic) {
            self.id = id
            self.title = title
            self.footerText = footerText
            self.characteristic = characteristic
            self.accessibilityIdentifier = "\(characteristic.key)_option"
        }
        
        // MARK: Decodable
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? .empty
            footerText = try container.decodeIfPresent(String.self, forKey: .footer)
            
            let specifierKey = try container.decode(String.self, forKey: .specifierKey)
            let titles = try container.decode([String].self, forKey: .titles)
            let defaultValue = container.decodeAnyIfPresent(forKey: .defaultValue) ?? .empty
            let values = container.decodeAnyListIfPresent(forKey: .values)
            
            accessibilityIdentifier = "\(specifierKey)_option"
            shouldReset = try container.decodeIfPresent(Bool.self, forKey: .restartable) ?? true
            
            if let container = decoder.userInfo[Specifier.repository] as? RepositoryStorable {
                characteristic = .init(key: specifierKey,
                                       defaultValue: defaultValue,
                                       titles: titles,
                                       values: values ?? [],
                                       container: container)
            } else {
                throw DecodingError.unableToFindRepository
            }
        }
        
        public func resetSpecifier() {
            guard shouldReset else { return }
            characteristic.storedContent = characteristic.defaultValue
        }
        
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case footer = "FooterText"
            case specifierKey = "Key"
            case defaultValue = "DefaultValue"
            case titles = "Titles"
            case values = "Values"
            case restartable = "Restartable"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.Radio: PathIdentifier {}

// MARK: CharacteristicStorable

public extension Specifier.Radio {
    class Characteristic: CharacteristicStorable, Equatable {
        
        @Storable
        public var storedContent: String {
            didSet {
                objectWillChange.send()
            }
        }
        public let key: String
        public let defaultValue: String
        public let titles: [String]
        public let values: [String]
        public let valueForTitle: [String: String]
        public let titleForValue: [String: String]
        
        internal init(key: String, defaultValue: String, titles: [String], values: [String], container: RepositoryStorable? = nil) {
            self.key = key
            self.defaultValue = defaultValue
            self.titles = titles
            self.values = values
            self.valueForTitle = Dictionary(uniqueKeysWithValues: zip(titles, values))
            self.titleForValue = Dictionary(uniqueKeysWithValues: zip(values, titles))
            _storedContent = .init(key: key, defaultValue: defaultValue, container: container)
        }
        
        public static func == (lhs: Characteristic, rhs: Characteristic) -> Bool {
            lhs.key == rhs.key &&
            lhs.defaultValue == rhs.defaultValue &&
            lhs.titles == rhs.titles &&
            lhs.values == rhs.values
        }
    }
}

// MARK: Hashable

extension Specifier.Radio {
    public static func == (lhs: Specifier.Radio, rhs: Specifier.Radio) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.footerText == rhs.footerText &&
        lhs.characteristic == rhs.characteristic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
