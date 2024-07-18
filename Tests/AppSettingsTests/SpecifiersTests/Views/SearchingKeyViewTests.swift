// Copyright © ICS 2024 from aiPhad.com

@testable import AppSettings
import Combine
import SwiftUI
import ViewInspector
import XCTest

final class SearchingKeyViewTests: XCTestCase {
    func test_body_searchingKeyView_whenSearchIsActive() {
        // given
        let expectation = expectation(description: "A Label with the key and one the the specifier path are the only ones expected")
        expectation.expectedFulfillmentCount = 2
        
        let specifierKey = "some_specifier_key"
        let specifierTitle = "specifier title"
        let specifierPath = "some/specifier/path"
        
        // when
        var sut = SearchingKeyView(
            searchIsActive: true,
            specifierKey: specifierKey,
            specifierTitle: specifierTitle,
            specifierFooter: "specifierFooter",
            specifierPath: specifierPath
        )
        
        // then
        sut.on(\.didAppear) { view in
            let searchKeyView = try XCTUnwrap(view.actualView())
            
            let textViews = try searchKeyView
                .inspect()
                .findAll(ViewType.Text.self)
            
            XCTAssertEqual(textViews.count, 2)
            
            try textViews.forEach { textView in
                if try textView.attributes().font() == .caption,
                   try textView.string().contains(specifierKey) {
                    expectation.fulfill()
                }
                
                if try textView.attributes().font() == .system(size: 9),
                   try textView.string() == specifierPath {
                    expectation.fulfill()
                }
            }
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_body_searchingKeyView_whenSearchIsInactive() {
        // given
        let expectation = expectation(description: "A Label with the specifier footer is expected")
        
        let specifierFooter = "specifier footer"
        
        // when
        var sut = SearchingKeyView(
            searchIsActive: false,
            specifierKey: "specifierKey",
            specifierTitle: "specifierTitle",
            specifierFooter: specifierFooter,
            specifierPath: "specifierPath"
        )
        
        // then
        sut.on(\.didAppear) { view in
            let searchKeyView = try XCTUnwrap(view.actualView())
            
            let textViews = try searchKeyView
                .inspect()
                .findAll(ViewType.Text.self)
            
            XCTAssertEqual(textViews.count, 1)
            
            try textViews.forEach { textView in
                if try textView.string() == specifierFooter {
                    expectation.fulfill()
                }
            }
        }
        
        ViewHosting.host(view: sut)
        
        wait(for: [expectation], timeout: 1)
    }
}
