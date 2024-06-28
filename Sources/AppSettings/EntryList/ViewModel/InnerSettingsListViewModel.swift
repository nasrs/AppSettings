// Copyright © ICS 2024 from aiPhad.com

import Combine
import Foundation

extension InnerSettingsListView {
    final class ViewModel: ObservableObject {
        @Published var visibleEntries: [any SettingEntry] = []
        @Published var searchText: String = ""
        
        var searchable: SearchableEntries
        
        var isSearching: Bool {
            searchText.isEmpty == false && searchText.count > 3
        }
        
        private var entries: [any SettingEntry]
        private var cancellables = Set<AnyCancellable>()
        
        init(entries: [any SettingEntry], findable: [any SettingSearchable] = []) {
            self.searchable = .init(findable)
            self.entries = entries
            self.defaultSetup()
        }
        
        private func defaultSetup() {
            performSmartFilter()
            setupBindings()
        }
        
        private func setupBindings() {
            guard cancellables.isEmpty else { return }
            
            $searchText
                .removeDuplicates()
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    guard let self else { return }
                    self.performSmartFilter()
                })
                .store(in: &cancellables)
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
    }
}
