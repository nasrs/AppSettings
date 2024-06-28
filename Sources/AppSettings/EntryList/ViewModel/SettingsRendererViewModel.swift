// Copyright © ICS 2024 from aiPhad.com

import Combine
import Foundation

extension SettingsRendererView {
    final class ViewModel: ObservableObject, SmartSearching {
        @Published var visibleEntries: [any SettingEntry] = []
        @Published var searchText: String = ""
        
        private var cancellable: AnyCancellable?
        private(set) var reader: (any SettingsBundleReading)?
        private(set) var searchable: SearchableEntries
        private(set) var entries: [any SettingEntry]
        
        init(_ reader: any SettingsBundleReading) {
            self.reader = reader
            searchable = .init(reader.findable)
            entries = reader.entries
            defaultSetup()
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
        
        @MainActor
        func resetUserDefaults() async {
            visibleEntries = []
            await reader?.resetDefaults()
            searchText = .empty
            performSmartFilter()
        }
    }
}
