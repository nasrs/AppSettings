// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Foundation

extension MockEntries {
    var radio: Specifier.Radio {
        .init(
            title: "Radio Title",
            footerText: "Radio Footer Text",
            characteristic: .init(
                key: "radio_example_key",
                defaultValue: "option_1",
                titles: ["Option 1", "Option 2", "Option 3"],
                values: ["option_1", "option_2", "option_3"],
                container: mockStorable)
        )
    }
    
    var radioData: Data? {
        """
        {
            "Key": "radio_example_key",
            "Title": "Radio Title",
            "FooterText": "Radio Footer Text",
            "Titles": [
                "Option 1",
                "Option 2",
                "Option 3"
            ],
            "Values": [
                "option_1",
                "option_2",
                "option_3"
            ],
            "DefaultValue": "option_1"
        }
        """.data(using: .utf8)
    }
}
