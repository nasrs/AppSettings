// Copyright © ICS 2024 from aiPhad.com

import Foundation
import Combine

/// Usage example:
///
///     public class Test {
///         public var id: UUID = .init()
///         public let title: String
///         var characteristic: Characteristic
///
///         init(id: UUID = .init(), title: String, characteristic: Characteristic) {
///             self.id = id
///             self.title = title
///             self.characteristic = characteristic
///         }
///     }
///
///     class Characteristic: SpecifierStorable {
///         var key: String
///         var defaultValue: Bool
///
///         @Storable
///         var storedContent: Bool
///
///         init(key: String, defaultValue: Bool) {
///             self.key = key
///             self.defaultValue = defaultValue
///             _storedContent = .init(key: key, defaultValue: defaultValue)
///         }
///     }

/// Allows to match for optionals with generics that are defined as non-optional.
public protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

@propertyWrapper
public struct Storable<Value> {
    private weak var container: RepositoryStorable?
    private let key: String
    private let defaultValue: Value
    
    init(key: String, defaultValue: Value, container: RepositoryStorable?) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
    
    public var wrappedValue: Value {
        get {
            container?.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container?.removeObject(forKey: key)
            } else {
                container?.set(newValue, forKey: key)
            }
        }
    }
}

extension Storable where Value: ExpressibleByNilLiteral {
    
    /// Creates a new User Defaults property wrapper for the given key.
    /// - Parameters:
    ///   - key: The key to use with the user defaults store.
    init(key: String, _ container: RepositoryStorable) {
        self.init(key: key, defaultValue: nil, container: container)
    }
}
