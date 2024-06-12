// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct ToggleSpecifierView: SpecifierSettingsViewing {
    private let searchIsActive: Bool
    var id: UUID { viewModel.id }
    @StateObject var viewModel: Specifier.ToggleSwitch
    @State var selected: Bool
    // only used for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    internal init(viewModel: Specifier.ToggleSwitch, searchActive: Bool) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchIsActive = searchActive
        _selected =  State(initialValue: viewModel.characteristic.storedContent)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextOrEmptyView(text: viewModel.title)
                    .font(.callout)
                
                Spacer()
                
                Toggle(String.empty, isOn: $selected)
                    .fixedSize()
                    .onChange(of: selected) { newValue in
                        if viewModel.characteristic.storedContent != newValue {
                            viewModel.characteristic.storedContent = newValue
                        }
                    }
                    .accessibilityIdentifier(viewModel.accessibilityIdentifier)
            }
            
            SearchingKeyView(searchIsActive: searchIsActive,
                             specifierKey: viewModel.specifierKey,
                             specifierTitle: viewModel.title,
                             specifierPath: viewModel.specifierPath)
        }
        .onAppear { didAppear?(self) }
    }
}

#Preview {
    let container = MockRepositoryStorable()
    let viewModel: Specifier.ToggleSwitch =
        .init(title: "Title",
              characteristic: .init(key: "user_defaults_toggle_key",
                                    defaultValue: true,
                                    container: container)
        )
    
    return Form {
        ToggleSpecifierView(viewModel: viewModel, searchActive: true)
    }
}
