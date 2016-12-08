//
//  WSDOTUITests.swift
//  WSDOTUITests
//
//  Created by Logan Sims on 9/6/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import XCTest

class WSDOTUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTrafficMapScreenShots() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let exists = NSPredicate(format: "exists == true")

        tablesQuery.cells.element(boundBy: 0).doubleTap()
        app.toolbars.buttons["Go To Location"].tap()
        app.tables.staticTexts["Seattle"].tap()
        
        sleep(5)
        snapshot("01TrafficMap")
        
        app.navigationBars["Traffic Map"].buttons["Menu"].doubleTap()
        
        expectation(for: exists, evaluatedWith: tablesQuery.cells.staticTexts["Travel Times"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        tablesQuery.cells.staticTexts["Travel Times"].doubleTap()
        snapshot("02TravelTimes")
    }
    
    func testMountainPassScreenShots() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let exists = NSPredicate(format: "exists == true")

        tablesQuery.cells.element(boundBy: 2).tap()
        
        expectation(for: exists, evaluatedWith: tablesQuery.staticTexts["Blewett Pass US97"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        tablesQuery.staticTexts["Blewett Pass US97"].doubleTap()
        snapshot("03PassReport")
    }
    
    func testFerriesScreenShots() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: tablesQuery.cells.element(boundBy: 5), handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        tablesQuery.cells.element(boundBy: 1).doubleTap()
        expectation(for: exists, evaluatedWith: tablesQuery.staticTexts["Route Schedules"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        tablesQuery.staticTexts["Route Schedules"].doubleTap()
        expectation(for: exists, evaluatedWith: tablesQuery.staticTexts["Seattle / Bremerton"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        tablesQuery.staticTexts["Seattle / Bremerton"].doubleTap()
        tablesQuery.staticTexts["Seattle to Bremerton"].doubleTap()
        snapshot("04RouteDetails")
    }
    
    func testAmtrakCascadesScreenShots() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        tablesQuery.cells.element(boundBy: 6).doubleTap()
        
        tablesQuery.staticTexts["Check Schedules and Status"].doubleTap()
        
        addUIInterruptionMonitor(withDescription: "Allow “WSDOT” to access your location while you use the app?") { (alert) -> Bool in
            alert.buttons["Allow"].doubleTap()
            return true
        }
        
        tablesQuery.staticTexts["Origin"].tap()
        // Clears Seattle from origin if using location
        tablesQuery.staticTexts["Bellingham, WA"].tap()
        tablesQuery.staticTexts["Origin"].tap()
        tablesQuery.staticTexts["Seattle, WA"].tap()
        tablesQuery.staticTexts["Destination"].tap()
        tablesQuery.staticTexts["Portland, OR"].tap()
        tablesQuery.staticTexts["Check Schedule"].tap()
        
        snapshot("05Amtrak")
    }
}
