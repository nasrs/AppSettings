// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension MockEntries {
    enum ToggleSwitch {
        static let title = "Example Title"
        static let key = "some_key_toggle_switch"
        static let defaultValue = true
    }
    
    var toggleSwitchData: Data? {
        """
        {
            "Title": "\(ToggleSwitch.title)",
            "Key": "\(ToggleSwitch.key)",
            "DefaultValue": \(ToggleSwitch.defaultValue)
        }
        """.data(using: .utf8)
    }
}
