// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct ChildPaneSpecifier<Destination: View>: SpecifierSettingsView {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.ChildPane
    @ViewBuilder var destination: () -> Destination
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            TextOrEmptyView(text: viewModel.title)
        }
        .accessibilityIdentifier(viewModel.accessibilityIdentifier)
    }
}

#Preview {
    let viewModel = Specifier.ChildPane(title: "Child pane",
                                        characteristic: .init(fileName: "blahblahblah"))
    
    return Form(content: {
        ChildPaneSpecifier(viewModel: viewModel) {
            Text("you'll land here")
        }
    })
}
