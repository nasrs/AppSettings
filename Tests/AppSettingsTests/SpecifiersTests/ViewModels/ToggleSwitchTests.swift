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
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
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
        
        var hasher1 = Hasher()
        toggleSwitch1.hash(into: &hasher1)
        
        var hasher2 = Hasher()
        toggleSwitch2.hash(into: &hasher2)
        
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }
}
