// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct ChildPaneSpecifierView<Destination: View>: SpecifierSettingsViewing {
    var id: UUID { viewModel.id }
    var viewModel: Specifier.ChildPane
    @ViewBuilder var destination: () -> Destination
    // only used for unit testing purposes
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            TextOrEmptyView(text: viewModel.title)
        }
        .accessibilityIdentifier(viewModel.accessibilityIdentifier)
        .onAppear { didAppear?(self) }
    }
}

#Preview {
    let viewModel = Specifier.ChildPane(title: "Child pane",
                                        characteristic: .init(fileName: "blahblahblah"))
    
    return Form(content: {
        ChildPaneSpecifierView(viewModel: viewModel) {
            Text("you'll land here")
        }
    })
}
