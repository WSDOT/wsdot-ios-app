//
//  FerriesRouteScheduleItem.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
import SwiftyJSON

class FerriesRouteScheduleItem: NSObject {
 
    var uuid: String = NSUUID().UUIDString
    var routeId: Int = 0
    var routeDescription: String = ""
    var selected = false
    var crossingTime: String? = nil
    var cacheDate: Int64 = 0
    var routeAlertsJSON: JSON = nil
    var routeAlerts = [FerriesRouteAlertItem]()
    var scheduleDate = [FerriesScheduleDateItem]()
    
    private func getRouteAlertItems(alertsJSON: JSON) -> [FerriesRouteAlertItem]{
        
        var alerts = [FerriesRouteAlertItem]()
        
       print("FerriesRouteScheduleItem.getRouteAlertItems raw JSON")
       print(routeAlertsJSON.type)
        
        for (_,alertJSON):(String, JSON) in alertsJSON {
        
            print("Alert")
        
        
    
        
            let alert = FerriesRouteAlertItem(id: alertJSON["BulletinID"].intValue, date: alertJSON["PublishDate"].stringValue, desc: alertJSON["AlertDescription"].stringValue, title: alertJSON["AlertFullTitle"].stringValue, text: alertJSON["AlertFullText"].stringValue)
            alerts.append(alert)
        }
        
       print("FerriesRouteScheduleItem.getRouteAlertItems")
       print(alerts)
        
        return alerts
    }
 
    init(description: String, id: Int, crossingTime: String?, cacheDate: Int64, alerts: JSON, scheduleDate: [FerriesScheduleDateItem] ) {
        super.init()
        self.routeId = id
        self.routeDescription = description
        self.crossingTime = crossingTime
        self.cacheDate = cacheDate
        print("init")
        print(alerts.isExists())
        print(alerts)
        self.routeAlertsJSON = alerts
        self.routeAlerts = getRouteAlertItems(alerts)
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
