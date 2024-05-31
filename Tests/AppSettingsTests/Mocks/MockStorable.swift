// Copyright © ICS 2024 from aiPhad.com

import Foundation
import AppSettings

final class MockStoreEntity: RepositoryStorable {
    private var results: [String: Any] = [:]
    
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
}
