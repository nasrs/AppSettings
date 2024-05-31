// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import XCTest

final class MultiValueTests: XCTestCase {
    var sut: Specifier.MultiValue!
    var characteristic: Specifier.MultiValue.Characteristic!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        characteristic = .init(
            key: "multi_value_key",
            defaultValue: mockEntries.multiValue.characteristic.defaultValue,
            titles: mockEntries.multiValue.characteristic.titles,
            values: mockEntries.multiValue.characteristic.values,
            container: mockEntries.mockStorable
        )
        
        sut = .init(
            title: "multi value",
            characteristic: characteristic
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        characteristic = nil
    }
    
    func test_storedContent_updatesStorable() throws {
        let specifierKey = try XCTUnwrap(sut.characteristic.key)
        let defaultValueStored = mockEntries.mockStorable.object(forKey: specifierKey) as? String
        XCTAssertEqual(defaultValueStored, sut.characteristic.defaultValue)
        
        let valueToStore = try XCTUnwrap(sut.characteristic.values.last)
        sut.characteristic.storedContent = valueToStore
        
        XCTAssertEqual(mockEntries.mockStorable.object(forKey: specifierKey) as? String,
                       valueToStore)
    }
    
    func test_multiValue_isValidAsExpected() throws {
        XCTAssertEqual(sut.type, .multiValue)
        XCTAssertEqual(sut.title, "multi value")
        XCTAssertTrue(sut.characteristic == mockEntries.multiValue.characteristic)
        XCTAssertTrue(sut.characteristic.titles == mockEntries.multiValue.characteristic.titles)
        XCTAssertTrue(sut.characteristic.values == mockEntries.multiValue.characteristic.values)
    }
    
    func test_decoding_from_data() throws {
        let data = try XCTUnwrap(mockEntries.multiValueData)
        let decoded = try JSONDecoder().decode(Specifier.MultiValue.self, from: data)
        
        XCTAssertEqual(decoded.title, sut.title)
        XCTAssertEqual(decoded.characteristic.key, sut.characteristic.key)
        XCTAssertEqual(decoded.characteristic.defaultValue, sut.characteristic.defaultValue)
        XCTAssertEqual(decoded.characteristic.titles, sut.characteristic.titles)
        XCTAssertEqual(decoded.characteristic.values, sut.characteristic.values)
    }
}
