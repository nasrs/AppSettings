// Copyright © ICS 2024 from aiPhad.com

import XCTest
@testable import AppSettings

final class SliderTests: XCTestCase {
    func testInitialization() throws {
        // Given
        let characteristic = Specifier.Slider.Characteristic(key: "testKey", defaultValue: 0, minValue: 0, maxValue: 100)
        
        // When
        let slider = Specifier.Slider(characteristic: characteristic)
        
        // Then
        XCTAssertEqual(slider.type, .slider)
        XCTAssertTrue(slider.title.isEmpty)
        XCTAssertEqual(slider.characteristic, characteristic)
        XCTAssertEqual(slider.accessibilityIdentifier, "\(characteristic.key)_slider")
        XCTAssertEqual(slider.specifierPath, "")
        XCTAssertEqual(slider.specifierKey, characteristic.key)
    }

    func testDecoding() throws {
        // Given
        let jsonData = try XCTUnwrap(mockEntries.sliderData)
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
        
        // When
        let slider = try decoder.decode(Specifier.Slider.self,
                                        from: jsonData)
        
        // Then
        XCTAssertEqual(slider.characteristic.key, MockEntries.Slider.key)
        XCTAssertEqual(slider.characteristic.defaultValue, MockEntries.Slider.defaultValue)
        XCTAssertEqual(slider.characteristic.minValue, MockEntries.Slider.minimumValue)
        XCTAssertEqual(slider.characteristic.maxValue, MockEntries.Slider.maximumValue)
    }

    func testResetSliderSpecifier() throws {
        // Given
        let characteristic = Specifier.Slider.Characteristic(
            key: "testKey",
            defaultValue: 0,
            minValue: 0,
            maxValue: 100,
            container: mockEntries.mockStorable
        )
        let slider = Specifier.Slider(characteristic: characteristic)
        slider.characteristic.storedContent = 50
        XCTAssertEqual(slider.characteristic.storedContent, 50)
        
        // When
        slider.resetSpecifier()
        
        // Then
        XCTAssertEqual(slider.characteristic.storedContent, slider.characteristic.defaultValue)
    }

    func testCharacteristicEquatable() throws {
        // Given
        let characteristic1 = Specifier.Slider.Characteristic(key: "testKey", defaultValue: 0, minValue: 0, maxValue: 100)
        let characteristic2 = Specifier.Slider.Characteristic(key: "testKey", defaultValue: 0, minValue: 0, maxValue: 100)
        let characteristic3 = Specifier.Slider.Characteristic(key: "differentKey", defaultValue: 0, minValue: 0, maxValue: 100)
        
        // Then
        XCTAssertEqual(characteristic1, characteristic2)
        XCTAssertNotEqual(characteristic1, characteristic3)
    }

    func testSpecifierEquatable() throws {
        // Given
        let characteristic = Specifier.Slider.Characteristic(key: "testKey", defaultValue: 0, minValue: 0, maxValue: 100)
        let sliderId = UUID()
        let specifier1 = Specifier.Slider(id: sliderId, 
                                          characteristic: characteristic)
        let specifier2 = Specifier.Slider(id: sliderId,
                                          characteristic: characteristic)
        let specifier3 = Specifier.Slider(characteristic: Specifier.Slider.Characteristic(key: "differentKey", defaultValue: 0, minValue: 0, maxValue: 100))
        
        // Then
        XCTAssertEqual(specifier1, specifier2)
        XCTAssertNotEqual(specifier1, specifier3)
    }
}
