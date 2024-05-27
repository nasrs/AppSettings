// Copyright © ICS 2024 from aiPhad.com

import Foundation

public protocol RepositoryStorable: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
    func register(defaults registrationDictionary: [String : Any])
}

extension UserDefaults: RepositoryStorable {}
