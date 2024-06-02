// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct MultiValueSpecifier: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.MultiValue
    
    @State var selected: String = .empty
    private let searchIsActive: Bool
    
    init(viewModel: Specifier.MultiValue, searchActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchActive
        if let selected = viewModel.characteristic.titleForValue[viewModel.characteristic.storedContent] {
            self._selected = State<String>(initialValue: selected)
        } else if let firstTitle = viewModel.characteristic.titles.first {
            self._selected = State<String>(initialValue: firstTitle)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $selected) {
                ForEach(Array(viewModel.characteristic.titles.enumerated()), id: \.offset) { idx, title in
                    // We need to provide an unique tag to the visible text of the picker,
                    // otherwise weird logs start appearing, and the the Setting is not changed accordingly
                    Text(title)
                        .tag(title)
                        .accessibilityIdentifier("option_\(idx)")
                }
            } label: {
                TextOrEmptyView(text: viewModel.title)
            }
            .accessibilityIdentifier(viewModel.accessibilityIdentifier)
            .pickerStyle(.menu)
            .accentColouring(.black)
            .onChange(of: selected) { newValue in
                if let value = viewModel.characteristic.valueForTitle[newValue],
                   viewModel.characteristic.storedContent != value {
                    viewModel.characteristic.storedContent = value
                }
            }
            
            SearchingKeyView(searchIsActive: searchIsActive,
                             specifierKey: viewModel.specifierKey,
                             specifierTitle: viewModel.title,
                             specifierPath: viewModel.specifierPath)
        }
    }
}

#Preview {
    let viewModel: Specifier.MultiValue =
        .init(
            title: "Multi Value",
            characteristic: .init(key: "user_defaults_key",
                                  defaultValue: "test_3",
                                  titles: [
                                      "test 1",
                                      "test 2",
                                      "test 3",
                                  ],
                                  values: [
                                      "test_1",
                                      "test_2",
                                      "test_3",
                                  ])
        )
    
    return Form {
        MultiValueSpecifier(viewModel: viewModel, searchActive: true)
    }
}
