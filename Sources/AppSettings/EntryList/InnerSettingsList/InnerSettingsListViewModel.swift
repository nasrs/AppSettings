// Copyright © ICS 2024 from aiPhad.com

import Combine
import Foundation

extension InnerSettingsListView {
    final class ViewModel: ObservableObject, SmartSearching {
        @Published var visibleEntries: [any SettingEntry] = []
        @Published var searchText: String = ""
        
        var searchable: SearchableEntries
        
        private(set) var entries: [any SettingEntry]
        private var cancellable: AnyCancellable?
        
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
            guard cancellable == nil else { return }
            
            cancellable = $searchText
                .removeDuplicates()
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    guard let self else { return }
                    self.performSmartFilter()
                })
        }
    }
}
