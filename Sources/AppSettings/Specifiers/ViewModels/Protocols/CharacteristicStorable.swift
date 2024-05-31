// Copyright © ICS 2024 from aiPhad.com

import Foundation

public protocol CharacteristicStorable {
    associatedtype Value: Equatable
    var key: String { get }
    var defaultValue: Value { get }
    var storedContent: Value { get }
}
