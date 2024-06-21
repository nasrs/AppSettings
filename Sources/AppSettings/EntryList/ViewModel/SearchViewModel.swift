// Copyright © ICS 2024 from aiPhad.com

import Combine
import Foundation

final class SearchableEntries: ObservableObject {
    private(set) var entries: [any SettingSearchable]
    
    init(_ searchable: [any SettingSearchable]) {
        self.entries = searchable
    }
}

final class SearchViewModel: ObservableObject {
    @Published var visibleEntries: [any SettingEntry] = []
    @Published var searchText: String = ""
    
    var isSearching: Bool {
        searchText.isEmpty == false && searchText.count > 3
    }
    
    private let entries: [any SettingEntry]
    private var cancellables = Set<AnyCancellable>()
    var searchable: SearchableEntries
    
    init(entries: [any SettingEntry], findable: [any SettingSearchable] = []) {
        self.entries = entries
        self.searchable = .init(findable)
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
    
    @MainActor
    func resetUserDefaults() async {
        visibleEntries = []
        await SettingsBundleReader.shared?.resetDefaults()
        searchText = .empty
        performSmartFilter()
    }
}
