// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct RadioSpecifierView: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.Radio
    
    @State var selected: String = .empty
    
    private let searchIsActive: Bool
    
    init(viewModel: Specifier.Radio, searchActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchActive
        if let selected = viewModel.characteristic.titleForValue[viewModel.characteristic.storedContent] {
            _selected = State<String>(initialValue: selected)
        } else if let firstTitle = viewModel.characteristic.titles.first {
            _selected = State<String>(initialValue: firstTitle)
        }
    }
    
    var body: some View {
        Section {
            ForEach(Array(viewModel.characteristic.titles.enumerated()), id: \.offset) { idx, title in
                RadioOptionCell(title: title,
                                selected: title == selected)
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
                             specifierPath: viewModel.specifierPath)
        }
        .accentColouring(.black)
        .onChange(of: selected) { newValue in
            if let value = viewModel.characteristic.valueForTitle[newValue],
               viewModel.characteristic.storedContent != value {
                viewModel.characteristic.storedContent = value
            }
        }
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
                                  ])
        )
    
    return Form(content: {
        RadioSpecifierView(viewModel: viewModel,
                                      searchActive: true)
    })
}
