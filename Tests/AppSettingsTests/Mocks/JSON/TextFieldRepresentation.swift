// Copyright © ICS 2024 from aiPhad.com

import Foundation
@testable import AppSettings

extension MockEntries {
    enum TextField {
        static let title = "TextField Your title here"
        static let key = "text_field_example_key"
        static let defaultValue = "textfield default value"
        static let keyboardType = Specifier.TextField.Characteristic.KeyboardType.alphabet
        static let isSecure = false
    }
    
    var textFieldData: Data? {
        """
        {
            "Title": "\(TextField.title)",
            "Key": "\(TextField.key)",
            "DefaultValue": "\(TextField.defaultValue)",
            "KeyboardType": "\(TextField.keyboardType.rawValue)",
            "IsSecure": \(TextField.isSecure)
        }
        """.data(using: .utf8)
    }
}
