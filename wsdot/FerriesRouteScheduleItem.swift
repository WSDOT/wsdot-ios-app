//
//  RouteSchedulesModel.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit
 
class FerriesRouteScheduleItem: NSObject {
 
    var uuid: String = NSUUID().UUIDString
    var routeId: Int = 0
    var routeDescription: String = ""
    var selected = false
    var routeAlert = [FerriesRouteAlertItem]()
    var scheduleDate = [FerriesScheduleDateItem]()
 
    init(description: String, id: Int, alerts: [FerriesRouteAlertItem], scheduleDate: [FerriesScheduleDateItem] ) {
        super.init()
        self.routeId = id
        self.routeDescription = description
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
