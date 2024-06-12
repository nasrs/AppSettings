// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import ViewInspector
import XCTest
import SwiftUI

final class ToggleSpecifierViewTests: XCTestCase {
    var viewModel: Specifier.ToggleSwitch!
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        viewModel = mockEntries.toggleSwitch
    }
    
    override func tearDownWithError() throws {
        cancellable?.cancel()
        cancellable = nil
        viewModel = nil
        mockEntries.mockStorable.resetResults()
        try super.tearDownWithError()
    }
    
    func test_ToggleSpecifierViewInit() {
        var toggleView = ToggleSpecifierView(viewModel: viewModel,
                                             searchActive: false)
        
        let expectation = toggleView.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            let toggleSpecifier = try XCTUnwrap(view.actualView())
            XCTAssertEqual(toggleSpecifier.viewModel, viewModel)
            XCTAssertEqual(toggleSpecifier.id, viewModel.id)
            XCTAssertEqual(toggleSpecifier.selected, viewModel.characteristic.defaultValue)
            
            let textString = try toggleSpecifier.inspect().find(ViewType.Text.self).string()
            XCTAssertEqual(textString, viewModel.title)
            
            let toggle = try toggleSpecifier.inspect().find(ViewType.Toggle.self)
            XCTAssertEqual(try toggle.isOn(), viewModel.characteristic.defaultValue)
        }
        
        ViewHosting.host(view: toggleView)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testToggleSwitchValueUpdatesCorrectly() throws {
        let expectation = expectation(description: "Toggle should update and propagate result to RepositoryStorable")
        
        var toggleView = ToggleSpecifierView(viewModel: viewModel,
                                             searchActive: false)
        let expectedValue = !viewModel.characteristic.defaultValue
        
        cancellable = mockEntries.mockStorable.$results.dropFirst().sink(receiveValue: { received in
            do {
                let receivedValue = try XCTUnwrap(received[MockEntries.ToggleSwitch.key] as? Bool)
                XCTAssertEqual(receivedValue, expectedValue)
                expectation.fulfill()
            } catch {
                XCTFail("failed with error: \(error)")
            }
        })
        
        toggleView.on(\.didAppear) { view in
            let toggleView = try XCTUnwrap(view.actualView())
            let toggle = try toggleView.inspect().find(ViewType.Toggle.self)
            try toggle.tap()
        }
        
        ViewHosting.host(view: toggleView)
        
        wait(for: [expectation], timeout: 10000)
    }
    
    func testToggleSwitchAccessibilityIdentifier() throws {
        let toggleView = ToggleSpecifierView(viewModel: viewModel,
                                             searchActive: false)
        
        let entry = try toggleView.inspect().find(ViewType.Toggle.self)
        XCTAssertEqual(try entry.accessibilityIdentifier(), viewModel.accessibilityIdentifier)
    }
}
