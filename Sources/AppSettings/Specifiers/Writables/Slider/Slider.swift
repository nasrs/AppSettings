// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    public class Slider: SettingSearchable {
        @Published public internal(set) var characteristic: Characteristic
        public var id: UUID
        public let type: Kind = .slider
        public let title: String = .empty
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        public var specifierKey: String {
            characteristic.key
        }
        
        private(set) var shouldReset: Bool = true
        
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
            
            id = .init()
            accessibilityIdentifier = "\(specifierKey)_slider"
            shouldReset = try container.decodeIfPresent(Bool.self, forKey: .restartable) ?? true
            
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
            guard shouldReset else { return }
            characteristic.storedContent = characteristic.defaultValue
        }
        
        enum CodingKeys: String, CodingKey {
            case specifierKey = "Key"
            case defaultValue = "DefaultValue"
            case minValue = "MinimumValue"
            case maxValue = "MaximumValue"
            case restartable = "Restartable"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.Slider: PathIdentifier {}

// MARK: CharacteristicStorable

public extension Specifier.Slider {
    class Characteristic: CharacteristicStorable, Equatable {
        
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
        
        public static func == (lhs: Characteristic, rhs: Characteristic) -> Bool {
            lhs.key == rhs.key &&
            lhs.defaultValue == rhs.defaultValue &&
            lhs.minValue == rhs.minValue &&
            lhs.maxValue == rhs.maxValue
        }
    }
}

// MARK: Hashable

extension Specifier.Slider {
    public static func == (lhs: Specifier.Slider, rhs: Specifier.Slider) -> Bool {
        lhs.id == rhs.id &&
        lhs.characteristic == rhs.characteristic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
