// Copyright © ICS 2024 from aiPhad.com

import Foundation

extension MockEntries {
    enum MultiValue {
        static let key = "multi_value_example_key"
        static let title = "MultiValue Title"
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
    
    var multiValueData: Data? {
        """
        {
            "Key": "\(MultiValue.key)",
            "Title": "\(MultiValue.title)",
            "Titles": \(MultiValue.titles),
            "Values": \(MultiValue.values),
            "DefaultValue": "\(MultiValue.defaultValue)"
        }
        """.data(using: .utf8)
    }
}
