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
    var sailings = [(String, String)]()
    
    init(description: String, id: Int, crossingTime: String?, isFavorite: Bool, cacheDate: Int64, alerts: JSON, scheduleDates: JSON ) {
        super.init()
        self.routeId = id
        self.routeDescription = description
        self.crossingTime = crossingTime
        self.cacheDate = cacheDate
        self.selected = isFavorite
        self.routeAlertsJSON = alerts
        self.routeAlerts = getRouteAlertItemsFromJson(alerts)
        self.scheduleDatesJSON = scheduleDates
        self.scheduleDates = getDateItemsFromJson(scheduleDates)
        self.sailings = getSailings()
    }
    
    /*
        Creates an array of avaliable sailings for a route based on todays sailings.
    */
    private func getSailings() -> [(String, String)]{
        
        var sailings = [(String, String)]()
        
        for index in 0...scheduleDates.count-1 {
            for sailing in scheduleDates[index].sailings {
                
                let sailing = (sailing.departingTerminalName, sailing.arrivingTerminalName)
                
                if (!contains(sailings, v: sailing)){
                    sailings.append(sailing)
                }
            }
        }
        
        return sailings.sort({ $0.0 < $1.0})
    }
    
    private func contains(a:[(String, String)], v:(String,String)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    private func getRouteAlertItemsFromJson(alertsJSON: JSON) -> [FerriesRouteAlertItem]{
        
        var alerts = [FerriesRouteAlertItem]()
        
        for (_,alertJSON):(String, JSON) in alertsJSON {
            
            let alert = FerriesRouteAlertItem(id: alertJSON["BulletinID"].intValue, date: alertJSON["PublishDate"].stringValue, desc: alertJSON["AlertDescription"].stringValue, title: alertJSON["AlertFullTitle"].stringValue, text: alertJSON["AlertFullText"].stringValue)
            
            
            if(alert.alertFullText != ""){
                alerts.append(alert)
            }
            
            
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
