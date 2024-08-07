// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct SearchingKeyView: View {
    var searchIsActive: Bool
    var specifierKey: String
    var specifierTitle: String
    var specifierFooter: String?
    var specifierPath: String?
    private var shouldShowKey: Bool {
        !specifierKey.isEmpty && specifierKey != specifierTitle
    }
    // only valid for unit testing purposes
    var didAppear: ((Self) -> Void)?
        
    var body: some View {
        if searchIsActive {
            VStack(alignment: .leading, spacing: 2, content: {
                if shouldShowKey {
                    Text("key: \(specifierKey)")
                        .font(.caption)
                        .foregroundStyle(.gray.opacity(0.8))
                    Divider()
                }
                if let specifierPath, specifierPath.isEmpty == false {
                    Text(specifierPath)
                        .font(.system(size: 9))
                        .foregroundStyle(.gray.opacity(0.8))
                }
            })
            .padding(3)
            .border(Color(.systemGray).opacity(0.3), width: 1.0)
            .onAppear { didAppear?(self) }
        } else {
            if let specifierFooter,
               !specifierFooter.isEmpty {
                Text(specifierFooter)
                    .onAppear { didAppear?(self) }
            } else {
                EmptyView()
                    .onAppear { didAppear?(self) }
            }
        }
    }
}

#Preview {
    let specifierTitle = "Specifier title"
    
    return Form {
        VStack(alignment: .leading) {
            Text(specifierTitle)
            SearchingKeyView(searchIsActive: false,
                             specifierKey: "something_test",
                             specifierTitle: specifierTitle,
                             specifierFooter: "specifier footer",
                             specifierPath: "test → something → other")
        }
    }
}
