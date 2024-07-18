// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct GroupSpecifierView: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.Group
    var searchIsActive: Bool
    // only valid for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        Section {
            ForEach(viewModel.characteristic.entries, id: \.id) { viewModel in
                SettingsEntryView(viewModel: viewModel, searchIsActive: searchIsActive)
            }
        } header: {
            TextOrEmptyView(text: viewModel.title)
        } footer: {
            TextOrEmptyView(text: viewModel.footerText)
        }
        .onAppear { didAppear?(self) }
    }
}

#Preview {
    let viewModel = Specifier.Group(
        title: "Title",
        footerText: "Footer text",
        characteristic: .init(entries: [
            Specifier.ToggleSwitch(title: "Title",
                                   characteristic: .init(key: "user_defaults_toggle_key",
                                                         defaultValue: true)),
            Specifier.MultiValue(title: "MultiValue",
                                 characteristic:
                                 .init(key: "Multivalue",
                                       defaultValue: "default",
                                       titles: ["Title A", "Title B", "Title C" ],
                                       values: [ "title_a", "title_b", "title_c" ]
                                 ))
        ])
    )
    
    return Form(content: {
        GroupSpecifierView(viewModel: viewModel, searchIsActive: true)
    })
}
