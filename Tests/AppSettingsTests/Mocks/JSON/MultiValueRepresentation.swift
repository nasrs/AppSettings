// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Foundation

extension MockEntries {
    var multiValue: Specifier.MultiValue {
        .init(
            title: "MultiValue Title",
            characteristic: .init(
                key: "multi_value_example_key",
                defaultValue: "option_1",
                titles: ["Option 1", "Option 2", "Option 3"],
                values: ["option_1", "option_2", "option_3"],
                container: mockStorable)
        )
    }
    
    var multiValueData: Data? {
        """
        {
            "Key": "multi_value_example_key",
            "Title": "MultiValue Title",
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
