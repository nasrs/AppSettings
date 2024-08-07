// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import SwiftUI
import ViewInspector
import XCTest

final class InnerSettingsListViewModelTests: XCTestCase {
    var entries: [any SettingEntry]!
    var findable: [any SettingSearchable]!
    var sut: InnerSettingsListView.ViewModel!
    
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let innerEntries: [any SettingEntry] = [
            mockEntries.radio,
            mockEntries.multiValue,
            mockEntries.slider
        ]
        
        entries =  [
            mockEntries.childPane(with: innerEntries),
        ]
        
        findable = [
            mockEntries.radio,
            mockEntries.multiValue,
            mockEntries.slider
        ]
        
        sut = .init(entries: entries,
                    findable: findable)
    }

    override func tearDownWithError() throws {
        cancellable?.cancel()
        cancellable = nil
        sut = nil
        entries = nil
        findable = nil
        mockEntries.storable.resetResults()
        mockEntries.reader.resetAllEntries()
        try super.tearDownWithError()
    }
    
    func test_visibleEntries_whenNoSearchString_shouldReturnAllEntries() {
        // given
        let expectation = expectation(description: "All results are returned")
        
        // when
        let expectedCount = entries.count
        let searchString = ""
        
        // then
        cancellable = sut.$visibleEntries.dropFirst().sink(receiveValue: { result in
            XCTAssertEqual(result.count, expectedCount)
            expectation.fulfill()
        })
        
        sut.searchText = searchString
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_visibleEntries_whenSearchingStringIsOnlyPresentOnTwoObjects_shouldBeReturnedTwoObjects() {
        // given
        let expectation = expectation(description: "Only 2 values are returned")
        
        // when
        let expectedCount = 2
        // only 2 values contain the word title on its "tile" or "key"
        let searchString = "title"
        
        // then
        cancellable = sut.$visibleEntries.dropFirst().sink(receiveValue: { result in
            XCTAssertEqual(result.count, expectedCount)
            expectation.fulfill()
        })
        
        sut.searchText = searchString
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_visibleEntries_whenSearchingTextIsPresentOnAllSpecifiers_shouldReturnedAllEntries() {
        // given
        let expectation = expectation(description: "All values are returned")
        
        // when
        let expectedCount = 3
        let searchString = "key"
        
        // then
        cancellable = sut.$visibleEntries.dropFirst().sink(receiveValue: { result in
            XCTAssertEqual(result.count, expectedCount)
            expectation.fulfill()
        })
        
        sut.searchText = searchString
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_visibleEntries_whenSearchingBySpecifierKey_shouldReturnedOneSpecifier() {
        // given
        let expectation = expectation(description: "Only 1 entry is expecte to be returned")
        
        // when
        let expectedCount = 1
        let searchString = MockEntries.MultiValue.key
        
        // then
        cancellable = sut.$visibleEntries.dropFirst().sink(receiveValue: { result in
            XCTAssertEqual(result.count, expectedCount)
            expectation.fulfill()
        })
        
        sut.searchText = searchString
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_visibleEntries_whenSearchingBySpecifierTitle_shouldReturnedOneSpecifier() {
        // given
        let expectation = expectation(description: "All values are returned, the search string should be empty")
        
        // when
        let expectedCount = 1
        let searchString = MockEntries.Radio.title
        
        // then
        cancellable = sut.$visibleEntries.dropFirst().sink(receiveValue: { result in
            XCTAssertEqual(result.count, expectedCount)
            expectation.fulfill()
        })
        
        sut.searchText = searchString
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_isSearching_whenSearchTextChanges_shouldReturnTrueOnlyWhenSearchTextGreatherThan4Chars() {
        // given
        let expectation = expectation(description: "For searches with content < 3 is searching should be false")
        
        // when
        let searchString = "abckjsahi"
        expectation.expectedFulfillmentCount = searchString.count
        
        // then
        sut.searchText = .empty
        XCTAssertFalse(sut.isSearching)
        
        searchString.forEach { char in
            let textToSearch = sut.searchText + "\(char)"
            sut.searchText = textToSearch
            if textToSearch.count < 4 {
                XCTAssertFalse(sut.isSearching)
            } else {
                XCTAssertTrue(sut.isSearching)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 100)
    }
}
