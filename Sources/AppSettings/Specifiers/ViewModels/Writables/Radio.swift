// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    public class Radio: SettingSearchable {
        public var id: UUID = .init()
        public let type: Kind = .radio
        public let title: String
        public let footerText: String?
        public let characteristic: Characteristic
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        public var specifierKey: String {
            characteristic.key
        }
        
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
            characteristic.storedContent = characteristic.defaultValue
        }
        
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case footer = "FooterText"
            case specifierKey = "Key"
            case defaultValue = "DefaultValue"
            case titles = "Titles"
            case values = "Values"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.Radio: PathIdentifier {}

// MARK: CharacteristicStorable

public extension Specifier.Radio {
    class Characteristic: CharacteristicStorable {
        
        @Storable
        public var storedContent: String
        public let key: String
        public var defaultValue: String
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
    }
}

// MARK: Hashable

extension Specifier.Radio {
    public static func == (lhs: Specifier.Radio, rhs: Specifier.Radio) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
