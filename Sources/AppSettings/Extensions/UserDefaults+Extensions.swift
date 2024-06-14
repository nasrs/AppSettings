// Copyright © ICS 2024 from aiPhad.com

import Foundation

public protocol RepositoryStorable: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
    func register(defaults registrationDictionary: [String : Any])
}

extension UserDefaults: RepositoryStorable {}

#if DEBUG
class MockRepositoryStorable: RepositoryStorable, ObservableObject {
    @Published var results: [String: Any] = [:]
    
    func object(forKey defaultName: String) -> Any? {
        return results[defaultName]
    }
    
    func removeObject(forKey defaultName: String) {
        results.removeValue(forKey: defaultName)
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        results[defaultName] = value
    }
    
    func register(defaults registrationDictionary: [String : Any]) {
        results = registrationDictionary
    }
    
    func resetResults() {
        results.removeAll()
    }
}
#endif
