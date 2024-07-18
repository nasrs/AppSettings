// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import ViewInspector
import XCTest
import SwiftUI

final class GroupSpecifierViewTests: XCTestCase {
    var sut: GroupSpecifierView!
    var viewModel: Specifier.Group!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = mockEntries.group(with: [
            mockEntries.toggleSwitch,
            mockEntries.radio,
            mockEntries.slider
        ])
        
        sut = GroupSpecifierView(viewModel: viewModel,
                                 searchIsActive: false)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        viewModel = nil
        try super.tearDownWithError()
    }
    
    
    func testHeaderSectionOfGroupSpecifierView() {
        let expectedTitle = viewModel.title
        
        let expectation = sut.on(\.didAppear) { view in
            let groupView = try XCTUnwrap(view.actualView())
            
            let textView = try groupView
                .inspect()
                .find(ViewType.Section.self)
                .header()
                .find(ViewType.Text.self)
            
            XCTAssertEqual(try textView.string(),
                           expectedTitle)
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFooterSectionOfGroupSpecifierView() {
        let expectedFooter = viewModel.footerText
        
        let expectation = sut.on(\.didAppear) { view in
            let groupView = try XCTUnwrap(view.actualView())
            
            let textView = try groupView
                .inspect()
                .find(ViewType.Section.self)
                .footer()
                .find(ViewType.Text.self)
            
            XCTAssertEqual(try textView.string(),
                           expectedFooter)
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testSectionEntriesOfGroupSpecifierView() {
        let expectedEntries = viewModel.characteristic.entries
        
        let expectation = sut.on(\.didAppear) { view in
            let groupView = try XCTUnwrap(view.actualView())
            
            let textViews = try groupView
                .inspect()
                .find(ViewType.Section.self)
                .findAll(SettingsEntryView.self)
            
            try textViews.enumerated().forEach { enumerator in
                let settingsEntryView = try enumerator.element.actualView()
                
                XCTAssertTrue(
                    settingsEntryView.viewModel.isEqual(
                        expectedEntries[enumerator.offset]
                    )
                )
            }
            
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
}
