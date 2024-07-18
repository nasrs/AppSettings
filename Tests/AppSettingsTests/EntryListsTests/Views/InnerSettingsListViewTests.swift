// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import SwiftUI
import ViewInspector
import XCTest

final class InnerSettingsListViewTests: XCTestCase {
    var entries: [any SettingEntry]!
    var searchable: SearchableEntries!
    var sut: InnerSettingsListView!
    
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        entries = [
            mockEntries.radio,
            mockEntries.multiValue,
            mockEntries.slider
        ]
        
        searchable = .init(
            [
                mockEntries.radio,
                mockEntries.multiValue,
                mockEntries.slider
            ]
        )
    }
    
    override func tearDownWithError() throws {
        cancellable?.cancel()
        cancellable = nil
        sut = nil
        entries = nil
        searchable = nil
        try super.tearDownWithError()
    }
    
    func test_settingsRendererView_whenInitialized_shouldRenderCorrectly() {
        // Given
        let expectedTitle = "Expected title"
        
        // When
        sut = .init(entries: entries,
                    title: expectedTitle)
        
        let expectation = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            let innerListView = try XCTUnwrap(view.actualView())
            
            let form = try innerListView.inspect().form()
            
            let settingEntries = form.findAll(SettingsEntryView.self)
            XCTAssertEqual(settingEntries.count, entries.count)
            
            XCTAssertEqual(innerListView.title, expectedTitle)
        }
        
        let sutContainer = ZStack {
            sut
        }.environmentObject(searchable)
        
        // Then
        ViewHosting.host(view: sutContainer)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_whenNoVisibleResults_shouldOnlyBePresentAnEmptyResultView() throws {
        // Given
        entries = []
        searchable = .init([])
        
        // When
        sut = .init(entries: entries,
                    title: "expected title")
        
        let expectation = sut.on(\.didAppear) { view in
            let innerListView = try XCTUnwrap(view.actualView())
            
            XCTAssertThrowsError(
                try innerListView.inspect().form()
            )
            
            XCTAssertNoThrow(
                try innerListView.inspect().find(EmptySearchResultView.self)
            )
        }
        
        let sutContainer = ZStack {
            sut
        }.environmentObject(searchable)
        
        // Then
        
        ViewHosting.host(view: sutContainer)
        
        wait(for: [expectation], timeout: 1)
    }
}
