// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension MockEntries {
    enum Radio {
        static let key = "radio_example_key"
        static let title = "Radio Title"
        static let footerText = "Radio Footer Text"
        static let titles = [
            "Option 1",
            "Option 2",
            "Option 3"
        ]
        static let values = [
            "option_1",
            "option_2",
            "option_3"
        ]
        static let defaultValue = "option_1"
    }
    
    var radioData: Data? {
        """
        {
            "Key": "\(Radio.key)",
            "Title": "\(Radio.title)",
            "FooterText": "\(Radio.footerText)",
            "Titles": \(Radio.titles),
            "Values": \(Radio.values),
            "DefaultValue": "\(Radio.defaultValue)"
        }
        """.data(using: .utf8)
    }
}
