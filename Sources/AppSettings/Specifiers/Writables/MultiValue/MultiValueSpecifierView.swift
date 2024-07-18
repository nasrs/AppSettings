// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct MultiValueSpecifierView: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    @StateObject var viewModel: Specifier.MultiValue
    @State var selected: String = ""
    // only used for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    private let searchIsActive: Bool
    
    init(viewModel: Specifier.MultiValue, searchActive: Bool) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchIsActive = searchActive
        if let selected = viewModel.characteristic.titleForValue[viewModel.characteristic.storedContent] {
            _selected = State(initialValue: selected)
        } else if let firstTitle = viewModel.characteristic.titles.first {
            _selected = State(initialValue: firstTitle)
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
        .onAppear { self.didAppear?(self) }
    }
}

#Preview {
    let container = MockRepositoryStorable()
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
                                  ],
                                 container: container)
        )
    
    return Form {
        MultiValueSpecifierView(viewModel: viewModel, searchActive: true)
    }
}
