// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    /// Used to identify the section of a set of entries
    public class Group: SettingEntry {
        public var id: UUID = .init()
        public let type: Kind = .group
        public let title: String
        public let footerText: String?
        public let characteristic: Characteristic
        public internal(set) var specifierPath: String = ""
        
        internal init(id: UUID = .init(), title: String, footerText: String? = nil, characteristic: Characteristic) {
            self.id = id
            self.title = title
            self.footerText = footerText
            self.characteristic = characteristic
        }
        
        // MARK: Decodable
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? .empty
            footerText = try container.decodeIfPresent(String.self, forKey: .footer)
            characteristic = .init()
        }
        
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case footer = "FooterText"
        }
    }
}

// MARK: PathIdentifier

extension Specifier.Group: PathIdentifier {}

extension Specifier.Group {
    public class Characteristic {
        public internal(set) var entries: [any SettingEntry]
        
        internal init(entries: [any SettingEntry] = []) {
            self.entries = entries
        }
    }
}

// MARK: Hashable

extension Specifier.Group {
    public static func == (lhs: Specifier.Group, rhs: Specifier.Group) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
