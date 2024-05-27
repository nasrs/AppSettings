// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

extension View {
    func accentColouring(_ accentColor: Color?) -> some View {
        if #available(iOS 15.0, *) {
            return self.tint(accentColor)
        } else {
            return self.accentColor(accentColor)
        }
    }
}
