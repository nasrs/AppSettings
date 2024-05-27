// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct InnerSettingsListView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var reseting: Bool = false
    private let title: String
    
    init(entries: [any SettingEntry], title: String) {
        self.title = title
        
        _viewModel = StateObject(
            wrappedValue: SearchViewModel(entries)
        )
    }
    
    var body: some View {
        settingsEntryContent()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .searchable(text: $viewModel.searchText,
                        prompt: "Insert title or key")
    }
    
    @ViewBuilder
    private func settingsEntryContent() -> some View {
        if viewModel.visibleEntries.isEmpty {
            EmptySearchResultView()
        } else {
            Form(content: {
                ForEach(viewModel.visibleEntries, id: \.id) { entryViewModel in
                    SettingsEntryView(viewModel: entryViewModel,
                                      searchIsActive: viewModel.isSearching)
                }
            })
        }
    }
}

#Preview {
    let entries: [any SettingEntry] = [
        Specifier.ToggleSwitch(title: "Title",
                               characteristic: .init(key: "user_defaults_toggle_key",
                                                     defaultValue: true)),
        
        Specifier.TextField(title: "Remaining",
                            characteristic: .init(key: "user_defaults_textfield_key",
                                                  defaultValue: "some value")),
        
        Specifier.MultiValue(title: "Multi Value",
                             characteristic: .init(key: "user_defaults_key",
                                                   defaultValue: "test 2",
                                                   titles: [
                                                       "test 1",
                                                       "test 2",
                                                       "test 3",
                                                   ],
                                                   values: [
                                                       "test_1",
                                                       "test_2",
                                                       "test_3",
                                                   ])),
    ]
    
    return InnerSettingsListView(entries: entries, title: "Screen title")
}
