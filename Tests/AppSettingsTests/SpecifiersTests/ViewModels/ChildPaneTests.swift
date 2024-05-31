// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import XCTest

final class ChildPaneTests: XCTestCase {
    var sut: Specifier.ChildPane!
    var characteristic: Specifier.ChildPane.Characteristic!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = mockEntries.childpane
        sut.characteristic.entries = [
            mockEntries.textField
        ]
        XCTAssertNotNil(sut)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        characteristic = nil
    }

    func test_childPane_isValidAsExpected() throws {
        XCTAssertEqual(sut.type, .childPane)
        XCTAssertEqual(sut.title, MockEntries.ChildPane.title)
        XCTAssertEqual(sut.characteristic.fileName, MockEntries.ChildPane.fileName)
        XCTAssertFalse(sut.characteristic.entries.isEmpty)
        
        let characteristic = try XCTUnwrap(sut.characteristic.entries.first)
        XCTAssertEqual(characteristic.title, mockEntries.textField.title)
    }
    
    func test_decoding_from_data() throws {
        let data = try XCTUnwrap(mockEntries.childPaneData)
        let decoded = try JSONDecoder().decode(Specifier.ChildPane.self, from: data)
        
        XCTAssertEqual(decoded.title, sut.title)
        XCTAssertEqual(decoded.characteristic.fileName, sut.characteristic.fileName)
    }
}
