// Copyright © ICS 2024 from aiPhad.com

import Foundation

public enum Specifier {}

extension Specifier {
    public enum Kind: String, CaseIterable {
        case childPane = "PSChildPaneSpecifier"
        case group = "PSGroupSpecifier"
        case multiValue = "PSMultiValueSpecifier"
        case textField = "PSTextFieldSpecifier"
        case toggleSwitch = "PSToggleSwitchSpecifier"
        case slider = "PSSliderSpecifier"
        case radio = "PSRadioGroupSpecifier"
        // possible to exist but not rendered on Settings so the supporto will exist but the object itself won't be unwrapped
        case titleValue = "PSTitleValueSpecifier"
        
        public var friendlyName: String {
            switch self {
            case .childPane:
                "Navigation"
            case .group:
                "Group"
            case .multiValue:
                "Multi Value"
            case .textField:
                "Text field"
            case .toggleSwitch:
                "Toggle"
            case .slider:
                "Slider"
            case .radio:
                "Radio"
            case .titleValue:
                "Title"
            }
        }
    }
    
    public static var repository: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "repository")!
    }
}
