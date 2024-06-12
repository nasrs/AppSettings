// Copyright © ICS 2024 from aiPhad.com

import XCTest
@testable import AppSettings

final class GroupTests: XCTestCase {
    var sut: Specifier.Group!
    
    override func setUp() {
        super.setUp()
        sut = mockEntries.group(with: [
            mockEntries.textField
        ])
    }
    
    override func tearDown() {
        sut.characteristic.entries.removeAll()
        sut = nil
        super.tearDown()
    }
    
    func testGroupInitialization() {
        XCTAssertEqual(sut.title, MockEntries.Group.title)
        XCTAssertNotNil(sut.characteristic)
        XCTAssertTrue(sut.specifierPath.isEmpty)
    }
    
    func testGroupEquality() {
        let otherGroup = Specifier.Group(
            id: mockEntries.group.id,
            title: MockEntries.Group.title,
            footerText: MockEntries.Group.footerText,
            characteristic: .init(entries: [
                mockEntries.textField
            ])
        )
        
        XCTAssertTrue(sut == otherGroup)
    }
    
    func testGroupHashValue() {
        let groupId = UUID()
        let group1 = Specifier.Group(
            id: groupId,
            title: "Some group title",
            footerText: "Some Group Footer Text",
            characteristic: .init(entries: [
                mockEntries.textField
            ])
        )
        
        let group2 = Specifier.Group(
            id: groupId,
            title: "Some group title",
            footerText: "Some Group Footer Text",
            characteristic: .init(entries: [
                mockEntries.textField
            ])
        )
        
        XCTAssertEqual(group1.hashValue,
                       group2.hashValue)
    }
    
    func testGroupDecoding() throws {
        let jsonData = try XCTUnwrap(mockEntries.groupData)
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
        let decodedGroup = try decoder.decode(Specifier.Group.self, from: jsonData)
        
        XCTAssertEqual(decodedGroup.title, MockEntries.Group.title)
        XCTAssertEqual(decodedGroup.footerText, MockEntries.Group.footerText)
        XCTAssertNotNil(decodedGroup.characteristic)
    }
    
    func testGroupCharacteristicEquality() {
        let textFieldId = UUID()
        let entry1 = Specifier.TextField(
            id: textFieldId,
            title: "Text field",
            characteristic: .init(
                key: "text_field_key",
                defaultValue: "some hint"
            )
        )

        let entry2 = Specifier.TextField(
            id: textFieldId,
            title: "Text field",
            characteristic: .init(
                key: "text_field_key",
                defaultValue: "some hint"
            )
        )
        
        let characteristic1 = Specifier.Group.Characteristic(entries: [entry1, entry2])
        let characteristic2 = Specifier.Group.Characteristic(entries: [entry1, entry2])
        
        XCTAssertEqual(characteristic1, characteristic2)
    }
    
    func testGroupCharacteristicInequality() {
        let characteristic = Specifier.MultiValue.Characteristic(
            key: "some_key",
            defaultValue: "default_1",
            titles: ["Default 1", "Default 2", "Default 3"],
            values: ["default_1", "default_2", "default_3"]
        )
        let entryId = UUID()
        let entry1 = Specifier.MultiValue(
            id: entryId,
            title: "Multi Value 1",
            characteristic: characteristic
        )
        let entry2 = Specifier.MultiValue(
            id: entryId,
            title: "Multi Value 2",
            characteristic: characteristic
        )
        let characteristic1 = Specifier.Group.Characteristic(entries: [entry1, entry2])
        let characteristic2 = Specifier.Group.Characteristic(entries: [entry2, entry1])
        
        XCTAssertNotEqual(characteristic1, characteristic2)
    }
}
