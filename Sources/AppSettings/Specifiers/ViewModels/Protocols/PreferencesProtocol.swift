// Copyright © ICS 2024 from aiPhad.com

import Foundation

public protocol SettingEntry: Decodable, Identifiable, Hashable, AnyObject {
    var id: UUID { get }
    var type: Specifier.Kind { get }
    var title: String { get }
    var specifierPath: String { get }
}

public protocol SettingSearchable: SettingEntry {
    var specifierKey: String { get }
    var accessibilityIdentifier: String { get }
    func resetSpecifier()
}

protocol PathIdentifier: SettingEntry {
    var specifierPath: String { get set }
    func appendPath(_ parent: String?)
}

extension PathIdentifier {
    func appendPath(_ parent: String?) {
        guard let parent else { return }
        if specifierPath.isEmpty {
            let titleToUse = title.isEmpty ? type.friendlyName : title
            specifierPath = parent.isEmpty ? titleToUse : "\(parent) → \(titleToUse)"
        } else {
            specifierPath.append(" → \(parent)")
        }
    }
}

public protocol SettingWritable: SettingEntry {
    var key: String { get set }
}

public enum DecodingError: Error {
    case unableToFindRepository
}

extension DecodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unableToFindRepository:
            return NSLocalizedString("Unable to find a valid RepositoryStorable object",
                                     comment: "Try to find any related error on console")
        }
    }
}
