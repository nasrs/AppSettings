// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import XCTest

final class TextFieldTests: XCTestCase {
    var sut: Specifier.TextField!
    
    func testTextFieldInitialization() {
        // Given
        let title = "Username"
        let characteristic = Specifier.TextField.Characteristic(
            key: "username",
            defaultValue: "some hint text"
        )
        
        // When
        let textField = Specifier.TextField(title: title, 
                                            characteristic: characteristic)
        
        // Then
        XCTAssertEqual(textField.title, title)
        XCTAssertEqual(textField.characteristic, characteristic)
        XCTAssertEqual(textField.accessibilityIdentifier, "\(characteristic.key)_textfield")
    }

    func testTextFieldDecoding() throws {
        // Given
        let json = try XCTUnwrap(mockEntries.textFieldData)
        
        // When
        let decoder = JSONDecoder()
        decoder.userInfo = [Specifier.repository: mockEntries.mockStorable]
        let textField = try decoder.decode(Specifier.TextField.self, from: json)
        
        // Then
        XCTAssertEqual(textField.title, MockEntries.TextField.title)
        XCTAssertEqual(textField.characteristic.key, MockEntries.TextField.key)
        XCTAssertEqual(textField.characteristic.defaultValue, MockEntries.TextField.defaultValue)
        XCTAssertEqual(textField.characteristic.keyboard, MockEntries.TextField.keyboardType)
        XCTAssertEqual(textField.characteristic.isSecure, MockEntries.TextField.isSecure)
    }

    func testTextFieldResetSpecifier() {
        // Given
        let characteristic = Specifier.TextField.Characteristic(
            key: "username",
            defaultValue: "guest",
            container: mockEntries.mockStorable
        )
        let textField = Specifier.TextField(
            title: "Username",
            characteristic: characteristic
        )
        textField.characteristic.storedContent = "admin"
        XCTAssertEqual(textField.characteristic.storedContent, "admin")
        
        // When
        textField.resetSpecifier()
        
        // Then
        XCTAssertEqual(textField.characteristic.storedContent, textField.characteristic.defaultValue)
    }

    func testTextFieldEquatable() {
        // Given
        let textFieldId = UUID()
        let characteristic1 = Specifier.TextField.Characteristic(
            key: MockEntries.TextField.key,
            defaultValue: MockEntries.TextField.defaultValue
        )
        let textField1 = Specifier.TextField(
            id: textFieldId,
            title: MockEntries.TextField.title,
            characteristic: characteristic1
        )
        
        let characteristic2 = Specifier.TextField.Characteristic(
            key: MockEntries.TextField.key,
            defaultValue: MockEntries.TextField.defaultValue
        )
        let textField2 = Specifier.TextField(
            id: textFieldId,
            title: MockEntries.TextField.title,
            characteristic: characteristic2
        )
        
        let characteristic3 = Specifier.TextField.Characteristic(
            key: "password",
            defaultValue: nil
        )
        let textField3 = Specifier.TextField(
            title: "Password",
            characteristic: characteristic3
        )
        
        // Then
        XCTAssertEqual(textField1, textField2)
        XCTAssertNotEqual(textField1, textField3)
    }

    func testTextFieldHashable() {
        // Given
        let characteristic = Specifier.TextField.Characteristic(key: "username", defaultValue: nil)
        let textField = Specifier.TextField(title: "Username", characteristic: characteristic)
        
        // When
        let hashValue = textField.hashValue
        
        // Then
        XCTAssertNotNil(hashValue)
    }
}
