// Copyright © ICS 2024 from aiPhad.com

import Foundation

protocol SmartSearching: AnyObject {
    var searchable: SearchableEntries { get }
    var isSearching: Bool { get }
    var entries: [any SettingEntry] { get }
    var searchText: String { get }
    var visibleEntries: [any SettingEntry] { get set }
    
    func performSmartFilter()
}

extension SmartSearching {
    var isSearching: Bool {
        searchText.isEmpty == false && searchText.count > 3
    }
    
    func performSmartFilter() {
        guard !searchText.isEmpty || searchText.count > 3 else {
            visibleEntries = entries
            return
        }
        
        guard let regexObject = NSRegularExpression(searchText.lowercased()) else {
            return
        }
        
        var filteredEntries: [any SettingEntry]
        
        filteredEntries = searchable.entries.filter {
            regexObject.matchPattern($0.title.lowercased()) ||
                regexObject.matchPattern($0.specifierKey.lowercased())
        }
        
        visibleEntries = filteredEntries
    }
}
