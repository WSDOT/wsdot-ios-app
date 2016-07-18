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
    static func getRouteSchedules(force: Bool, completion: FetchRouteScheduleCompletion) {
        
        if (((TimeUtils.currentTime - CachesStore.getUpdatedTime(Tables.FERRIES_TABLE)) > TimeUtils.updateTime) || force){
            print("Database data is old.")
            deleteAll()
    
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
            let routeSchedulesA = findAllSchedules()
            completion(data: routeSchedulesA, error: nil)
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
                        routeAlerts: route.routeAlertsJSON.rawString(),
                        scheduleDate: "")) // TODO: store date
            } catch DataAccessError.Update_Error {
                print("saveRouteSchedules: failed to update caches")
            } catch DataAccessError.Datastore_Connection_Error {
                print("saveRouteSchedules: Connection error")
            } catch DataAccessError.Nil_In_Data{
                print("saveRouteSchedules: nil in data error")
            } catch _ {
                print("saveRouteSchedules: unknown error occured.")
            }
        }
    }

    private static func findAllSchedules() -> [FerriesRouteScheduleItem]{
        var routeSchedules = [FerriesRouteScheduleItem]()
        do{
            if let result = try FerriesScheduleDataHelper.findAll(){
            
                for route in result {
                
                    let alertsJSON: JSON = JSON(arrayLiteral: route.routeAlerts!)
                
                    let routeItem = FerriesRouteScheduleItem(description: route.routeDescription!, id: Int(route.routeId!), crossingTime: route.crossingTime,                                                  cacheDate: route.cacheDate!, alerts: alertsJSON, scheduleDate: [FerriesScheduleDateItem]())
                    routeSchedules.append(routeItem)
                }
            }
        } catch DataAccessError.Datastore_Connection_Error {
            print("findAllSchedules: Connection error")
        } catch _ {
            print("findAllSchedules: unknown error")
        }
        return routeSchedules
    }
    
    private static func deleteAll(){
        do{
            try FerriesScheduleDataHelper.deleteAll()
        } catch DataAccessError.Datastore_Connection_Error {
            print("deleteAll: Connection error")
        } catch _ {
            print("deleteAll: unknown error")
        }
    }
    
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseRouteSchedulesJSON(json: JSON) ->[FerriesRouteScheduleItem]{
        var routeSchedules = [FerriesRouteScheduleItem]()
        for (_,subJson):(String, JSON) in json {
            
            var crossingTime: String? = nil
            
            if (subJson["CrossingTime"] != nil){
                crossingTime = subJson["CrossingTime"].stringValue
            }
            
            let cacheDate = TimeUtils.parseJSONDate(subJson["CacheDate"].stringValue)
            
            let route = FerriesRouteScheduleItem(description: subJson["Description"].stringValue, id: subJson["RouteID"].intValue, crossingTime: crossingTime,                                                  cacheDate: cacheDate, alerts: subJson["RouteAlert"], scheduleDate: parseRouteDatesJSON(subJson["Date"]))
            routeSchedules.append(route)
        }
        
        return routeSchedules
    }
    
    // TODO: implement
    // Helper function for parseRouteSchedulesJSON
    // Reads builds FerriesScheduleDateItem array from JSON
    private static func parseRouteDatesJSON(json: JSON) ->[FerriesScheduleDateItem]{
        return [FerriesScheduleDateItem]()
    }
}
