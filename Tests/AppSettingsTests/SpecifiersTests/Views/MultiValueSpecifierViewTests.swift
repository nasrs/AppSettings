// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import ViewInspector
import XCTest

final class MultiValueSpecifierViewTests: XCTestCase {
    var viewModel: Specifier.MultiValue!
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = mockEntries.multiValue
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        cancellable?.cancel()
        cancellable = nil
        mockEntries.mockStorable.resetResults()
        try super.tearDownWithError()
    }
    
    func testViewModelInitialization() {
        var specifier = MultiValueSpecifierView(
            viewModel: viewModel,
            searchActive: false
        )
        
        let expectation = specifier.on(\.didAppear) { view in
            let unwrapped = try view.actualView()
            XCTAssertEqual(unwrapped.selected, "Option 3")
        }
        
        ViewHosting.host(view: specifier)
        XCTAssertEqual(specifier.viewModel, viewModel)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_header_isVisible() throws {
        // Given
        let expectedTitle = viewModel.title
        
        var radioSpecifier = MultiValueSpecifierView(viewModel: viewModel, searchActive: false)
        
        let expectation = radioSpecifier.on(\.didAppear) { view in
            let multiValueView = try XCTUnwrap(view.actualView())
            
            let entry = try multiValueView.inspect().find(ViewType.Picker.self)
            XCTAssertNoThrow(
                try entry.labelView().find(text: expectedTitle)
            )
            
            XCTAssertEqual(multiValueView.selected, "Option 3")
        }
        
        ViewHosting.host(view: radioSpecifier)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_allViewModelEntries_arePresent() {
        // Given
        let expectedTitles = viewModel.characteristic.titles
        
        var multiValueSpecifier = MultiValueSpecifierView(viewModel: viewModel, searchActive: false)
        
        let expectation = multiValueSpecifier.on(\.didAppear) { view in
            let radioView = try XCTUnwrap(view.actualView())
            
            try expectedTitles.forEach { title in
                let entry = try radioView.inspect().find(text: title)
                XCTAssertNotNil(entry)
            }
        }
        
        ViewHosting.host(view: multiValueSpecifier)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_selectValue_shouldUpdateAndPropagateTheValueForRepository() throws {
        let expectation = expectation(description: "MultiValueOption should update and propagate result to RepositoryStorable")
        
        var multiValueSpecifier = MultiValueSpecifierView(viewModel: viewModel, searchActive: false)
        
        cancellable = mockEntries.mockStorable.$results.dropFirst().sink(receiveValue: { received in
            do {
                let receivedValue = try XCTUnwrap(received[MockEntries.MultiValue.key] as? String)
                XCTAssertEqual(receivedValue, "option_1")
                expectation.fulfill()
            } catch {
                XCTFail("failed with error: \(error)")
            }
        })
        
        multiValueSpecifier.on(\.didAppear) { view in
            let multiValueView = try XCTUnwrap(view.actualView())
            XCTAssertEqual(multiValueView.selected, "Option 3")
            
            let entry = try multiValueView.inspect().find(ViewType.Picker.self)
            try entry.select(value: "Option 1")
        }
        
        ViewHosting.host(view: multiValueSpecifier)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_selected_whenDefaultInvalidOnViewModel_shouldFallbackForFirstTitle() throws {
        let mockVM = Specifier.MultiValue(
            title: "Radio Button",
            characteristic: .init(key: "user_defaults_key",
                                  defaultValue: "test_3",
                                  titles: [
                                    "test 1",
                                    "test 2"
                                  ],
                                  values: [
                                    "test_1",
                                    "test_2"
                                  ])
        )
        
        var multiValueSpecifier = MultiValueSpecifierView(viewModel: mockVM, searchActive: false)
        
        let expectation = multiValueSpecifier.on(\.didAppear) { view in
            let radioView = try XCTUnwrap(view.actualView())
            XCTAssertEqual(radioView.selected, "test 1")
        }
        
        ViewHosting.host(view: multiValueSpecifier)
        
        wait(for: [expectation], timeout: 1)
        
    }
        
//    func testPickerSelectionNoChange() {
//        let multiValue = MultiValueSpecifierView(viewModel: viewModel, searchActive: true)
//        
////        XCTAssertEqual(multiValue.viewModel.characteristic.storedContent, "option_2")
//        
////        cancellable = mockEntries.mockStorable.$results.dropFirst().sink(receiveValue: { received in
////            do {
////                let receivedValue = try XCTUnwrap(received[MockEntries.MultiValue.key] as? String)
////                XCTAssertEqual(receivedValue, "option_1")
////                expectation.fulfill()
////            } catch {
////                XCTFail("failed with error: \(error)")
////            }
////        })
//        
//        multiValue.on(\.didAppear) { view in
//            let specifier = try view.actualView()
//            multiValue.selected = "Option 2"
//        }
//        
//        ViewHosting.host(view: multiValue)
//    }
//        
//    func testSearchingKeyView() {
//        let view = MultiValueSpecifierView(viewModel: viewModel, searchActive: true)
//            
////        let searchingKeyView = view.body.viewWithTag(1)
////
////        XCTAssertNotNil(searchingKeyView)
//    }
}
