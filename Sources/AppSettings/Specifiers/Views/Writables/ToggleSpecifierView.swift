// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct ToggleSpecifierView: SpecifierSettingsView {
    private let searchIsActive: Bool
    var id: UUID { viewModel.id }
    var viewModel: Specifier.ToggleSwitch
    
    @State var selected: Bool
    
    internal init(viewModel: Specifier.ToggleSwitch, searchActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchActive
        selected = viewModel.characteristic.storedContent
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
    }
}

#Preview {
    let viewModel: Specifier.ToggleSwitch =
        .init(title: "Title",
              characteristic: .init(key: "user_defaults_toggle_key",
                                    defaultValue: true))
    
    return Form {
        ToggleSpecifierView(viewModel: viewModel, searchActive: true)
    }
}
