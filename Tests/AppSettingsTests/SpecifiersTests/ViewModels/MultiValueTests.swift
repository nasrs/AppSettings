// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import XCTest

final class MultiValueTests: XCTestCase {
    var sut: Specifier.MultiValue!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = mockEntries.multiValue
        XCTAssertNotNil(sut)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func test_storedContent_updatesStorable() throws {
        sut.characteristic.storedContent = sut.characteristic.defaultValue
        let specifierKey = try XCTUnwrap(sut.characteristic.key)
        let defaultValueStored = mockEntries.storable.object(forKey: specifierKey) as? String
        XCTAssertEqual(defaultValueStored, sut.characteristic.defaultValue)
        
        let valueToStore = try XCTUnwrap(sut.characteristic.values.last)
        sut.characteristic.storedContent = valueToStore
        
        XCTAssertEqual(mockEntries.storable.object(forKey: specifierKey) as? String,
                       valueToStore)
    }
    
    func test_multiValue_isValidAsExpected() throws {
        XCTAssertEqual(sut.type, .multiValue)
        XCTAssertEqual(sut.title, "MultiValue Title")
        XCTAssertTrue(sut.characteristic == mockEntries.multiValue.characteristic)
    }
    
    func test_decoding_from_data() throws {
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.storable
        let data = try XCTUnwrap(mockEntries.multiValueData)
        let decoded = try decoder.decode(Specifier.MultiValue.self, from: data)
        
        XCTAssertEqual(decoded.type, .multiValue)
        XCTAssertEqual(decoded.title, sut.title)
        XCTAssertEqual(decoded.characteristic, sut.characteristic)
    }
    
    func testMultiValueResetSpecifier() {
        // Given
        let characteristic = Specifier.MultiValue.Characteristic(
            key: "testKey",
            defaultValue: "defaultValue",
            titles: ["Option 1", "Option 2", "Option 3"],
            values: ["option_1", "option_2", "option_3"],
            container: mockEntries.storable
        )
        let multiValue = Specifier.MultiValue(
            title: "MultiValue Title",
            characteristic: characteristic
        )
        multiValue.characteristic.storedContent = "admin"
        XCTAssertEqual(multiValue.characteristic.storedContent, "admin")
        
        // When
        multiValue.resetSpecifier()
        
        // Then
        XCTAssertEqual(multiValue.characteristic.storedContent, multiValue.characteristic.defaultValue)
    }
    
    func testCharacteristicEquatable() throws {
        // Given
        let characteristic1 = Specifier.MultiValue.Characteristic(key: "testKey", defaultValue: "defaultValue", titles: ["Option 1", "Option 2", "Option 3"], values: ["option_1", "option_2", "option_3"])
        let characteristic2 = Specifier.MultiValue.Characteristic(key: "testKey", defaultValue: "defaultValue", titles: ["Option 1", "Option 2", "Option 3"], values: ["option_1", "option_2", "option_3"])
        let characteristic3 = Specifier.MultiValue.Characteristic(key: "differentTestKey", defaultValue: "defaultValue", titles: ["Option 1", "Option 2", "Option 3"], values: ["option_1", "option_2", "option_3"])
        // Then
        XCTAssertEqual(characteristic1, characteristic2)
        XCTAssertNotEqual(characteristic1, characteristic3)
    }

    func test_specifier_equatable() throws {
        // Given
        let characteristic = Specifier.MultiValue.Characteristic(key: "testKey", defaultValue: "defaultValue", titles: ["Option 1", "Option 2", "Option 3"], values: ["option_1", "option_2", "option_3"])
        let sliderId = UUID()
        let specifier1 = Specifier.MultiValue(id: sliderId,
                                              title: "slider title",
                                              characteristic: characteristic)
        let specifier2 = Specifier.MultiValue(id: sliderId,
                                              title: "slider title",
                                              characteristic: characteristic)
        let specifier3 = Specifier.MultiValue(
            title: "another slider title",
            characteristic: Specifier.MultiValue.Characteristic(
                key: "differentTestKey",
                defaultValue: "defaultValue",
                titles: ["Option 1", "Option 2", "Option 3"],
                values: ["option_1", "option_2", "option_3"]
            )
        )
        
        // Then
        XCTAssertEqual(specifier1, specifier2)
        XCTAssertNotEqual(specifier1, specifier3)
    }
    
    func test_shouldReset_whenTrue_shouldPreventStoredContentToResetForDefault() throws {
        // Given
        let multiValueData = """
        {
            "Key": "some_multivalue_key",
            "Title": "Multi Value Title",
            "Titles": ["value A", "value B"],
            "Values": ["val1", "val2"],
            "DefaultValue": "val1",
            "Restartable": false
        }
        """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.storable
        let data = try XCTUnwrap(multiValueData)
        let decoded = try decoder.decode(Specifier.MultiValue.self, from: data)
        
        XCTAssertEqual(decoded.specifierKey, "some_multivalue_key")
        XCTAssertEqual(decoded.title, "Multi Value Title")
        XCTAssertEqual(decoded.characteristic.defaultValue, "val1")
        XCTAssertEqual(decoded.shouldReset, false)
        
        decoded.characteristic.storedContent = "val2"
        XCTAssertEqual(decoded.characteristic.storedContent, "val2")
        
        // When
        decoded.resetSpecifier()
        
        // Then
        XCTAssertEqual(decoded.characteristic.storedContent, "val2")
    }
    
    func test_shouldReset_whenFalse_shouldResetStoredContentForDefault() throws {
        // Given
        let multiValueData = """
        {
            "Key": "some_multivalue_key",
            "Title": "Multi Value Title",
            "Titles": ["value A", "value B"],
            "Values": ["val1", "val2"],
            "DefaultValue": "val1",
            "Restartable": true
        }
        """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.storable
        let data = try XCTUnwrap(multiValueData)
        let decoded = try decoder.decode(Specifier.MultiValue.self, from: data)
        
        XCTAssertEqual(decoded.specifierKey, "some_multivalue_key")
        XCTAssertEqual(decoded.title, "Multi Value Title")
        XCTAssertEqual(decoded.characteristic.defaultValue, "val1")
        XCTAssertEqual(decoded.shouldReset, true)
        
        decoded.characteristic.storedContent = "val2"
        XCTAssertEqual(decoded.characteristic.storedContent, "val2")
        
        // When
        decoded.resetSpecifier()
        
        // Then
        XCTAssertEqual(decoded.characteristic.storedContent, decoded.characteristic.defaultValue)
    }
}
