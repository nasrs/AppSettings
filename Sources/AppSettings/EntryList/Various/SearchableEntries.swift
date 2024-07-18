// Copyright © ICS 2024 from aiPhad.com

import Foundation

final class SearchableEntries: ObservableObject {
    private(set) var entries: [any SettingSearchable]
    
    init(_ searchable: [any SettingSearchable]) {
        self.entries = searchable
    }
}
