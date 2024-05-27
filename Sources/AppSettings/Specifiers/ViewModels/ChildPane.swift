// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    /// Used to identify the content of the next screen
    public class ChildPane: SettingEntry {
        public var id: UUID = .init()
        public let type: Kind = .childPane
        public let title: String
        public let characteristic: Characteristic
        public let accessibilityIdentifier: String
        public internal(set) var specifierPath: String = ""
        
        internal init(id: UUID = .init(), title: String, characteristic: ChildPane.Characteristic) {
            self.id = id
            self.title = title
            self.characteristic = characteristic
            self.accessibilityIdentifier = title.replacingOccurrences(of: " ", with: "_").lowercased() + "_navigation"
        }
        
        // MARK: Decodable
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            let fileName = try container.decode(String.self, forKey: .fileName)
            accessibilityIdentifier = title.replacingOccurrences(of: " ", with: "_").lowercased() + "_navigation"
            characteristic = .init(fileName: fileName)
        }
        
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case fileName = "File"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.ChildPane: PathIdentifier {}

extension Specifier.ChildPane {
    public class Characteristic {
        public let fileName: String
        public internal(set) var entries: [any SettingEntry] = []
        
        internal init(fileName: String) {
            self.fileName = fileName
        }
    }
}

// MARK: Hashable

extension Specifier.ChildPane {
    public static func == (lhs: Specifier.ChildPane, rhs: Specifier.ChildPane) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
