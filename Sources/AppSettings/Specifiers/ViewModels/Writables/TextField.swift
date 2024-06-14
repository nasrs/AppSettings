// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    public class TextField: SettingSearchable {
        @Published public internal(set) var characteristic: Characteristic
        public var id: UUID = .init()
        public let type: Kind = .textField
        public let title: String
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        public var specifierKey: String {
            characteristic.key
        }
        
        private(set) var shouldReset: Bool = true
        
        internal init(id: UUID = .init(), title: String, characteristic: TextField.Characteristic) {
            self.id = id
            self.title = title
            self.characteristic = characteristic
            self.accessibilityIdentifier = "\(characteristic.key)_textfield"
        }
        
        // MARK: Decodable

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? .empty
            
            let specifierKey = try container.decode(String.self, forKey: .specifierKey)
            let defaultValue = container.decodeAnyIfPresent(forKey: .defaultValue) ?? .empty
            let keyboard = try container.decodeIfPresent(Characteristic.KeyboardType.self, forKey: .keyboard) ?? .alphabet
            let isSecure = try container.decodeIfPresent(Bool.self, forKey: .isSecure) ?? false
            
            accessibilityIdentifier = "\(specifierKey)_textfield"
            shouldReset = try container.decodeIfPresent(Bool.self, forKey: .restartable) ?? true
            
            if let container = decoder.userInfo[Specifier.repository] as? RepositoryStorable {
                characteristic = .init(key: specifierKey,
                                       defaultValue: defaultValue,
                                       isSecure: isSecure,
                                       keyboard: keyboard,
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
            case specifierKey = "Key"
            case defaultValue = "DefaultValue"
            case keyboard = "KeyboardType"
            case isSecure = "IsSecure"
            case restartable = "Restartable"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.TextField: PathIdentifier {}

// MARK: CharacteristicStorable

public extension Specifier.TextField {
    class Characteristic: CharacteristicStorable, Equatable {
        public enum KeyboardType: String, Codable {
            case alphabet = "Alphabet"
            case numbersAndPunctuation = "NumbersAndPunctuation"
            case numPad = "NumberPad"
            case url = "URL"
            case email = "EmailAddress"
        }
        
        @Storable
        public var storedContent: String {
            didSet {
                objectWillChange.send()
            }
        }
        public let key: String
        public let defaultValue: String
        public let isSecure: Bool
        public let keyboard: KeyboardType
        
        internal init(key: String, defaultValue: String = .empty, isSecure: Bool = false, keyboard: KeyboardType = .alphabet, container: RepositoryStorable? = nil) {
            self.key = key
            self.defaultValue = defaultValue
            self.isSecure = isSecure
            self.keyboard = keyboard
            _storedContent = .init(key: key, defaultValue: defaultValue, container: container)
        }
        
        public static func == (lhs: Characteristic, rhs: Characteristic) -> Bool {
            lhs.key == rhs.key &&
            lhs.defaultValue == rhs.defaultValue &&
            lhs.isSecure == rhs.isSecure &&
            lhs.keyboard == rhs.keyboard
        }
    }
}

// MARK: Hashable

extension Specifier.TextField {
    public static func == (lhs: Specifier.TextField, rhs: Specifier.TextField) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.characteristic == rhs.characteristic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
