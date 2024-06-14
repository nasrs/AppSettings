import XCTest
@testable import AppSettings

class RadioTests: XCTestCase {
    var sut: Specifier.Radio!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = mockEntries.radio
        XCTAssertNotNil(sut)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func testRadioInitialization() {
        // Given
        let title = "Radio Option"
        let footerText = "Footer Text"
        let characteristic: Specifier.Radio.Characteristic = .init(
            key: "radio_example_key",
            defaultValue: "option_1",
            titles: ["Option 1", "Option 2", "Option 3"],
            values: ["option_1", "option_2", "option_3"]
        )
        
        // When
        let radio = Specifier.Radio(
            title: title,
            footerText: footerText,
            characteristic: characteristic
        )
        
        // Then
        XCTAssertEqual(radio.title, title)
        XCTAssertEqual(radio.footerText, footerText)
        XCTAssertEqual(radio.characteristic, characteristic)
    }
    
    func test_storedContent_updatesStorable() throws {
        sut.characteristic.storedContent = sut.characteristic.defaultValue
        let specifierKey = try XCTUnwrap(sut.characteristic.key)
        let defaultValueStored = mockEntries.mockStorable.object(forKey: specifierKey) as? String
        XCTAssertEqual(defaultValueStored, sut.characteristic.defaultValue)
        
        let valueToStore = try XCTUnwrap(sut.characteristic.values.last)
        sut.characteristic.storedContent = valueToStore
        
        let valueExpected = try XCTUnwrap(mockEntries.mockStorable.object(forKey: specifierKey) as? String)
        XCTAssertEqual(valueExpected, valueToStore)
    }
    
    func test_decoding_from_data() throws {
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
        let data = try XCTUnwrap(mockEntries.radioData)
        let decoded = try decoder.decode(Specifier.Radio.self, from: data)
        
        XCTAssertEqual(decoded.type, .radio)
        XCTAssertEqual(decoded.title, sut.title)
        XCTAssertEqual(decoded.footerText, sut.footerText)
        XCTAssertEqual(decoded.accessibilityIdentifier, sut.accessibilityIdentifier)
        XCTAssertEqual(decoded.characteristic, sut.characteristic)
    }
    
    func testRadioResetSpecifier() {
        // Given
        let characteristic = Specifier.Radio.Characteristic(
            key: "testKey",
            defaultValue: "option_1",
            titles: ["Option 1", "Option 2", "Option 3"],
            values: ["option_1", "option_2", "option_3"],
            container: mockEntries.mockStorable
        )
        let radio = Specifier.Radio(
            title: "Radio Option",
            characteristic: characteristic
        )
        radio.characteristic.storedContent = "option_2"
        XCTAssertEqual(radio.characteristic.storedContent, "option_2")
        
        // When
        radio.resetSpecifier()
        
        // Then
        XCTAssertEqual(radio.characteristic.storedContent, radio.characteristic.defaultValue)
    }
    
    func testCharacteristicEquatable() throws {
        // Given
        let characteristic1 = Specifier.Radio.Characteristic(key: "testKey",
                                                             defaultValue: "abc",
                                                             titles: ["ABC", "DEF", "GHI"],
                                                             values: ["abc", "def", "ghi"])
        
        let characteristic2 = Specifier.Radio.Characteristic(key: "testKey", 
                                                             defaultValue: "abc",
                                                             titles: ["ABC", "DEF", "GHI"],
                                                             values: ["abc", "def", "ghi"])
        
        let characteristic3 = Specifier.Radio.Characteristic(key: "differentKey",  
                                                             defaultValue: "abc",
                                                             titles: ["ABC", "DEF", "GHI"],
                                                             values: ["abc", "def", "ghi"])
        
        // Then
        XCTAssertEqual(characteristic1, characteristic2)
        XCTAssertNotEqual(characteristic1, characteristic3)
    }

    func testSpecifierEquatable() throws {
        // Given
        let characteristic = Specifier.Radio.Characteristic(key: "testKey",
                                                            defaultValue: "abc",
                                                            titles: ["ABC", "DEF", "GHI"],
                                                            values: ["abc", "def", "ghi"])
        let radioId = UUID()
        let specifier1 = Specifier.Radio(id: radioId,
                                         title: "Radio Option",
                                         characteristic: characteristic)
        let specifier2 = Specifier.Radio(id: radioId,
                                         title: "Radio Option",
                                         characteristic: characteristic)
        let specifier3 = Specifier.Radio(title: "Another Radio Option",
                                         characteristic:
                                            Specifier.Radio.Characteristic(key: "differentKey",
                                                                           defaultValue: "abc",
                                                                           titles: ["ABC", "DEF", "GHI"],
                                                                           values: ["abc", "def", "ghi"])
        )
        
        // Then
        XCTAssertEqual(specifier1, specifier2)
        XCTAssertNotEqual(specifier1, specifier3)
    }
    
    func test_shouldReset_whenTrue_shouldPreventStoredContentToResetForDefault() throws {
        // Given
        let radioData =  """
        {
            "Key": "radio_key",
            "Title": "Radio Title",
            "FooterText": "Footer Text",
            "Titles": ["value A", "value B"],
            "Values": ["val1", "val2"],
            "DefaultValue": "val2",
            "Restartable": false
        }
        """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
        let data = try XCTUnwrap(radioData)
        let decoded = try decoder.decode(Specifier.Radio.self, from: data)
        
        XCTAssertEqual(decoded.specifierKey, "radio_key")
        XCTAssertEqual(decoded.title, "Radio Title")
        XCTAssertEqual(decoded.characteristic.defaultValue, "val2")
        XCTAssertEqual(decoded.shouldReset, false)
        
        decoded.characteristic.storedContent = "val1"
        XCTAssertEqual(decoded.characteristic.storedContent, "val1")
        
        // When
        decoded.resetSpecifier()
        
        // Then
        XCTAssertEqual(decoded.characteristic.storedContent, "val1")
    }

    func test_shouldReset_whenFalse_shouldResetStoredContentForDefault() throws {
        // Given
        let radioData =  """
        {
            "Key": "radio_key",
            "Title": "Radio Title",
            "FooterText": "Footer Text",
            "Titles": ["value A", "value B"],
            "Values": ["val1", "val2"],
            "DefaultValue": "val2",
            "Restartable": true
        }
        """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
        let data = try XCTUnwrap(radioData)
        let decoded = try decoder.decode(Specifier.Radio.self, from: data)
        
        XCTAssertEqual(decoded.specifierKey, "radio_key")
        XCTAssertEqual(decoded.title, "Radio Title")
        XCTAssertEqual(decoded.characteristic.defaultValue, "val2")
        XCTAssertEqual(decoded.shouldReset, true)
        
        decoded.characteristic.storedContent = "val1"
        XCTAssertEqual(decoded.characteristic.storedContent, "val1")
        
        // When
        decoded.resetSpecifier()
        
        // Then
        XCTAssertEqual(decoded.characteristic.storedContent, decoded.characteristic.defaultValue)
    }
}
