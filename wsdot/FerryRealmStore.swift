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
 Collects new ferry schedule information from
 the schedule API at: https://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js
 */
class FerryRealmStore {
    
    typealias UpdateRoutesCompletion = (_ error: Error?) -> ()
    
    static func updateFavorite(_ route: FerryScheduleItem, newValue: Bool){
        
        do {
            let realm = try Realm()
            try realm.write{
                route.selected = newValue
            }
        } catch {
            print("FerryRealmStore.updateFavorite: Realm write error")
        }
    }
    
    static func toggleFavorite(_ routeId: Int) -> Int {
        do {
            let realm = try! Realm()
            let scheduleItem = realm.object(ofType: FerryScheduleItem.self, forPrimaryKey: routeId)
            
            if let scheduleItemValue = scheduleItem {
                try realm.write{
                    scheduleItemValue.selected = !scheduleItemValue.selected
                }
                return scheduleItemValue.selected ? 1 : 0
            }
            return -1
        } catch {
            print("FerryRealmStore.updateFavorite: Realm write error")
            return -1
        }
    }
    
    static func findAllSchedules() -> [FerryScheduleItem]{
        let realm = try! Realm()
        let scheduleItems = realm.objects(FerryScheduleItem.self).filter("delete == false")
        return Array(scheduleItems.sorted(by: {$0.routeDescription < $1.routeDescription}))
    }
    
    static func findFavoriteSchedules() -> [FerryScheduleItem]{
        let realm = try! Realm()
        let favoriteScheduleItems = realm.objects(FerryScheduleItem.self).filter("selected == true").filter("delete == false")
        return Array(favoriteScheduleItems.sorted(by: {$0.routeDescription < $1.routeDescription}))
    }
    
    static func findSchedule(withId: Int) -> FerryScheduleItem? {
        let realm = try! Realm()
        let scheduleItem = realm.object(ofType: FerryScheduleItem.self, forPrimaryKey: withId)
        return scheduleItem
    }
    
    static func updateRouteSchedules(_ force: Bool, completion: @escaping UpdateRoutesCompletion) {
    
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { 
            var delta = CachesStore.updateTime
            let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.ferries), to: Date(), options: []).second
            
            if let deltaValue = deltaUpdated {
                delta = deltaValue
            }
        
            if ((delta > CachesStore.updateTime) || force){
            
                Alamofire.request("https://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js").validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            DispatchQueue.global().async {
                                let json = JSON(value)
                                let routeSchedules = FerryRealmStore.parseRouteSchedulesJSON(json)
                                saveRouteSchedules(routeSchedules)
                                CachesStore.updateTime(CachedData.ferries, updated: Date())
                                DispatchQueue.main.async { completion(nil) }
                            }
                        }
                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async { completion(error) }
                    }
                }
            }else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    // Saves new route schedules. tags old routes for deletion if not updated.
    fileprivate static func saveRouteSchedules(_ routeSchedules: [FerryScheduleItem]){
        
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
                realm.add(newRoutes, update: .all)
            }
        }catch {
            print("FerryRealmStore.saveRouteSchedules: Realm write error")
        }
    }
    
    // Deletes routes tagged for deletion
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
    fileprivate static func parseRouteSchedulesJSON(_ json: JSON) ->[FerryScheduleItem]{
        var routeSchedules = [FerryScheduleItem]()
        for (_,subJson):(String, JSON) in json {
            
            var crossingTime: String? = nil
            
            if (subJson["CrossingTime"] != JSON.null){
                crossingTime = subJson["CrossingTime"].stringValue
            }
            
            // Check for new date format from future API update, fall back to previous date format
            var cacheDate = Date()
            if let cacheDateValue = try? TimeUtils.formatTimeStamp(subJson["CacheDate"].stringValue) {
                cacheDate = cacheDateValue
            } else {
                cacheDate = TimeUtils.parseJSONDateToNSDate(subJson["CacheDate"].stringValue)
            }
            
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
    
    fileprivate static func getTerminalPairs(_ scheduleDates: List<FerryScheduleDateItem>) -> [FerryTerminalPairItem]{
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
        return terminalPairs.sorted(by: { (a, b) -> Bool in
            return a.aTerminalName < b.aTerminalName
        })
    }
    
    
    fileprivate static func containsTerminal(_ terms: List<FerryTerminalPairItem>, term: FerryTerminalPairItem) -> Bool{
        for terminal in terms {if terminal.aTerminalId == term.aTerminalId && terminal.bTerminalId == term.bTerminalId { return true } }
        return false
    }
    
    fileprivate static func parseAlertsJSON(_ json: JSON) -> List<FerryAlertItem> {
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
 
    fileprivate static func parseDateJSON(_ json: JSON) -> List<FerryScheduleDateItem> {
        let scheduleDates = List<FerryScheduleDateItem>()
        for(_,dateJSON):(String, JSON) in json {
            let scheduleDate = FerryScheduleDateItem()
            
            // Check for new date format from future API update, fall back to previous date format
            if let dateValue = try? TimeUtils.formatTimeStamp(dateJSON["Date"].stringValue, dateFormat: "yyyy-MM-dd") {
                scheduleDate.date = dateValue
            } else {
                scheduleDate.date = TimeUtils.parseJSONDateToNSDate(dateJSON["Date"].stringValue)
            }
            
            for sailing in parseSailingsJSON(dateJSON["Sailings"]){
                scheduleDate.sailings.append(sailing)
            }
            scheduleDates.append(scheduleDate)
        }
        return scheduleDates
    }
    
    fileprivate static func parseSailingsJSON(_ json: JSON) -> List<FerrySailingsItem>{
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
    
    fileprivate static func parseDepartureTimesJSON(_ json: JSON) -> List<FerryDepartureTimeItem>{
        let times = List<FerryDepartureTimeItem>()
        for(_, timeJSON):(String, JSON) in json {
            let time = FerryDepartureTimeItem()
            
            // Check for new date format from future API update, fall back to previous date format
            if (timeJSON["ArrivingTime"] != JSON.null){
                if let timeValue = try? TimeUtils.formatTimeStamp(timeJSON["ArrivingTime"].stringValue) {
                    time.arrivingTime = timeValue
                } else {
                    time.arrivingTime = TimeUtils.parseJSONDateToNSDate(timeJSON["ArrivingTime"].stringValue)
                }
            }
            
            // Check for new date format from future API update, fall back to previous date format
            if let timeValue = try? TimeUtils.formatTimeStamp(timeJSON["DepartingTime"].stringValue) {
                time.departingTime = timeValue
            } else {
                time.departingTime = TimeUtils.parseJSONDateToNSDate(timeJSON["DepartingTime"].stringValue)
            }
            
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
