// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct TextFieldSpecifierView: SpecifierSettingsViewing {
    private enum Constants {
        static let padding = CGFloat(24)
    }
    
    private var searchIsActive: Bool
    var id: UUID { viewModel.id }
    var viewModel: Specifier.TextField
    @State var contentBinding: String
    // only used for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    internal init(viewModel: Specifier.TextField, searchActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchActive
        _contentBinding = State(initialValue: viewModel.characteristic.storedContent)
        self.searchIsActive = searchActive
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextOrEmptyView(text: viewModel.title)
                
                Spacer(minLength: Constants.padding)
                
                TextField(viewModel.characteristic.defaultValue,
                          text: $contentBinding)
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
        .onAppear { didAppear?(self) }
    }
}

#Preview {
    let container = MockRepositoryStorable()
    let viewModel: Specifier.TextField =
        .init(title: "Remaining",
              characteristic: .init(key: "user_defaults_textfield_key",
                                    defaultValue: "some value",
                                    container: container))
    
    return Form {
        TextFieldSpecifierView(viewModel: viewModel, searchActive: true)
    }
}
