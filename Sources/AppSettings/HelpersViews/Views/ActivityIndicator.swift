// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct ActivityIndicator: View {
    var title: String? = nil
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            VStack {
                if let title, title.isEmpty == false {
                    Text(title)
                        .bold()
                        .font(.title)
                        .foregroundColor(.gray.opacity(0.8))
                }
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.4, anchor: .center)
            }
        }
    }
}

#Preview {
    ActivityIndicator(title: "the title")
}
