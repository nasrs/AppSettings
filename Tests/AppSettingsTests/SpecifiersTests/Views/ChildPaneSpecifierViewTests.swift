// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import ViewInspector
import XCTest
import SwiftUI

final class ChildPaneSpecifierViewTests: XCTestCase {
    var sut: ChildPaneSpecifierView<EmptyView>!
    var viewModel: Specifier.ChildPane!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = mockEntries.childPane(with: [
            mockEntries.toggleSwitch
        ])
        
        sut = ChildPaneSpecifierView(viewModel: viewModel) {
            EmptyView()
        }
    }
    
    override func tearDownWithError() throws {
        sut = nil
        viewModel = nil
        try super.tearDownWithError()
    }
    
    func testChildPaneSpecifierViewInitialization() {
        XCTAssertEqual(sut.viewModel.title, MockEntries.ChildPane.title)
        XCTAssertEqual(sut.viewModel.characteristic.fileName, MockEntries.ChildPane.fileName)
    }
    
    func testChildPaneSpecifierViewAccessibilityIdentifier() {
        let expectedIdentifier = viewModel.accessibilityIdentifier
        
        let expectation = sut.on(\.didAppear) { view in
            let childPaneView = try XCTUnwrap(view.actualView())
            
            let linkView = try childPaneView.inspect().find(ViewType.NavigationLink.self)
            
            XCTAssertEqual(try linkView.accessibilityIdentifier(),
                           expectedIdentifier)
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testChildPaneSpecifierViewTitle() {
        let expectedTitleText = viewModel.title
        
        let expectation = sut.on(\.didAppear) { view in
            let childPaneView = try XCTUnwrap(view.actualView())
            
            let textView = try childPaneView
                .inspect()
                .find(TextOrEmptyView.self)
                .find(ViewType.Text.self)
            
            XCTAssertEqual(try textView.string(),
                           expectedTitleText)
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
}
