// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct GroupSpecifier: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.Group
    var searchIsActive: Bool
    
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
        GroupSpecifier(viewModel: viewModel, searchIsActive: true)
    })
}
