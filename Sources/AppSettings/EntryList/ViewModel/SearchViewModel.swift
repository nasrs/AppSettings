// Copyright © ICS 2024 from aiPhad.com

import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    @Published var visibleEntries: [any SettingEntry] = []
    @Published var searchText: String = ""
    
    var isSearching: Bool {
        searchText.isEmpty == false && searchText.count > 3
    }
    
    private let entries: [any SettingEntry]
    private var cancellables = Set<AnyCancellable>()
    private var findableEntries: [any SettingSearchable] {
        SettingsBundleReader.shared?.searchable ?? []
    }
    
    init(_ entries: [any SettingEntry]) {
        self.entries = entries
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
    
    @MainActor
    func resetUserDefaults() async {
        visibleEntries = []
        await SettingsBundleReader.shared?.resetDefaults()
        searchText = .empty
        performSmartFilter()
    }
    
    private func performSmartFilter() {
        guard !searchText.isEmpty || searchText.count > 3 else {
            visibleEntries = entries
            return
        }
        var filteredEntries: [any SettingEntry]
        
        if let regexObject = NSRegularExpression(searchText.lowercased()) {
            filteredEntries = findableEntries.filter {
                regexObject.matchPattern($0.title.lowercased()) ||
                    regexObject.matchPattern($0.specifierKey.lowercased())
            }
        } else {
            filteredEntries = findableEntries.filter {
                $0.title.localizedStandardContains(searchText) ||
                    $0.specifierKey.localizedStandardContains(searchText)
            }
        }
        
        visibleEntries = filteredEntries
    }
}
