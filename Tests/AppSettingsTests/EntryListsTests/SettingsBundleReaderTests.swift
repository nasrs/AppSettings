// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Foundation
import XCTest

final class SettingsBundleReaderTests: XCTestCase {
    var mockRepository: MockRepositoryStorable!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockRepositoryStorable()
    }

    override func tearDownWithError() throws {
        SettingsBundleReader.resetStatics()
        mockRepository = nil
        try super.tearDownWithError()
    }

    func testInitWithCustomParameters() async {
        // Given
        let exception = expectation(description: "Did finish setup with success")
        
        XCTAssertNil(SettingsBundleReader.shared)
        XCTAssertNil(SettingsBundleReader.didFinishInit)
        
        // When
        SettingsBundleReader.didFinishInit = { reader in
            XCTAssertNotNil(SettingsBundleReader.shared)
            XCTAssertEqual(reader.rootFileName, "CustomRoot")
            XCTAssertEqual(reader.bundleFileName, "CustomSettings")
            exception.fulfill()
        }
        
        await SettingsBundleReader(
            repository: mockRepository,
            bundle: Bundle.main,
            rootFileName: "CustomRoot",
            bundleFileName: "CustomSettings"
        )
        
        await fulfillment(of: [exception], timeout: 1.0)
    }

    func testInitUsesDefaultParameters() async throws {
        // Given
        let exception = expectation(description: "Did finish setup with success")
        XCTAssertNil(SettingsBundleReader.shared)
        XCTAssertNil(SettingsBundleReader.didFinishInit)
        
        // When
        SettingsBundleReader.didFinishInit = { reader in
            XCTAssertNotNil(SettingsBundleReader.shared)
            XCTAssertEqual(reader.rootFileName, "Root")
            XCTAssertEqual(reader.bundleFileName, "Settings")
            exception.fulfill()
        }
        
        // Then
        SettingsBundleReader.setup(
            repository: mockRepository
        )
        
        await fulfillment(of: [exception], timeout: 1.0)
    }
    
    func testUnwrappingResultsFromLocalPlist() async throws {
        // Given
        let exception = expectation(description: "Did finish setup with success")
        XCTAssertNil(SettingsBundleReader.shared)
        XCTAssertNil(SettingsBundleReader.didFinishInit)

        // When
        SettingsBundleReader.didFinishInit = { reader in
            XCTAssertNotNil(SettingsBundleReader.shared)
            XCTAssertEqual(reader.entries.count, 1)
            let group = reader.entries.first as? Specifier.Group
            XCTAssertNotNil(group)
            XCTAssertEqual(group?.characteristic.entries.count, 5)
            XCTAssertEqual(group?.title, "Some Title Text")
            XCTAssertEqual(group?.footerText, "Some Footer Text")
            
            XCTAssertEqual(reader.findable.count, group?.characteristic.entries.count)
            
            reader.findable.enumerated().forEach {
                let element = $0.element
                let index = $0.offset
                XCTAssertEqual(element.id, group?.characteristic.entries[index].id)
                XCTAssertEqual(element.type, group?.characteristic.entries[index].type)
                XCTAssertEqual(element.title, group?.characteristic.entries[index].title)
            }
            
            exception.fulfill()
        }
        
        // Then
        await SettingsBundleReader(
            repository: mockRepository,
            bundle: Bundle.module,
            rootFileName: "TestRoot",
            bundleFileName: .empty
        )
        
        await fulfillment(of: [exception], timeout: 1.0)
    }
}
