//
//  FerryRealmStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/3/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
/*
 This class collects new ferry schedule information from
 the schedule API at: http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js
 
 Roles:
 Saves information into SQLite database.
 Converts JSON data structure into SQLite data using typealias.
 */
class FerryRealmStore {
    
    typealias UpdateRoutesCompletion = (error: NSError?) -> ()

    static func updateFavorite(route: FerryScheduleItem, newValue: Bool){
        let realm = try! Realm()
        try! realm.write{
            route.selected = newValue
        }
    }
    
    static func findAllSchedules() -> [FerryScheduleItem]{
        let realm = try! Realm()
        let scheduleItems = realm.objects(FerryScheduleItem.self)
        return Array(scheduleItems)
    }
    
    static func findFavoriteSchedules() -> [FerryScheduleItem]{
        let realm = try! Realm()
        let favoriteScheduleItems = realm.objects(FerryScheduleItem.self).filter("selected == true")
        return Array(favoriteScheduleItems)
    }
    
    static func updateRouteSchedules(force: Bool, completion: UpdateRoutesCompletion) {
        
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
    private static func saveRouteSchedules(routeSchedules: [FerryScheduleItem]){
        
        let realm = try! Realm()
        
        let oldFavoriteRoutes = self.findFavoriteSchedules()
        let newRoutes = List<FerryScheduleItem>()
        
        for route in routeSchedules {
            for oldRoute in oldFavoriteRoutes {
                if (oldRoute.routeId == route.routeId){
                    route.selected = true
                }
            }
            newRoutes.append(route)
        }
        
        deleteAll()
        
        for newRoute in newRoutes{
            try! realm.write{
                realm.add(newRoute)
            }
        }
    
        
    }
    
    private static func deleteAll(){
        let realm = try! Realm()
        try! realm.write{
            realm.delete(realm.objects(FerryScheduleItem))
        }
    }
    
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseRouteSchedulesJSON(json: JSON) ->[FerryScheduleItem]{
        var routeSchedules = [FerryScheduleItem]()
        for (_,subJson):(String, JSON) in json {
            
            var crossingTime: String? = nil
            
            if (subJson["CrossingTime"] != nil){
                crossingTime = subJson["CrossingTime"].stringValue
            }
            
            let cacheDate = TimeUtils.parseJSONDateToNSDate(subJson["CacheDate"].stringValue)
            
            let route = FerryScheduleItem()
            route.routeId = subJson["RouteID"].intValue
            route.routeDescription = subJson["Description"].stringValue
            route.crossingTime = crossingTime
            route.selected = false
            route.cacheDate = cacheDate
            
            for alert in parseAlertsJSON(subJson["RouteAlert"]){
                route.routeAlerts.append(alert)
            }
            
            for dateSchedule in parseDateJSON(subJson["Date"]){
                route.scheduleDates.append(dateSchedule)
            }
            
            for terminalPair in getTerminalPairs(route.scheduleDates){
                route.terminalPairs.append(terminalPair)
            }
            
            
            routeSchedules.append(route)
        }
        
        return routeSchedules
    }
    
    private static func getTerminalPairs(scheduleDates: List<FerryScheduleDateItem>) -> List<FerryTerminalPairItem>{
        let terminalPairs = List<FerryTerminalPairItem>()
        
        for index in 0...scheduleDates.count-1 {
            for sailing in scheduleDates[index].sailings{
                let terminalPair = FerryTerminalPairItem()
                terminalPair.aTerminalId = sailing.arrivingTerminalId
                terminalPair.aTerminalName = sailing.arrivingTerminalName
                terminalPair.bTerminalId = sailing.departingTerminalId
                terminalPair.bTterminalName = sailing.departingTerminalName
                if !containsTerminal(terminalPairs, term: terminalPair){
                    terminalPairs.append(terminalPair)
                }
            }
        }
        return terminalPairs
    }
    
    
    private static func containsTerminal(terms: List<FerryTerminalPairItem>, term: FerryTerminalPairItem) -> Bool{
        for terminal in terms {if terminal.aTerminalId == term.aTerminalId && terminal.bTerminalId == term.bTerminalId { return true } }
        return false
    }
    
    private static func parseAlertsJSON(json: JSON) -> List<FerryAlertItem> {
        let routeAlerts = List<FerryAlertItem>()
    
        for(_,alertJSON):(String, JSON) in json {
            let alert = FerryAlertItem()
            alert.bulletinId = alertJSON["BulletinID"].intValue
            alert.alertFullTitle = alertJSON["AlertFullTitle"].stringValue
            alert.alertFullText = alertJSON["AlertFullText"].stringValue
            alert.alertDescription = alertJSON["AlertDescription"].stringValue
            alert.publishDate = alertJSON["PublishDate"].stringValue
            routeAlerts.append(alert)
        }
        return routeAlerts
    }
 
    private static func parseDateJSON(json: JSON) -> List<FerryScheduleDateItem> {
        let scheduleDates = List<FerryScheduleDateItem>()
        for(_,dateJSON):(String, JSON) in json {
            let scheduleDate = FerryScheduleDateItem()
            scheduleDate.date = TimeUtils.parseJSONDateToNSDate(dateJSON["Date"].stringValue)
            for sailing in parseSailingsJSON(dateJSON["Sailings"]){
                scheduleDate.sailings.append(sailing)
            }
            scheduleDates.append(scheduleDate)
        }
        return scheduleDates
    }
    
    private static func parseSailingsJSON(json: JSON) -> List<FerrySailingsItem>{
        let sailings = List<FerrySailingsItem>()
        for(_, sailingJSON):(String, JSON) in json {
            let sailing = FerrySailingsItem()
            
            sailing.arrivingTerminalId = sailingJSON["ArrivingTerminalID"].intValue
            sailing.arrivingTerminalName = sailingJSON["ArrivingTerminalName"].stringValue
            sailing.departingTerminalId = sailingJSON["DepartingTerminalID"].intValue
            sailing.departingTerminalName = sailingJSON["DepartingTerminalName"].stringValue
            
            for time in parseDepartureTimesJSON(sailingJSON["Times"]){
                sailing.times.append(time)
            }
            
            for(_, annotationJSON):(String, JSON) in sailingJSON["Annotations"]{
                let annotation = Annotation()
                annotation.message = annotationJSON.stringValue
                sailing.annotations.append(annotation)
            }
            
            sailings.append(sailing)
        }
        return sailings
    }
    
    private static func parseDepartureTimesJSON(json: JSON) -> List<FerryDepartureTimeItem>{
        let times = List<FerryDepartureTimeItem>()
        for(_, timeJSON):(String, JSON) in json {
            let time = FerryDepartureTimeItem()
            
            if (timeJSON["ArrivingTime"] != nil){
                time.arrivingTime = TimeUtils.parseJSONDateToNSDate(timeJSON["ArrivingTime"].stringValue)
            }
            time.departingTime = TimeUtils.parseJSONDateToNSDate(timeJSON["DepartingTime"].stringValue)
            
            for(_,annotationIndex):(String, JSON) in timeJSON["AnnotationIndexes"]{
            
                let index = AnnotationIndex()
                index.index = annotationIndex.intValue
                time.annotationIndexes.append(index)
            }
            
            times.append(time)
        }
        return times
    }
}
