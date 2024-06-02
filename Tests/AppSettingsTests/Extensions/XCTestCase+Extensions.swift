// Copyright © ICS 2024 from aiPhad.com

import XCTest
import Foundation

extension XCTest {
    var mockEntries: MockEntries {
        MockEntries.shared
    }
}

enum Error: Swift.Error, Equatable {
    case emptyText
    case noDataFound
}
