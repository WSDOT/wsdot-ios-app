//
//  FerriesRouteScheduleItem.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
 
class FerriesRouteScheduleItem: NSObject {
 
    var uuid: String = NSUUID().UUIDString
    var routeId: Int = 0
    var routeDescription: String = ""
    var selected = false
    var crossingTime: String? = nil
    var cacheDate: Int64 = 0
    var routeAlert = [FerriesRouteAlertItem]()
    var scheduleDate = [FerriesScheduleDateItem]()

 
    init(description: String, id: Int, crossingTime: String?, cacheDate: Int64, alerts: [FerriesRouteAlertItem], scheduleDate: [FerriesScheduleDateItem] ) {
        super.init()
        self.routeId = id
        self.routeDescription = description
        self.crossingTime = crossingTime
        self.cacheDate = cacheDate
        self.routeAlert = alerts
        self.scheduleDate = scheduleDate
    }
    
    // MARK: -
    // MARK: For testing
    init(description: String, id: Int) {
        super.init()
        self.routeId = id
        self.routeDescription = description
    }
}
