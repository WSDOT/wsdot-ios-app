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

        tablesQuery.cells.elementBoundByIndex(0).doubleTap()
        snapshot("01TrafficMap")
        
        app.navigationBars["Traffic Map"].buttons["icMenu"].doubleTap()
        
        expectationForPredicate(exists, evaluatedWithObject: tablesQuery.cells.staticTexts["Travel Times"], handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        tablesQuery.cells.staticTexts["Travel Times"].doubleTap()
        snapshot("02TravelTimes")
    }
    
    func testMountainPassScreenShots() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let exists = NSPredicate(format: "exists == true")

        tablesQuery.cells.elementBoundByIndex(2).doubleTap()
        
        expectationForPredicate(exists, evaluatedWithObject: tablesQuery.staticTexts["Blewett Pass US97"], handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        tablesQuery.staticTexts["Blewett Pass US97"].doubleTap()
        snapshot("03PassReport")
    }
    
    func testFerriesScreenShots() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let exists = NSPredicate(format: "exists == true")
        expectationForPredicate(exists, evaluatedWithObject: tablesQuery.cells.elementBoundByIndex(5), handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        tablesQuery.cells.elementBoundByIndex(1).doubleTap()
        expectationForPredicate(exists, evaluatedWithObject: tablesQuery.staticTexts["Route Schedules"], handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        
        tablesQuery.staticTexts["Route Schedules"].doubleTap()
        expectationForPredicate(exists, evaluatedWithObject: tablesQuery.staticTexts["Seattle / Bremerton"], handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        
        tablesQuery.staticTexts["Seattle / Bremerton"].doubleTap()
        tablesQuery.staticTexts["Seattle to Bremerton"].doubleTap()
        snapshot("04RouteDetails")
    }
    
    func testAmtrakCascadesScreenShots() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        tablesQuery.cells.elementBoundByIndex(6).doubleTap()
        
        tablesQuery.staticTexts["Check Schedules and Status"].doubleTap()
        
        addUIInterruptionMonitorWithDescription("Allow “WSDOT” to access your location while you use the app?") { (alert) -> Bool in
            alert.buttons["Allow"].doubleTap()
            return true
        }
        
        app.scrollViews.otherElements.childrenMatchingType(.TextField).elementBoundByIndex(1).tap()
        app.pickerWheels.element.adjustToPickerWheelValue("Seattle, WA")
        app.pickers.pickerWheels["Seattle, WA"].doubleTap()
        app.toolbars.buttons["Done"].tap()
        
        app.scrollViews.otherElements.childrenMatchingType(.TextField).elementBoundByIndex(2).tap()
        app.pickerWheels.element.adjustToPickerWheelValue("Portland, OR")
        app.pickers.pickerWheels["Portland, OR"].doubleTap()
        app.toolbars.buttons["Done"].tap()
        
        app.scrollViews.otherElements.buttons["Check Schedules"].doubleTap()
        snapshot("05AmtrakCascadesDetails")
    }
}
