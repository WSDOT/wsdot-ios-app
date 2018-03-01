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
    
    typealias getTravelTimesCompletion = (_ error: Error?) -> ()
    
    static func updateFavorite(_ timeGroup: TravelTimeItemGroup, newValue: Bool){
        do {
            let realm = try Realm()
            try realm.write{
                timeGroup.selected = newValue
            }
        } catch {
            print("TravelTimesStore.updateFavorite: Realm write error")
        }
    }
    
    static func getAllTravelTimeGroups() -> [TravelTimeItemGroup]{
        let realm = try! Realm()
        let travelTimeItems = realm.objects(TravelTimeItemGroup.self).filter("delete == false")
        return Array(travelTimeItems)
    }
    
    static func findFavoriteTimes() -> [TravelTimeItemGroup]{
        let realm = try! Realm()
        let favoriteTimeItems = realm.objects(TravelTimeItemGroup.self).filter("selected == true").filter("delete == false")
        return Array(favoriteTimeItems)
    }
    
    static func updateTravelTimes(_ force: Bool, completion: @escaping getTravelTimesCompletion) {
        var delta = TimeUtils.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.travelTimes), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > TimeUtils.updateTime) || force) {
            
            Alamofire.request("http://data.wsdot.wa.gov/mobile/TravelTimesv2.js").validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            let travelTimes = TravelTimesStore.parseTravelTimesJSON(json)
                            if travelTimes.count != 0 {
                                saveTravelTimes(travelTimes)
                                CachesStore.updateTime(CachedData.travelTimes, updated: Date())
                            }
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(error)
                }
                
            }
        }else {
            completion(nil)
        }
    }
    
    // TODO: Make this smarter
    fileprivate static func saveTravelTimes(_ travelTimes: [TravelTimeItemGroup]){
        
        let realm = try! Realm()
        
        let oldFavoriteTimes = self.findFavoriteTimes()
        let newTimes = List<TravelTimeItemGroup>()
        
        for time in travelTimes {
            for oldTime in oldFavoriteTimes {
                if (oldTime.title == time.title){
                    time.selected = true
                }
            }
            newTimes.append(time)
        }
        
        let oldTimes = realm.objects(TravelTimeItemGroup.self)
        
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
            let timeItems = realm.objects(TravelTimeItemGroup.self).filter("delete == true")
            try! realm.write{
                realm.delete(timeItems)
            }
        }catch {
            print("TravelTimesStore.flushOldData: Realm write error")
        }
    }
    
    fileprivate static func parseTravelTimesJSON(_ json: JSON) ->[TravelTimeItemGroup]{
        var travelTimes = [TravelTimeItemGroup]()
        
        for (_,subJson):(String, JSON) in json {
   
            let time = TravelTimeItem()
            time.routeid = subJson["routeid"].intValue
            
            time.viaText = subJson["via"].stringValue.replacingOccurrences(of: "REV", with: "EXPRESS", options: .literal).replacingOccurrences(of: ",", with: ", ", options: .literal)
            
            time.startLatitude = subJson["startLocationLatitude"].doubleValue
            time.startLongitude = subJson["startLocationLongitude"].doubleValue
            
            time.endLatitude = subJson["endLocationLatitude"].doubleValue
            time.endLongitude = subJson["endLocationLatitude"].doubleValue
            
            time.distance = subJson["miles"].floatValue
            time.averageTime = subJson["avg_time"].intValue
            time.status = subJson["status"].stringValue
            time.currentTime = subJson["current_time"].intValue
        
            time.updated = subJson["updated_at"].stringValue
        
            let timeGroupResult = travelTimes.filter { $0.title == subJson["title"].string }
            let timeGroup = timeGroupResult.first ?? TravelTimeItemGroup()
            timeGroup.title = subJson["title"].string!
        
            timeGroup.routes.append(time)
            travelTimes.append(timeGroup)
        }
        
        return travelTimes
    }
}
