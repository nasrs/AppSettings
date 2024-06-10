// Copyright © ICS 2024 from aiPhad.com

import Foundation
import Combine
@testable import AppSettings

protocol EntriesMocker {
    // MARK: Writables
    var multiValue: Specifier.MultiValue { get }
    var radio: Specifier.Radio { get }
    var slider: Specifier.Slider { get }
    var textField: Specifier.TextField { get }
    var toggle: Specifier.ToggleSwitch { get }
}

final class MockEntries {
    static let shared: MockEntries = .init()
    
    let mockStorable: MockRepositoryStorable = MockRepositoryStorable()

    lazy var textField: Specifier.TextField = {
        .init(
            title: TextField.title,
            characteristic: .init(
                key: TextField.key,
                defaultValue: TextField.defaultValue,
                keyboard: TextField.keyboardType,
                container: mockStorable
            )
        )
    }()
    
    lazy var multiValue: Specifier.MultiValue = {
        .init(
            title: MultiValue.title,
            characteristic: .init(
                key: MultiValue.key,
                defaultValue: MultiValue.defaultValue,
                titles: MultiValue.titles,
                values: MultiValue.values,
                container: mockStorable)
        )
    }()
    
    lazy var radio: Specifier.Radio = {
        .init(
            title: Radio.title,
            footerText: Radio.footerText,
            characteristic: .init(
                key: Radio.key,
                defaultValue: Radio.defaultValue,
                titles: Radio.titles,
                values: Radio.values,
                container: mockStorable)
        )
    }()
    
    lazy var slider: Specifier.Slider = {
        .init(
            characteristic: .init(
                key: Slider.key,
                defaultValue: Slider.defaultValue,
                minValue: Slider.minimumValue,
                maxValue: Slider.maximumValue,
                container: mockStorable
            )
        )
    }()
    
    lazy var toggleSwitch: Specifier.ToggleSwitch = {
        .init(
            title: ToggleSwitch.title,
            characteristic: .init(
                key: ToggleSwitch.key,
                defaultValue: ToggleSwitch.defaultValue,
                container: mockStorable
            )
        )
    }()
    
    // MARK: Non Storable
    
    var childpane: Specifier.ChildPane = {
        .init(
            title: ChildPane.title,
            characteristic: .init(fileName: ChildPane.fileName)
        )
    }()
    
    var group: Specifier.Group = {
        .init(
            title: Group.title,
            footerText: Group.footerText,
            characteristic: .init()
        )
    }()
    
    func childPane(with entries: [any SettingEntry]) -> Specifier.ChildPane {
        childpane.characteristic.entries.append(contentsOf: entries)
        return childpane
    }
    
    func group(with entries: [any SettingEntry]) -> Specifier.Group {
        group.characteristic.entries.append(contentsOf: entries)
        return group
    }
    
    init() {}
}
