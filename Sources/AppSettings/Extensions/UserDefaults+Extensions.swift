// Copyright © ICS 2024 from aiPhad.com

import Foundation

public protocol RepositoryStorable: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
    func register(defaults registrationDictionary: [String: Any])
}

extension UserDefaults: RepositoryStorable {}

#if DEBUG
    class MockRepositoryStorable: RepositoryStorable, ObservableObject {
        @Published var results: [String: Any] = [:]
        @Published var resetTriggered: Void?
        var didInteract = false
        
        func object(forKey defaultName: String) -> Any? {
            didInteract = true
            return results[defaultName]
        }
    
        func removeObject(forKey defaultName: String) {
            didInteract = true
            results.removeValue(forKey: defaultName)
        }
    
        func set(_ value: Any?, forKey defaultName: String) {
            didInteract = true
            results[defaultName] = value
        }
    
        func register(defaults registrationDictionary: [String: Any]) {
            didInteract = true
            results = registrationDictionary
        }
    
        func resetResults() {
            results.removeAll()
            resetTriggered = ()
        }
    }

    final class MockReader: SettingsBundleReading {
        @Published var resetTriggered: Void?
    
        var entries: [any SettingEntry] = []
        var findable: [any SettingSearchable] = []
    
        func resetAllEntries() {
            entries = []
            findable = []
        }
    
        func resetDefaults() async {
            resetTriggered = ()
        }
    
        init(entries: [any SettingEntry] = [], findable: [any SettingSearchable] = []) {
            self.entries = entries
            self.findable = findable
        }
    }
#endif
