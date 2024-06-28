// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import ViewInspector
import XCTest
import SwiftUI

final class SliderSpecifierViewTests: XCTestCase {
    var viewModel: Specifier.Slider!
    var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        viewModel = mockEntries.slider
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        cancellable?.cancel()
        cancellable = nil
        mockEntries.storable.resetResults()
        try super.tearDownWithError()
    }
    
    func testSliderValueUpdatesCorrectly() throws {
        let expectation = expectation(description: "Slider should update and propagate result to RepositoryStorable")
        let expectedValue = 34.5
        var sliderView = SliderSpecifierView(viewModel: viewModel,
                                             searchActive: false)
        
        cancellable = mockEntries.storable.$results.dropFirst().sink(receiveValue: { received in
            do {
                let receivedValue = try XCTUnwrap(received[MockEntries.Slider.key] as? Double)
                XCTAssertEqual(receivedValue, expectedValue, accuracy: 0.0001)
                expectation.fulfill()
            } catch {
                XCTFail("failed with error: \(error)")
            }
        })
        
        sliderView.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            let sliderView = try XCTUnwrap(view.actualView())
            let entry = try sliderView.inspect().find(ViewType.Slider.self)
            XCTAssertEqual(sliderView.sliderValue, MockEntries.Slider.defaultValue)
            XCTAssertEqual(sliderView.id, viewModel.id)
            
            let textString = try sliderView.inspect().find(ViewType.Text.self).string()
            let expected = String(format: "Value: %.01f", MockEntries.Slider.defaultValue)
            XCTAssertEqual(textString, expected)
            
            // Value represents a percentage on the slider and not the Value
            let valueToUse = sliderView.sliderPercentageConvert(value: expectedValue)
            try entry.setValue(valueToUse)
        }
        
        ViewHosting.host(view: sliderView)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_textView_shouldContainTheDefaultValueOfViewModel() {
        let expectation = expectation(description: "Slider should update and propagate result to RepositoryStorable")
        let localVM = Specifier.Slider(characteristic:
                .init(key: "key_string",
                      defaultValue: 32.0,
                      minValue: 6,
                      maxValue: 110)
        )
        var sliderView = SliderSpecifierView(viewModel: localVM,
                                             searchActive: false)
        
        sliderView.on(\.didAppear) { view in
            let sliderView = try XCTUnwrap(view.actualView())
            XCTAssertEqual(sliderView.sliderValue, localVM.characteristic.defaultValue)
            
            let text = try sliderView.inspect().find(ViewType.Text.self).string()
            let expected = String(format: "Value: %.01f", 32.0)
            XCTAssertEqual(text, expected)
            
            expectation.fulfill()
        }
        
        ViewHosting.host(view: sliderView)
        wait(for: [expectation], timeout: 1)
    }
    
     func test_searchingKeyView_shouldAlwaysBePresent() throws {
         let viewModel = Specifier.Slider(characteristic: 
                .init(key: "key_string", 
                      defaultValue: 5,
                      minValue: 1,
                      maxValue: 10)
         )
         var sliderView = SliderSpecifierView(viewModel: viewModel, searchActive: true)
         
         let expectation = sliderView.on(\.didAppear) { view in
             let sliderView = try XCTUnwrap(view.actualView())
             let entry = try sliderView.inspect().find(ViewType.Slider.self)
             let sliderAccId = try entry.accessibilityIdentifier()
             XCTAssertEqual(sliderAccId, viewModel.accessibilityIdentifier)
         }
         
         ViewHosting.host(view: sliderView)
         wait(for: [expectation], timeout: 1)
     }
}

private extension SliderSpecifierView {
    /// Converts a slider value to a percentage.
    /// - Parameter value: The value of the slider.
    /// - Returns: The percentage value of the slider, ranging from 0.0 to 1.0. If the value is outside the range of the minimum and maximum values of the view model's characteristic, 0.0 is returned.
    func sliderPercentageConvert(value: Double) -> Double {
        guard value >= viewModel.characteristic.minValue,
              value <= viewModel.characteristic.maxValue else {
            return 0.0
        }
        
        // 7 --------- 18
        // 18
        return (value - viewModel.characteristic.minValue) / (viewModel.characteristic.maxValue - viewModel.characteristic.minValue)
    }
}
