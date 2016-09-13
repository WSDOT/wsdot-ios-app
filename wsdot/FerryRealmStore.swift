//
//  FerryRealmStore.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
/*
 This class collects new ferry schedule information from
 the schedule API at: http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js
 */
class FerryRealmStore {
    
    typealias UpdateRoutesCompletion = (error: NSError?) -> ()
    
    static func updateFavorite(route: FerryScheduleItem, newValue: Bool){
        
        do {
            let realm = try Realm()
            try realm.write{
                route.selected = newValue
            }
        } catch {
            print("FerryRealmStore.updateFavorite: Realm write error")
        }
    }
    
    static func findAllSchedules() -> [FerryScheduleItem]{
            let realm = try! Realm()
            let scheduleItems = realm.objects(FerryScheduleItem.self).filter("delete == false")
            return Array(scheduleItems)

    }
    
    static func findFavoriteSchedules() -> [FerryScheduleItem]{
        let realm = try! Realm()
        let favoriteScheduleItems = realm.objects(FerryScheduleItem.self).filter("selected == true").filter("delete == false")
        return Array(favoriteScheduleItems)
    }
    
    static func updateRouteSchedules(force: Bool, completion: UpdateRoutesCompletion) {
        
        let deltaUpdated = NSCalendar.currentCalendar().components(.Second, fromDate: CachesStore.getUpdatedTime(CachedData.Ferries), toDate: NSDate(), options: []).second
        
        if ((deltaUpdated > TimeUtils.updateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                            let json = JSON(value)
                            let routeSchedules = FerryRealmStore.parseRouteSchedulesJSON(json)
                            saveRouteSchedules(routeSchedules)
                            CachesStore.updateTime(CachedData.Ferries, updated: NSDate())
                            completion(error: nil)
                        }
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

    
    
    // TODO: Make this smarter
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
        
        let oldRoutes = realm.objects(FerryScheduleItem.self)
        
        do {
            try realm.write{
                for route in oldRoutes{
                    route.delete = true
                }
                realm.add(newRoutes, update: true)
            }
        }catch {
            print("FerryRealmStore.saveRouteSchedules: Realm write error")
        }
    }
    
    static func flushOldData(){
        do {
            let realm = try Realm()
            let routeItems = realm.objects(FerryScheduleItem.self).filter("delete == true")
            try! realm.write{
                realm.delete(routeItems)
            }
        }catch {
            print("FerryRealmStore.flushOldData: Realm write error")
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
    
    private static func getTerminalPairs(scheduleDates: List<FerryScheduleDateItem>) -> [FerryTerminalPairItem]{
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
        return terminalPairs.sort({ (a, b) -> Bool in
            return a.aTerminalName < b.aTerminalName
        })
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