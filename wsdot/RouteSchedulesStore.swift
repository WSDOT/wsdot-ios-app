//
//  RouteSchedulesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
/*
 This class collects new ferry schedule information from
 the schedule API at: http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js
 
 Roles:
 Saves information into SQLite database.
 Converts JSON data structure into SQLite data using typealias.
 */
class RouteSchedulesStore {
    
    typealias FetchRouteScheduleCompletion = (data: [FerriesRouteScheduleItem]?, error: NSError?) -> ()
    
    /*
     Gets ferry schedule data from API or database.
     Updates database when pulling from API.
     */
    static func getRouteSchedules(completion: FetchRouteScheduleCompletion) {
        
        if (true){
        //if ((TimeUtils.currentTime - CachesStore.getUpdatedTime(Tables.FERRIES_TABLE)) > TimeUtils.updateTime){
            print("Database data is old.")
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let routeSchedules = self.parseRouteSchedulesJSON(json)
                        saveRouteSchedules(routeSchedules)
                        CachesStore.updateTime(Tables.FERRIES_TABLE, updated: TimeUtils.currentTime)
                        completion(data: routeSchedules, error: nil)
                    }
                case .Failure(let error):
                    print(error)
                    completion(data: nil, error: error)
                }
            }
            
        }else {
            print("Database data is still good.")
            //let routeSchedules = findAllSchedules()
            //completion(data: routeSchedules, error: nil)
        }
    }
    
    // Saves newly pulled data from the API into the database.
    private static func saveRouteSchedules(routeSchedules: [FerriesRouteScheduleItem]){
        for route in routeSchedules {
            do {
                try FerriesScheduleDataHelper.insert(
                    RouteScheduleDataModel(
                        routeId: Int64(route.routeId),
                        routeDescription: route.routeDescription,
                        selected: route.selected ? 1 : 0,
                        crossingTime: route.crossingTime,
                        cacheDate: route.cacheDate,
                        routeAlert: "", // TODO: store alerts and date..?
                        scheduleDate: ""))
            } catch _ {
                // Failed to insert
            }
        }
    }
    
    /*
     private static func findAllSchedules() -> [FerriesRouteScheduleItem]{
     
     
     
     return nil
     
     }
     */
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseRouteSchedulesJSON(json: JSON) ->[FerriesRouteScheduleItem]{
        
        var routeSchedules = [FerriesRouteScheduleItem]()
        
        for (_,subJson):(String, JSON) in json {
            
            var crossingTime: String? = nil
            
            if (subJson["CrossingTime"] != nil){
                crossingTime = subJson["CrossingTime"].stringValue
            }
            
            let cacheDate = TimeUtils.parseJSONDate(subJson["CacheDate"].stringValue)
            
            let route = FerriesRouteScheduleItem(description: subJson["Description"].stringValue, id: subJson["RouteID"].intValue, crossingTime: crossingTime,                                                  cacheDate: cacheDate, alerts: parseRouteAlertJSON(subJson["RouteAlert"]), scheduleDate: parseRouteDatesJSON(subJson["Date"]))
            routeSchedules.append(route)
        }
        
        return routeSchedules
    }
    
    
    // Helper function for parseRouteSchedulesJSON
    // Reads builds FerriesRouteAlertItem array from JSON
    private static func parseRouteAlertJSON(json: JSON) ->[FerriesRouteAlertItem]{
        
        var routeAlerts = [FerriesRouteAlertItem]()
        
        for (_,subJson):(String, JSON) in json {
            let alert = FerriesRouteAlertItem(id: subJson["BulletinID"].intValue, date: subJson["PublishDate"].stringValue, desc: subJson["AlertDescription"].stringValue,
                                              title: subJson["AlertFullTitle"].stringValue, text: subJson["AlertFullText"].stringValue)
            
            
            routeAlerts.append(alert)
        }
        
        return routeAlerts
    }
    
    // TODO: implement
    // Helper function for parseRouteSchedulesJSON
    // Reads builds FerriesScheduleDateItem array from JSON
    private static func parseRouteDatesJSON(json: JSON) ->[FerriesScheduleDateItem]{
        return [FerriesScheduleDateItem]()
    }
}
