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
    typealias UpdateRoutesCompletion = (error: NSError?) -> ()
    
    static func getRouteSchedules(force: Bool, favoritesOnly: Bool, completion: FetchRouteScheduleCompletion){
        self.updateRouteSchedules(force, completion: { error in
            if ((error == nil)){
                if favoritesOnly {
                    // MARK -
                    // MARK TODO:
                    // self.getFavoriteRoutes
                }else{
                    let routeSchedules = findAllSchedules()
                    completion(data: routeSchedules, error: nil)
                }
            }else{
                completion(data: nil, error: error)
            }
        })
    }
        
    static func updateFavorite(routeId: Int, newValue: Bool){
        do {
            try FerriesScheduleDataHelper.updateFavorite(Int64(routeId), isFavorite: newValue)
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
    
    
    /*
     Updates database by pulling from API.
     */
    private static func updateRouteSchedules(force: Bool, completion: UpdateRoutesCompletion) {
        
        let deltaUpdated = TimeUtils.currentTime - CachesStore.getUpdatedTime(Tables.FERRIES_TABLE)
        
        if ((deltaUpdated > TimeUtils.updateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let routeSchedules = self.parseRouteSchedulesJSON(json)
                        saveRouteSchedules(routeSchedules)
                        CachesStore.updateTime(Tables.FERRIES_TABLE, updated: TimeUtils.currentTime)
                        completion(error: nil)
                    }
                case .Failure(let error):
                    print(error)
                    completion(error: error)
                }
            }
        }else {
            completion(error: nil)
        }
    }

    
    
    // Saves newly pulled data from the API into the database.
    private static func saveRouteSchedules(routeSchedules: [FerriesRouteScheduleItem]){
        
        let oldRoutes = self.findAllSchedules()
        
        self.deleteAll()
        
        for route in routeSchedules {
        
            for oldRoute in oldRoutes {
            
                if(oldRoute.selected){
                    print("!!!!!!!!")
                }
            
                if (oldRoute.routeId == route.routeId) && (oldRoute.selected){
                    print("transfering fav status")
                    route.selected = oldRoute.selected
                }
            }
        
            do {
                try FerriesScheduleDataHelper.insert(
                    RouteScheduleDataModel(
                        routeId: Int64(route.routeId),
                        routeDescription: route.routeDescription,
                        selected: route.selected,
                        crossingTime: route.crossingTime,
                        cacheDate: route.cacheDate,
                        routeAlerts: route.routeAlertsJSON.rawString(),
                        scheduleDates: route.scheduleDatesJSON.rawString()))
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
                    
                    let alertsJSON: JSON = JSON(data: route.routeAlerts!.dataUsingEncoding(NSUTF8StringEncoding)!)
                    let scheduleDatesJSON: JSON = JSON(data: route.scheduleDates!.dataUsingEncoding(NSUTF8StringEncoding)!)

                    let routeItem = FerriesRouteScheduleItem(description: route.routeDescription!, id: Int(route.routeId!), crossingTime: route.crossingTime, isFavorite: route.selected!, cacheDate: route.cacheDate!, alerts: alertsJSON, scheduleDates: scheduleDatesJSON)
                    
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
            
            let route = FerriesRouteScheduleItem(description: subJson["Description"].stringValue, id: subJson["RouteID"].intValue, crossingTime: crossingTime,
                                                 isFavorite: false, cacheDate: cacheDate, alerts: subJson["RouteAlert"], scheduleDates: subJson["Date"])
            routeSchedules.append(route)
        }
        
        return routeSchedules
    }

}
