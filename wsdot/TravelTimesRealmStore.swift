//
//  TravelTimesRealmStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import Foundation
import SwiftyJSON
import RealmSwift
import Alamofire

class TravelTimesStore{
    
    typealias getTravelTimesCompletion = (error: NSError?) -> ()
    
    static func updateFavorite(route: TravelTimeItem, newValue: Bool){
        do {
            let realm = try Realm()
            try realm.write{
                route.selected = newValue
            }
        } catch {
            print("TravelTimesStore.updateFavorite: Realm write error")
        }
    }
    
    static func getAllTravelTimes() -> [TravelTimeItem]{
        let realm = try! Realm()
        let travelTimeItems = realm.objects(TravelTimeItem.self)
        return Array(travelTimeItems)
    }
    
    static func findFavoriteTimes() -> [TravelTimeItem]{
        let realm = try! Realm()
        let favoriteTimeItems = realm.objects(TravelTimeItem.self).filter("selected == true")
        return Array(favoriteTimeItems)
    }
    
    static func updateTravelTimes(force: Bool, completion: getTravelTimesCompletion) {
        
        let deltaUpdated = NSCalendar.currentCalendar().components(.Second, fromDate: CachesStore.getUpdatedTime(CachedData.Ferries), toDate: NSDate(), options: []).second
        
        if ((deltaUpdated > TimeUtils.updateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/TravelTimes.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                            let json = JSON(value)
                            let travelTimes = TravelTimesStore.parseTravelTimesJSON(json)
                            saveTravelTimes(travelTimes)
                            CachesStore.updateTime(CachedData.TravelTimes, updated: NSDate())
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
    private static func saveTravelTimes(travelTimes: [TravelTimeItem]){
        
        let realm = try! Realm()
        
        let oldFavoriteTimes = self.findFavoriteTimes()
        let newTimes = List<TravelTimeItem>()
        
        for time in travelTimes {
            for oldTime in oldFavoriteTimes {
                if (oldTime.routeid == time.routeid){
                    time.selected = true
                }
            }
            newTimes.append(time)
        }
        
        let oldTimes = realm.objects(TravelTimeItem.self)
        
        do {
            try realm.write{
                for time in oldTimes{
                    time.delete = true
                }
                realm.add(newTimes, update: true)
            }
        }catch {
            print("TravelTimesStore.saveTravelTimes: Realm write error")
        }
    }
    
    static func flushOldData(){
        do {
            let realm = try Realm()
            let timeItems = realm.objects(TravelTimeItem.self).filter("delete == true")
            try! realm.write{
                realm.delete(timeItems)
            }
        }catch {
            print("TravelTimesStore.flushOldData: Realm write error")
        }
    }
    
    private static func parseTravelTimesJSON(json: JSON) ->[TravelTimeItem]{
        var travelTimes = [TravelTimeItem]()
        
        for (_,subJson):(String, JSON) in json["traveltimes"]["items"] {
            
            let time = TravelTimeItem()
            time.routeid = subJson["routeid"].intValue
            time.title = subJson["title"].stringValue
            time.distance = subJson["distance"].floatValue
            time.averageTime = subJson["average"].intValue
            time.currentTime = subJson["current"].intValue
            time.updated = subJson["updated"].stringValue
            
            travelTimes.append(time)
        }
        
        return travelTimes
    }
}
