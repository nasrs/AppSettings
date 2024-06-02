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
    
    func testCharacteristicEquatable() throws {
        // Given
        let characteristic1 = Specifier.ChildPane.Characteristic(fileName: "test_file",
                                                                 entries: [mockEntries.textField])
        
        let characteristic2 = Specifier.ChildPane.Characteristic(fileName: "test_file",
                                                                 entries: [mockEntries.textField])

        let characteristic3 = Specifier.ChildPane.Characteristic(fileName: "different_test_file",
                                                                 entries: [mockEntries.textField])
        
        // Then
        XCTAssertEqual(characteristic1, characteristic2)
        XCTAssertNotEqual(characteristic1, characteristic3)
    }

    func testSpecifierEquatable() throws {
        // Given
        let characteristic = Specifier.ChildPane.Characteristic(fileName: "test_file",
                                                                entries: [mockEntries.textField])
        let childPaneId = UUID()
        let specifier1 = Specifier.ChildPane(id: childPaneId,
                                             title: "Child Pane",
                                             characteristic: characteristic)
        let specifier2 = Specifier.ChildPane(id: childPaneId,
                                             title: "Child Pane",
                                             characteristic: characteristic)
        let specifier3 = Specifier.ChildPane(title: "Another Child Pane",
                                             characteristic: characteristic)
        
        // Then
        XCTAssertEqual(specifier1, specifier2)
        XCTAssertNotEqual(specifier1, specifier3)
    }
}
