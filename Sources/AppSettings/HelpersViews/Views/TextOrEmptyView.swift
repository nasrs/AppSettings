// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct TextOrEmptyView: View {
    var text: String?
    
    var body: some View {
        if let text, text.isEmpty == false {
            Text(text)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    TextOrEmptyView(text: "test")
}
