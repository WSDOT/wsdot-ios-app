//
//  WSDOTTests.swift
//  WSDOTTests
//
//  Created by Logan Sims on 9/16/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import XCTest
@testable import WSDOT

class WSDOTTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetMinsFromString() {
        assert(TimeUtils.getMinsFromString("aaa 02 HR and 49 MIN") == 169.0)
        assert(TimeUtils.getMinsFromString("aaa aaa 49 MIN") == 49.0)
        assert(TimeUtils.getMinsFromString("aaa 02 HR") == 120.0)
        assert(TimeUtils.getMinsFromString("aaa 00 HR and 49 MIN") == 49.0)
    }

    
    // Umbrella check of all Amtrak schedules.
    func testAmtrakStationCombinations() {
        // This is an example of a performance test case.
        let stations = AmtrakCascadesStore.getStations()
        
        for stationA in stations {
            for stationB in stations {
                if stationA.id != stationB.id {
                    
                    // Declare our expectation
                    let readyExpectation = expectationWithDescription("ready")
                    print("testing " + stationA.id + " to " + stationB.id)
                    
                    AmtrakCascadesStore.getSchedule(NSDate(), originId: stationA.id, destId: stationB.id, completion: { data, error in
                        assert(data != nil)
                        print(stationA.id + " to " + stationB.id + " passed")
                        readyExpectation.fulfill()
                    })
                    
                    // Loop until the expectation is fulfilled
                    waitForExpectationsWithTimeout(5, handler: { error in
                        XCTAssertNil(error, "Error")
                    })
                }
            }
        }
    }
}
