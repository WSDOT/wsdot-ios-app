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
    var scheduleDatesJSON: JSON = nil
    var scheduleDates = [FerriesScheduleDateItem]()
    var sailings = [String]()
    
    init(description: String, id: Int, crossingTime: String?, cacheDate: Int64, alerts: JSON, scheduleDates: JSON ) {
        super.init()
        self.routeId = id
        self.routeDescription = description
        self.crossingTime = crossingTime
        self.cacheDate = cacheDate
        self.routeAlertsJSON = alerts
        self.routeAlerts = getRouteAlertItemsFromJson(alerts)
        self.scheduleDatesJSON = scheduleDates
        self.scheduleDates = getDateItemsFromJson(scheduleDates)
       // print("FerriesRouteScheduleItem.init scheduleDates: JSON ")
       // print(scheduleDates)
        self.sailings = getSailings()
    }
    
    /*
        Creates an array of avaliable sailings for a route based on todays sailings.
    */
    private func getSailings() -> [String]{
    
        var sailingsSet = Set<String>()
        
        for sailing in scheduleDates[0].sailings {
        
            let sailingName = sailing.departingTerminalName + " / " + sailing.arrivingTerminalName
            
            if (!sailingsSet.contains(sailingName)){
                sailingsSet.insert(sailingName)
            }
        }
    
        return Array(sailingsSet)
    }
    
    private func getRouteAlertItemsFromJson(alertsJSON: JSON) -> [FerriesRouteAlertItem]{
        
        var alerts = [FerriesRouteAlertItem]()
        
        for (_,alertJSON):(String, JSON) in alertsJSON {
            
            let alert = FerriesRouteAlertItem(id: alertJSON["BulletinID"].intValue, date: alertJSON["PublishDate"].stringValue, desc: alertJSON["AlertDescription"].stringValue, title: alertJSON["AlertFullTitle"].stringValue, text: alertJSON["AlertFullText"].stringValue)
            alerts.append(alert)
            print("alert full title")
            print(alert.alertFullTitle)
        }
        
        return alerts
    }
    
    private func getDateItemsFromJson(datesJSON: JSON) -> [FerriesScheduleDateItem]{
        
        var dates = [FerriesScheduleDateItem]()

        for (_,dateJSON):(String, JSON) in datesJSON {
        
            let date = FerriesScheduleDateItem(date: dateJSON["Date"].stringValue, sailingsJSON: dateJSON["Sailings"])            
            dates.append(date)
        }
        
        
        return dates
    }
}
