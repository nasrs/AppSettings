// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Foundation

extension MockEntries {
    var slider: Specifier.Slider {
        .init(
            characteristic: .init(
                key: "some_key_slider",
                defaultValue: 12,
                minValue: 3,
                maxValue: 17,
                container: mockStorable
            )
        )
    }
    
    var sliderData: Data? {
        """
        {
            "Key": "slider_example_key",
            "DefaultValue": 50.0,
            "MinimumValue": 5.0,
            "MaximumValue": 100.0
        }
        """.data(using: .utf8)
    }
}
