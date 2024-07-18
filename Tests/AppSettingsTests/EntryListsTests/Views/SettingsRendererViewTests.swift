// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import SwiftUI
import ViewInspector
import XCTest

final class SettingsRendererViewTests: XCTestCase {
    var sut: SettingsRendererView!
    var viewModel: SettingsRendererView.ViewModel!
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockEntries.reader.entries = [
            mockEntries.radio,
            mockEntries.multiValue,
            mockEntries.slider
        ]
        
        mockEntries.reader.findable = [
            mockEntries.radio,
            mockEntries.multiValue,
            mockEntries.slider
        ]
        
        viewModel = .init(mockEntries.reader)
    }
    
    override func tearDownWithError() throws {
        cancellable?.cancel()
        cancellable = nil
        viewModel = nil
        sut = nil
        mockEntries.reader.entries = []
        mockEntries.reader.findable = []
        try super.tearDownWithError()
    }
    
    func test_settingsRendererView_whenInitialized_shouldRenderCorrectly() {
        // given
        sut = .init(viewModel: viewModel)
        
        // when
        let expectation = sut.on(\.didAppear) { view in
            let settingsRendererView = try XCTUnwrap(view.actualView())
            
            let vstack = try XCTUnwrap(
                try settingsRendererView
                    .inspect()
                    .vStack(0)
            )
            
            // dragger is present
            let dragger = try XCTUnwrap(
                try vstack
                    .find(
                        ViewType.Image.self
                    )
            )
            
            XCTAssertEqual(try dragger.actualImage(), Image(systemName: "minus")
                .resizable())
            
            // Navigation is present and search empty
            let navigation = try XCTUnwrap(
                try vstack
                    .find(ViewType.NavigationView.self)
            )
            
            // tool bar items are present
            let toolbarItems = try XCTUnwrap(
                navigation.findAll(ViewType.Toolbar.Item.self)
            )
            
            XCTAssertEqual(toolbarItems.count, 2)
            
            let title = try XCTUnwrap(
                try toolbarItems.first?.text()
            )
            
            XCTAssertEqual(
                try title.string(),
                "Settings renderer"
            )
            
            let resetButton = try XCTUnwrap(
                try toolbarItems.last?.find(ViewType.Button.self)
            )
            
            XCTAssertEqual(
                try resetButton.labelView().text().string(),
                "Reset"
            )
            
            // reset button contains the expected identifier
            XCTAssertNoThrow(
                try settingsRendererView
                    .inspect()
                    .find(ViewType.Button.self,
                          accessibilityIdentifier: "reset_navigation_button")
            )
            
            let formView = try XCTUnwrap(
                try vstack.find(ViewType.Form.self)
            )
            
            // all entries are present
            let visibleEntries = try XCTUnwrap(
                formView.findAll(SettingsEntryView.self)
            )
            
            // all three entries present on viewModel are visible
            XCTAssertEqual(visibleEntries.count, 3)
        }
        
        // then
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_whenNoVisibleResults_shouldOnlyBePresentAnEmptyResultView() throws {
        // given
        mockEntries.reader.entries = []
        mockEntries.reader.findable = []
        viewModel = .init(mockEntries.reader)
        
        sut = .init(viewModel: viewModel)
        
        // when
        let expectation = sut.on(\.didAppear) { view in
            let settingRendererView = try XCTUnwrap(view.actualView())
            
            let navigationView = try XCTUnwrap(
                try settingRendererView
                    .inspect()
                    .find(ViewType.NavigationView.self)
            )
            
            XCTAssertThrowsError(
                try navigationView.find(ViewType.Form.self)
            )
            
            XCTAssertNoThrow(
                try navigationView.find(EmptySearchResultView.self)
            )
        }
        
        // then
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_whenResetButtonPressed_viewModelResetGetsTriggered() throws {
        // given
        let expectation = expectation(description: "View Model gets triggered for reseting entries")
        
        sut = .init(viewModel: viewModel)
        
        cancellable = mockEntries
            .reader
            .$resetTriggered
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
        
        sut.on(\.didAppear) { view in
            let settingsRendererView = try XCTUnwrap(view.actualView())
            
            let resetButton = try XCTUnwrap(
                try settingsRendererView
                    .inspect()
                    .find(ViewType.Button.self,
                          accessibilityIdentifier: "reset_navigation_button")
            )
            
            try resetButton.tap()
        }
        
        // then
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
}
