// Copyright © ICS 2024 from aiPhad.com

import XCTest
@testable import AppSettings

final class ToggleSwitchTests: XCTestCase {
    var sut: Specifier.ToggleSwitch!
    
    override func setUp() {
        super.setUp()
        sut = mockEntries.toggleSwitch
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testToggleSwitchInitialization() {
        XCTAssertEqual(sut.title, MockEntries.ToggleSwitch.title)
        XCTAssertEqual(sut.characteristic.key, MockEntries.ToggleSwitch.key)
        XCTAssertEqual(sut.characteristic.defaultValue, MockEntries.ToggleSwitch.defaultValue)
    }
    
    func testToggleSwitchDecoding() throws {
        // Given
        let data = try XCTUnwrap(mockEntries.toggleSwitchData)
        sut = mockEntries.toggleSwitch
        
        // When
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.storable
        let decoded = try decoder.decode(Specifier.ToggleSwitch.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.title, sut.title)
        XCTAssertEqual(decoded.characteristic, sut.characteristic)
    }
    
    func testToggleSwitchResetSpecifier() {
        sut.characteristic.storedContent = false
        XCTAssertEqual(sut.characteristic.storedContent, false)
        
        sut.resetSpecifier()
        
        XCTAssertEqual(sut.characteristic.storedContent,
                       MockEntries.ToggleSwitch.defaultValue)
    }
    
    func testToggleSwitchEquatable() {
        let toggleId = UUID()
        let characteristic1 = Specifier.ToggleSwitch.Characteristic(
            key: "key1",
            defaultValue: true
        )
        let toggleSwitch1 = Specifier.ToggleSwitch(
            id: toggleId,
            title: "Toggle Switch",
            characteristic: characteristic1
                
        )
        
        let characteristic2 = Specifier.ToggleSwitch.Characteristic(
            key: "key1",
            defaultValue: true
        )
        let toggleSwitch2 = Specifier.ToggleSwitch(
            id: toggleId,
            title: "Toggle Switch",
            characteristic: characteristic2
        )
        
        let characteristic3 = Specifier.ToggleSwitch.Characteristic(
            key: "key2",
            defaultValue: false
        )
        let toggleSwitch3 = Specifier.ToggleSwitch(
            title: "Toggle Switch 2",
            characteristic: characteristic3
        )
        
        XCTAssertEqual(toggleSwitch1, toggleSwitch2)
        XCTAssertNotEqual(toggleSwitch1, toggleSwitch3)
    }
    
    func testToggleSwitchHashable() {
        let toggleId = UUID()
        let toggleSwitch1 = Specifier.ToggleSwitch(
            id: toggleId,
            title: "Toggle Switch 1",
            characteristic:
                Specifier.ToggleSwitch.Characteristic(
                    key: "key1",
                    defaultValue: true
                )
        )
        let toggleSwitch2 = Specifier.ToggleSwitch(
            id: toggleId,
            title: "Toggle Switch 2",
            characteristic:
                Specifier.ToggleSwitch.Characteristic(
                    key: "key1",
                    defaultValue: true
                )
        )
        
        XCTAssertEqual(toggleSwitch1.hashValue, toggleSwitch2.hashValue)
    }
    
    func test_shouldReset_whenTrue_shouldPreventStoredContentToResetForDefault() throws {
        // Given
        let toggleSwitchData =  """
        {
            "Title": "Toggle Switch Title",
            "Key": "toggle_switch_key",
            "DefaultValue": true,
            "Restartable": false
        }
        """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.storable
        let data = try XCTUnwrap(toggleSwitchData)
        let decoded = try decoder.decode(Specifier.ToggleSwitch.self, from: data)
        
        XCTAssertEqual(decoded.specifierKey, "toggle_switch_key")
        XCTAssertEqual(decoded.title, "Toggle Switch Title")
        XCTAssertEqual(decoded.characteristic.defaultValue, true)
        XCTAssertEqual(decoded.shouldReset, false)
        
        decoded.characteristic.storedContent = false
        XCTAssertEqual(decoded.characteristic.storedContent, false)
        
        // When
        decoded.resetSpecifier()
        
        // Then
        XCTAssertEqual(decoded.characteristic.storedContent, false)
    }

    func test_shouldReset_whenFalse_shouldResetStoredContentForDefault() throws {
        // Given
        let toggleSwitchData =  """
        {
            "Title": "Toggle Switch Title",
            "Key": "toggle_switch_key",
            "DefaultValue": true,
            "Restartable": true
        }
        """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.storable
        let data = try XCTUnwrap(toggleSwitchData)
        let decoded = try decoder.decode(Specifier.ToggleSwitch.self, from: data)
        
        XCTAssertEqual(decoded.specifierKey, "toggle_switch_key")
        XCTAssertEqual(decoded.title, "Toggle Switch Title")
        XCTAssertEqual(decoded.characteristic.defaultValue, true)
        XCTAssertEqual(decoded.shouldReset, true)
        
        decoded.characteristic.storedContent = false
        XCTAssertEqual(decoded.characteristic.storedContent, false)
        
        // When
        decoded.resetSpecifier()
        
        // Then
        XCTAssertEqual(decoded.characteristic.storedContent, true)
    }
}
