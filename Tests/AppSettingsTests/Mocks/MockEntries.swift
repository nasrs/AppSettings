// Copyright © ICS 2024 from aiPhad.com

import Foundation
@testable import AppSettings

protocol EntriesMocker {
    // MARK: Writables
    var multiValue: Specifier.MultiValue { get }
    var radio: Specifier.Radio { get }
    var slider: Specifier.Slider { get }
    var textField: Specifier.TextField { get }
    var toggle: Specifier.ToggleSwitch { get }
}

struct MockEntries {
    static let shared: MockEntries = .init()
    
    let mockStorable: RepositoryStorable = MockStoreEntity()

    func childPane(with entries: [any SettingEntry]) -> Specifier.ChildPane {
        childpane.characteristic.entries.append(contentsOf: entries)
        return childpane
    }
    
    func group(_ entries: [any SettingEntry]) -> Specifier.Group {
        group.characteristic.entries.append(contentsOf: entries)
        return group
    }
    
    init() {}
}
