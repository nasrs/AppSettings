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
        let defaultValueStored = mockEntries.mockStorable.object(forKey: specifierKey) as? String
        XCTAssertEqual(defaultValueStored, sut.characteristic.defaultValue)
        
        let valueToStore = try XCTUnwrap(sut.characteristic.values.last)
        sut.characteristic.storedContent = valueToStore
        
        XCTAssertEqual(mockEntries.mockStorable.object(forKey: specifierKey) as? String,
                       valueToStore)
    }
    
    func test_multiValue_isValidAsExpected() throws {
        XCTAssertEqual(sut.type, .multiValue)
        XCTAssertEqual(sut.title, "MultiValue Title")
        XCTAssertTrue(sut.characteristic == mockEntries.multiValue.characteristic)
    }
    
    func test_decoding_from_data() throws {
        let decoder = JSONDecoder()
        decoder.userInfo[Specifier.repository] = MockEntries.shared.mockStorable
        let data = try XCTUnwrap(mockEntries.multiValueData)
        let decoded = try decoder.decode(Specifier.MultiValue.self, from: data)
        
        XCTAssertEqual(decoded.type, .multiValue)
        XCTAssertEqual(decoded.title, sut.title)
        XCTAssertEqual(decoded.characteristic, sut.characteristic)
    }
}
