// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension Specifier {
    /// Used to identify the section of a set of entries
    public class Group: SettingEntry {
        public var id: UUID
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
            id = .init()
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

extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

extension Specifier.Group {
    public class Characteristic: Equatable {
        public internal(set) var entries: [any SettingEntry]
        
        internal init(entries: [any SettingEntry] = []) {
            self.entries = entries
        }
        
        public static func ==(lhs: Specifier.Group.Characteristic, rhs: Specifier.Group.Characteristic) -> Bool {
            guard lhs.entries.count == rhs.entries.count else { return false }
            
            return lhs.entries.enumerated().first(where: {
                rhs.entries[$0].isEqual($1) == false
            }).isNil
        }
    }
}

// MARK: Hashable

extension Specifier.Group {
    public static func == (lhs: Specifier.Group, rhs: Specifier.Group) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.footerText == rhs.footerText &&
        lhs.characteristic == rhs.characteristic
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(id)\(title)")
    }
}
