// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import SwiftUI
import ViewInspector
import XCTest

final class RadioSpecifierViewTests: XCTestCase {
    var viewModel: Specifier.Radio!
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        viewModel = Specifier.Radio(
            title: "Radio Button",
            footerText: "Footer text",
            characteristic: .init(key: "user_defaults_key",
                                  defaultValue: "test_3",
                                  titles: [
                                    "test 1",
                                    "test 2",
                                    "test 3",
                                  ],
                                  values: [
                                    "test_1",
                                    "test_2",
                                    "test_3",
                                  ],
                                  container: mockEntries.mockStorable)
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellable = nil
        mockEntries.mockStorable.resetResults()
        try super.tearDownWithError()
    }
    
    func test_headerAndFooter_areVisible() throws {
        // Given
        let expectedTitle = viewModel.title
        let expectedFooter = try XCTUnwrap(viewModel.footerText)
        
        var radioSpecifier = RadioSpecifierView(viewModel: viewModel, searchActive: false)
        
        let expectation = radioSpecifier.on(\.didAppear) { view in
            let radioView = try XCTUnwrap(view.actualView())
            
            let entry = try radioView.inspect().find(ViewType.Section.self)
            XCTAssertNoThrow(
                try entry.header().find(text: expectedTitle)
            )
            
            XCTAssertNoThrow(
                try entry.footer().find(text: expectedFooter)
            )
            
            XCTAssertEqual(radioView.selected, "test 3")
        }
        
        ViewHosting.host(view: radioSpecifier)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_allViewModelEntries_arePresent() {
        // Given
        let expectedTitles = viewModel.characteristic.titles
        
        var radioSpecifier = RadioSpecifierView(viewModel: viewModel, searchActive: false)
        
        let expectation = radioSpecifier.on(\.didAppear) { view in
            let radioView = try XCTUnwrap(view.actualView())
            
            try expectedTitles.forEach { title in
                let entry = try radioView.inspect().find(text: title)
                XCTAssertNotNil(entry)
            }
        }
        
        ViewHosting.host(view:         radioSpecifier)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_selected_value() throws {
        let expectation = expectation(description: "RadioOption should update and propagate result to RepositoryStorable")
        
        var radioSpecifier = RadioSpecifierView(viewModel: viewModel, searchActive: false)
        
        cancellable = mockEntries.mockStorable.$results.dropFirst().sink(receiveValue: { received in
            do {
                let receivedValue = try XCTUnwrap(received["user_defaults_key"] as? String)
                XCTAssertEqual(receivedValue, "test_2")
                expectation.fulfill()
            } catch {
                XCTFail("failed with error: \(error)")
            }
        })
        
        radioSpecifier.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            let radioView = try XCTUnwrap(view.actualView())
            let accIdentifier = viewModel.accessibilityIdentifier + "_1"
            XCTAssertEqual(radioView.selected, "test 3")
            let radioOption = try radioView.inspect().find(viewWithAccessibilityIdentifier: accIdentifier)
            try? radioOption.callOnTapGesture()
        }
        
        ViewHosting.host(view: radioSpecifier)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_selected_whenDefaultInvalidOnViewModel_shouldFallbackForFirstTitle() throws {
        let mockVM = Specifier.Radio(
            title: "Radio Button",
            footerText: "Footer text",
            characteristic: .init(key: "user_defaults_key",
                                  defaultValue: "test_4",
                                  titles: [
                                    "test 1",
                                    "test 2",
                                    "test 3"
                                  ],
                                  values: [
                                    "test_1",
                                    "test_2",
                                    "test_3"
                                  ])
        )
        
        var radioSpecifier = RadioSpecifierView(viewModel: mockVM, searchActive: false)
        
        let expectation = radioSpecifier.on(\.didAppear) { view in
            let radioView = try XCTUnwrap(view.actualView())
            XCTAssertEqual(radioView.selected, "test 1")
        }
        
        ViewHosting.host(view: radioSpecifier)
        
        wait(for: [expectation], timeout: 1)
        
    }
}
