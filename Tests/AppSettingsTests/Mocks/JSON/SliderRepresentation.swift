 // Copyright © ICS 2024 from aiPhad.com

 import Foundation

 extension MockEntries {
     enum Slider {
         static let key = "slider_example_key"
         static let defaultValue = 17.0
         static let minimumValue = 7.0
         static let maximumValue = 56.0
     }
     
     var sliderData: Data? {
        """
        {
            "Key": "\(Slider.key)",
            "DefaultValue": \(Slider.defaultValue),
            "MinimumValue": \(Slider.minimumValue),
            "MaximumValue": \(Slider.maximumValue)
        }
        """.data(using: .utf8)
    }
 }
