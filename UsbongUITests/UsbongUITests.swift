//
//  UsbongUITests.swift
//  UsbongUITests
//
//  Created by Chris Amanse on 11/26/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import XCTest

class UsbongUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSnapshot() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Settings"].tap()
        snapshot("3Settings")
        
        tabBarsQuery.buttons["Trees"].tap()
        snapshot("0Trees")
        
        app.tables.staticTexts["Usbong iOS"].tap()
        
        // Wait until task node is available
        while !app.tables.cells.childrenMatchingType(.TextView).element.exists {
            sleep(1)
        }
        
        snapshot("1Usbong iOS")
        
        app.buttons["NEXT"].tap()
        
        sleep(1)
        snapshot("2Task Nodes")
    }
    
}
