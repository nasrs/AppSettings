// Copyright © ICS 2024 from aiPhad.com

import SwiftUI

public struct SettingsEntryView: SpecifierSettingsViewing {
    public var id: UUID { viewModel.id }
    public var viewModel: any SettingEntry
    private var searchIsActive: Bool
    
    public init(viewModel: any SettingEntry, searchIsActive: Bool) {
        self.viewModel = viewModel
        self.searchIsActive = searchIsActive
    }
    
    public var body: some View {
        switch viewModel.type {
        case .childPane:
            let viewModel = viewModel as! Specifier.ChildPane
            ChildPaneSpecifierView(viewModel: viewModel) {
                InnerSettingsListView(entries: viewModel.characteristic.entries, 
                                      title: viewModel.title)
            }
        case .group:
            let viewModel = viewModel as! Specifier.Group
            GroupSpecifierView(viewModel: viewModel, searchIsActive: searchIsActive)
        case .multiValue:
            let viewModel = viewModel as! Specifier.MultiValue
            MultiValueSpecifierView(viewModel: viewModel, searchActive: searchIsActive)
        case .textField:
            let viewModel = viewModel as! Specifier.TextField
            TextFieldSpecifierView(viewModel: viewModel, searchActive: searchIsActive)
        case .toggleSwitch:
            let viewModel = viewModel as! Specifier.ToggleSwitch
            ToggleSpecifierView(viewModel: viewModel, searchActive: searchIsActive)
        case .radio:
            let viewModel = viewModel as! Specifier.Radio
            RadioSpecifierView(viewModel: viewModel, searchActive: searchIsActive)
        case .slider:
            let viewModel = viewModel as! Specifier.Slider
            SliderSpecifierView(viewModel: viewModel, searchActive: searchIsActive)
        default:
            EmptyView()
        }
    }
}

#Preview {
    let viewModel = Specifier.ToggleSwitch(title: "Title",
                                           characteristic: .init(key: "user_defaults_toggle_key",
                                                                 defaultValue: true))
    
    return Form(content: {
        SettingsEntryView(viewModel: viewModel, searchIsActive: true)
    })
}
