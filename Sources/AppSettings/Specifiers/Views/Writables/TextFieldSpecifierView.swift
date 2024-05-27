// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct TextFieldSpecifierView: SpecifierSettingsView {
    private enum Constants {
        static let padding = CGFloat(24)
    }
    
    private var searchIsActive: Bool
    var id: UUID { viewModel.id }
    var viewModel: Specifier.TextField
    @State var contentBinding: String
    
    internal init(viewModel: Specifier.TextField, searchActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchActive
        self.contentBinding = viewModel.characteristic.storedContent ?? .empty
        self.searchIsActive = searchActive
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextOrEmptyView(text: viewModel.title)
                
                Spacer(minLength: Constants.padding)
                
                TextField(
                    viewModel.characteristic.defaultValue ?? .empty,
                    text: $contentBinding
                )
                .accessibilityIdentifier(viewModel.accessibilityIdentifier)
                .onChange(of: contentBinding) { newValue in
                    if viewModel.characteristic.storedContent != newValue {
                        viewModel.characteristic.storedContent = newValue
                    }
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
    let viewModel: Specifier.TextField =
        .init(title: "Remaining",
              characteristic: .init(key: "user_defaults_textfield_key",
                                    defaultValue: "some value"))
    
    return Form {
        TextFieldSpecifierView(viewModel: viewModel, searchActive: true)
    }
}
