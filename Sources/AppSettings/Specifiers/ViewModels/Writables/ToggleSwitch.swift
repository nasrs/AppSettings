// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    public class ToggleSwitch: SettingSearchable {
        public var id: UUID = .init()
        public let type: Kind = .toggleSwitch
        public let title: String
        public let characteristic: Characteristic
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        public var specifierKey: String {
            characteristic.key
        }
        
        internal init(id: UUID = .init(), title: String, characteristic: ToggleSwitch.Characteristic) {
            self.id = id
            self.title = title
            self.characteristic = characteristic
            self.accessibilityIdentifier = "\(characteristic.key)_toggle"
        }
    
        // MARK: Decodable

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
        
            let specifierKey = try container.decode(String.self, forKey: .specifierKey)
            let defaultValue = try? container.decodeIfPresent(Bool.self, forKey: .defaultValue)
            accessibilityIdentifier = "\(specifierKey)_toggle"
            
            if let container = decoder.userInfo[Specifier.repository] as? RepositoryStorable {
                characteristic = .init(key: specifierKey,
                                       defaultValue: defaultValue ?? false,
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
            case specifierKey = "Key"
            case defaultValue = "DefaultValue"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.ToggleSwitch: PathIdentifier {}

// MARK: CharacteristicStorable

public extension Specifier.ToggleSwitch {
    class Characteristic: CharacteristicStorable, Equatable {
        
        @Storable
        public var storedContent: Bool
        public let key: String
        public let defaultValue: Bool
        
        internal init(key: String, defaultValue: Bool, container: RepositoryStorable? = nil) {
            self.key = key
            self.defaultValue = defaultValue
            _storedContent = .init(key: key, defaultValue: defaultValue, container: container)
        }
        
        public static func == (lhs: Characteristic, rhs: Characteristic) -> Bool {
            lhs.key == rhs.key && lhs.defaultValue == rhs.defaultValue
        }
    }
}

// MARK: Hashable

extension Specifier.ToggleSwitch {
    public static func == (lhs: Specifier.ToggleSwitch, rhs: Specifier.ToggleSwitch) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.characteristic == rhs.characteristic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
