// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    public class Slider: SettingSearchable {
        public var id: UUID = .init()
        public let type: Kind = .slider
        public let title: String = .empty
        public let characteristic: Characteristic
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        public var specifierKey: String {
            characteristic.key
        }
        
        internal init(id: UUID = .init(), characteristic: Characteristic) {
            self.id = id
            self.characteristic = characteristic
            self.accessibilityIdentifier = "\(characteristic.key)_slider"
        }

        // MARK: Decodable
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let specifierKey = try container.decode(String.self, forKey: .specifierKey)
            let minValue = try container.decode(Double.self, forKey: .minValue)
            let maxValue = try container.decode(Double.self, forKey: .maxValue)
            let defaultValue = try container.decode(Double.self, forKey: .defaultValue)
            
            accessibilityIdentifier = "\(specifierKey)_slider"
            
            if let container = decoder.userInfo[Specifier.repository] as? RepositoryStorable {
                characteristic = .init(key: specifierKey,
                                       defaultValue: defaultValue,
                                       minValue: minValue,
                                       maxValue: maxValue,
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
            case minValue = "MinimumValue"
            case maxValue = "MaximumValue"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.Slider: PathIdentifier {}

// MARK: CharacteristicStorable

public extension Specifier.Slider {
    class Characteristic: CharacteristicStorable {
        
        @Storable
        public var storedContent: Double
        public let key: String
        public let defaultValue: Double
        public let minValue: Double
        public let maxValue: Double
        
        internal init(key: String, defaultValue: Double, minValue: Double, maxValue: Double, container: RepositoryStorable? = nil) {
            self.key = key
            self.defaultValue = defaultValue
            self.minValue = minValue
            self.maxValue = maxValue
            _storedContent = .init(key: key, defaultValue: defaultValue, container: container)
        }
    }
}

// MARK: Hashable

extension Specifier.Slider {
    public static func == (lhs: Specifier.Slider, rhs: Specifier.Slider) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
