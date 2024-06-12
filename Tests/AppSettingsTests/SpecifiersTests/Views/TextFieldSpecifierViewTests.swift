// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import ViewInspector
import XCTest

final class TextFieldSpecifierViewTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    override func tearDownWithError() throws {
        cancellable?.cancel()
        cancellable = nil
        mockEntries.mockStorable.resetResults()
        try super.tearDownWithError()
    }
    
    func test_sut_initializer() {
        // Given
        let viewModel = Specifier.TextField(title: "Test Title",
                                            characteristic: .init(key: "test_key",
                                                                  defaultValue: "test_default_value"))
        let searchActive = true
    
        // When
        var sut = TextFieldSpecifierView(viewModel: viewModel, searchActive: searchActive)
        
        // Then
        let expectation = sut.on(\.didAppear) { view in
            let textView = try XCTUnwrap(view.actualView())
            
            XCTAssertEqual(textView.viewModel, viewModel)
            XCTAssertEqual(textView.id, viewModel.id)
            XCTAssertEqual(textView.contentBinding, viewModel.characteristic.storedContent)
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }

    func test_defaultContent_textField() {
        // Given
        let viewModel = Specifier.TextField(title: "Test Title",
                                            characteristic: .init(key: "test_key",
                                                                  defaultValue: "test_default_value"))
        let searchActive = true
        var sut = TextFieldSpecifierView(viewModel: viewModel, searchActive: searchActive)
        
        // When
        let expectation = sut.on(\.didAppear) { view in
            let textFieldSpecifier = try XCTUnwrap(view.actualView())
            let textField = try textFieldSpecifier.inspect().find(ViewType.TextField.self)
            XCTAssertEqual(try textField.accessibilityIdentifier(), viewModel.accessibilityIdentifier)
            let textFieldContent = try textField.labelView().text().string()
            
            // Then
            XCTAssertEqual(textFieldContent, viewModel.characteristic.defaultValue)
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_contentBinding_change_shouldPropagateToContainer() {
        // Given
        let expectation = expectation(description: "The content received should be the one set on didAppear closure")
        let viewModel = Specifier.TextField(title: "Test Title",
                                            characteristic: .init(key: "test_key",
                                                                  defaultValue: "test_default_value",
                                                                  container: mockEntries.mockStorable))
        let searchActive = true
        var sut = TextFieldSpecifierView(viewModel: viewModel, searchActive: searchActive)
        
        cancellable = mockEntries.mockStorable.$results.dropFirst().sink(receiveValue: { received in
            do {
                let receivedValue = try XCTUnwrap(received["test_key"] as? String)
                XCTAssertEqual(receivedValue, "the new content")
                expectation.fulfill()
            } catch {
                XCTFail("failed with error: \(error)")
            }
        })
        
        // When
        sut.on(\.didAppear) { view in
            let textFieldSpecifier = try XCTUnwrap(view.actualView())
            let textField = try textFieldSpecifier.inspect().find(ViewType.TextField.self)
            try textField.setInput("the new content")
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
}
