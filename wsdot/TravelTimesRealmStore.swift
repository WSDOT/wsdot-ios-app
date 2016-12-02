//
//  TravelTimesRealmStore.swift
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
import SwiftyJSON
import RealmSwift
import Alamofire

class TravelTimesStore{
    
    typealias getTravelTimesCompletion = (_ error: NSError?) -> ()
    
    static func updateFavorite(_ route: TravelTimeItem, newValue: Bool){
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
        let travelTimeItems = realm.objects(TravelTimeItem.self).filter("delete == false")
        return Array(travelTimeItems)
    }
    
    static func findFavoriteTimes() -> [TravelTimeItem]{
        let realm = try! Realm()
        let favoriteTimeItems = realm.objects(TravelTimeItem.self).filter("selected == true").filter("delete == false")
        return Array(favoriteTimeItems)
    }
    
    static func updateTravelTimes(_ force: Bool, completion: @escaping getTravelTimesCompletion) {
        var delta = TimeUtils.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.travelTimes), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > TimeUtils.updateTime) || force){
            
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
            completion(nil)
        }
    }
    
    // TODO: Make this smarter
    fileprivate static func saveTravelTimes(_ travelTimes: [TravelTimeItem]){
        
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
    
    fileprivate static func parseTravelTimesJSON(_ json: JSON) ->[TravelTimeItem]{
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
