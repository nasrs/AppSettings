// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct RadioSpecifierView: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    @StateObject var viewModel: Specifier.Radio
    private let searchIsActive: Bool
    @State var selected: String = ""
    // only used for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    init(viewModel: Specifier.Radio, searchActive: Bool) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchIsActive = searchActive
        if let selected = viewModel.characteristic.titleForValue[viewModel.characteristic.storedContent] {
            _selected = State(initialValue: selected)
        } else if let firstTitle = viewModel.characteristic.titles.first {
            _selected = State(initialValue: firstTitle)
        }
    }
    
    var body: some View {
        Section {
            ForEach(Array(viewModel.characteristic.titles.enumerated()), id: \.offset) { idx, title in
                RadioOptionCell(title: title, selected: title == selected)
                    .accessibilityIdentifier(viewModel.accessibilityIdentifier + "_\(idx)")
                    .onTapGesture {
                        if selected != title {
                            selected = title
                        }
                    }
            }
        } header: {
            TextOrEmptyView(text: viewModel.title)
        } footer: {
            SearchingKeyView(searchIsActive: searchIsActive,
                             specifierKey: viewModel.specifierKey,
                             specifierTitle: viewModel.title,
                             specifierFooter: viewModel.footerText,
                             specifierPath: viewModel.specifierPath)
        }
        .accentColouring(.black)
        .onChange(of: selected) { newValue in
            if let value = viewModel.characteristic.valueForTitle[newValue],
               viewModel.characteristic.storedContent != value {
                viewModel.characteristic.storedContent = value
            }
        }
        .onAppear { self.didAppear?(self) }
    }
}

struct RadioOptionCell: View {
    var title: String
    var selected: Bool
    
    var body: some View {
        HStack(content: {
            TextOrEmptyView(text: title)
            Spacer()
            if selected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        })
        .contentShape(Rectangle())
    }
}

#Preview {
    let container = MockRepositoryStorable()
    let viewModel: Specifier.Radio =
        .init(
            title: "Radio",
            footerText: "footer text",
            characteristic: .init(key: "user_defaults_key",
                                  defaultValue: "radio_2",
                                  titles: [
                                      "radio 1",
                                      "radio 2",
                                      "radio 3",
                                  ],
                                  values: [
                                      "radio_1",
                                      "radio_2",
                                      "radio_3",
                                  ],
                                 container: container)
        )
    
    return Form(content: {
        RadioSpecifierView(viewModel: viewModel,
                           searchActive: true)
    })
}
