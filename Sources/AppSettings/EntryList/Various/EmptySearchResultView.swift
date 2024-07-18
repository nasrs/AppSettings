// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

struct EmptySearchResultView: View {
    var reseting: Bool = false
    
    var body: some View {
        VStack {
            if reseting {
                ActivityIndicator(title: "Loading")
            } else {
                Spacer()
                Text("Found 0 results")
                    .font(.title)
                    .foregroundStyle(.gray)
                Text("Pattern searches available.\n")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                Text("\(String.contains) - unordered search")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                Text("\(String.matchOrder) - ordered search")
                    .font(.callout)
                    .foregroundStyle(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("Example 1:\nsomething@other@string is a search with every possibilities available for the 3 elements")
                    .font(.body)
                    .foregroundStyle(.gray.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                Text("Example 2:\nsomething#other#string is a search that assume all 3 strings are in the expected order on the final result")
                    .font(.body)
                    .foregroundStyle(.gray.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                Spacer()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptySearchResultView(reseting: true)
}
