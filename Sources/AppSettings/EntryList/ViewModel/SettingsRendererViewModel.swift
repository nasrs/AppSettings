// Copyright © ICS 2024 from aiPhad.com

import Combine
import Foundation

extension SettingsRendererView {
    final class ViewModel: ObservableObject {
        @Published var visibleEntries: [any SettingEntry] = []
        @Published var searchText: String = ""
        
        var isSearching: Bool {
            searchText.isEmpty == false && searchText.count > 3
        }
        
        private var cancellable: AnyCancellable?
        private(set) var reader: (any SettingsBundleReading)?
        private(set) var searchable: SearchableEntries
        private var entries: [any SettingEntry]
        
        init(_ reader: any SettingsBundleReading) {
            self.reader = reader
            self.searchable = .init(reader.findable)
            self.entries = reader.entries
            self.defaultSetup()
        }
        
        private func defaultSetup() {
            setupBindings()
            performSmartFilter()
        }
        
        private func setupBindings() {
            guard cancellable == nil else { return }
            
            cancellable = $searchText
                .dropFirst()
                .removeDuplicates()
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    guard let self else { return }
                    self.performSmartFilter()
                })
        }
        
        private func performSmartFilter() {
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
        
        @MainActor
        func resetUserDefaults() async {
            visibleEntries = []
            await reader?.resetDefaults()
            searchText = .empty
            performSmartFilter()
        }

    }
}

