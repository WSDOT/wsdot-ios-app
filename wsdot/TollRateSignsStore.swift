//
//  TollRatesModel.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

class TollRateSignsStore {

    typealias getTollRateSignsCompletion  = (_ error: Error?) -> ()

    static func updateFavorite(_ tollSign: TollRateSignItem, newValue: Bool){
        do {
            let realm = try Realm()
            try realm.write{
                tollSign.selected = newValue
            }
        } catch {
            print("TollRatesStore.updateFavorite: Realm write error")
        }
    }
    
    static func getAllTollRateSigns() -> [TollRateSignItem]{
        let realm = try! Realm()
        let tollSignItems = realm.objects(TollRateSignItem.self).filter("delete == false")
        return Array(tollSignItems)
    }
    
    static func getTollRateSignsByRoute(route: String) -> [TollRateSignItem]{
        let realm = try! Realm()
        let tollSignItems = realm.objects(TollRateSignItem.self).filter("delete == false").filter("stateRoute == \(route)")
        
        
        
        return Array(tollSignItems.sorted(by: {$0.startLocationName < $1.startLocationName}).sorted(by: { $0.travelDirection < $1.travelDirection }))
    }
    
    static func getSouthboundTollRatesByRoute(route: String) -> [TollRateSignItem]{
        let realm = try! Realm()

        let tollSignItems = realm.objects(TollRateSignItem.self).filter("delete == false").filter("stateRoute == \(route)").filter("travelDirection == 'S'")
        return Array(tollSignItems.sorted(by: { $0.milepost > $1.milepost }))
        
    }
    
    static func getNorthboundTollRatesByRoute(route: String) -> [TollRateSignItem]{
        let realm = try! Realm()
        let tollSignItems = realm.objects(TollRateSignItem.self).filter("delete == false").filter("stateRoute == \(route)").filter("travelDirection == 'N'")
        return Array(tollSignItems.sorted(by: { $0.milepost < $1.milepost }))
    }
    
    static func findFavoriteTollSigns() -> [TollRateSignItem]{
        let realm = try! Realm()
        let favoriteTollSignItems = realm.objects(TollRateSignItem.self).filter("selected == true").filter("delete == false")
        return Array(favoriteTollSignItems).sorted(by: { $0.travelDirection < $1.travelDirection }).sorted(by: {$0.stateRoute < $1.stateRoute})
    }

    static func updateTollRateSigns(_ force: Bool, completion: @escaping getTollRateSignsCompletion) {
    
        var delta = CachesStore.tollUpdateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.tollRates), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > CachesStore.updateTime) || force) {
            
            let request = NetworkUtils.getJSONRequestNoLocalCache(forUrl: "https://wsdot.com/traffic/api/api/tolling?accesscode=" + ApiKeys.getWSDOTKey())
            
            AF.request(request).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.data {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            let tollRates = TollRateSignsStore.parseTollRateSignsJSON(json)
                            if tollRates.count != 0 {
                                saveTollRateSigns(tollRates)
                                CachesStore.updateTime(CachedData.tollRates, updated: Date())
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
    fileprivate static func saveTollRateSigns(_ tollSigns: [TollRateSignItem]){
        
        let realm = try! Realm()
        
        let oldFavoriteTolls = self.findFavoriteTollSigns()
        let newTolls = List<TollRateSignItem>()
        
        for tollSign in tollSigns {
            for oldTollSign in oldFavoriteTolls {
                if (oldTollSign.compoundKey == tollSign.compoundKey){
                    tollSign.selected = true
                }
            }
            newTolls.append(tollSign)
        }
        
        let oldTolls = realm.objects(TollRateSignItem.self)
        
        do {
            try realm.write{
                for sign in oldTolls {
                    sign.delete = true
                }
                realm.add(newTolls, update: .all)
            }
        }catch {
            print("TollRatesStore.saveTollRates: Realm write error")
        }
    }
    
    static func flushOldData(){
        do {
            let realm = try Realm()
            let tollItems = realm.objects(TollRateSignItem.self).filter("delete == true")
            try! realm.write{
                realm.delete(tollItems)
            }
        }catch {
            print("TollRatesStore.flushOldData: Realm write error")
        }
    }
    
    // Converts JSON from api into and array of FerriesRouteScheduleItems
    fileprivate static func parseTollRateSignsJSON(_ json: JSON) -> [TollRateSignItem]{
        
        var tollRates = [TollRateSignItem]()
        
        for (_,subJson):(String, JSON) in json {
            
            if !shouldSkipTrip(tripJson: subJson) {
            
                // get this trip item
                let tripItem = TollTripItem()
            
                tripItem.tripName = subJson["TripName"].stringValue
                tripItem.endLocationName = subJson["EndLocationName"].stringValue
                tripItem.endMilepost = subJson["EndMilepost"].intValue
                tripItem.toll = subJson["CurrentToll"].floatValue / 100
                tripItem.message = subJson["CurrentMessage"].stringValue
                tripItem.endLatitude = subJson["EndLatitude"].doubleValue
                tripItem.endLongitude = subJson["EndLongitude"].doubleValue
            
                // check if we already have a sign item for this start location
                let signItems = tollRates.filter { $0.compoundKey == (subJson["StartLocationName"].stringValue + "-" + subJson["TravelDirection"].stringValue) }
                
                if !signItems.isEmpty {
                    
                    signItems[0].trips.append(tripItem)
                    
                    if signItems[0].travelDirection == "N" {
                        let sortedTrips = signItems[0].trips.sorted{ return $0.endMilepost < $1.endMilepost }
                        signItems[0].trips.removeAll()
                        signItems[0].trips.append(objectsIn: sortedTrips)
                    } else {
                        let sortedTrips = signItems[0].trips.sorted{ return $0.endMilepost > $1.endMilepost }
                        signItems[0].trips.removeAll()
                        signItems[0].trips.append(objectsIn: sortedTrips)
                    }
                    
                } else {
                    let tollRate = TollRateSignItem()
                
                    tollRate.setCompoundLocationName(name: subJson["StartLocationName"].stringValue)
                    tollRate.setCompoundTravelDirection(direction: subJson["TravelDirection"].stringValue)
                
                    if subJson["StateRoute"].intValue == 405 {
                        tollRate.locationTitle = get405LocationTitle(location: subJson["StartLocationName"].stringValue, direction: subJson["TravelDirection"].stringValue)
                    } else if subJson["StateRoute"].intValue == 167 {
                        tollRate.locationTitle = get167LocationTitle(location: subJson["StartLocationName"].stringValue, direction: subJson["TravelDirection"].stringValue)
                    }
     
                    tollRate.milepost = subJson["StartMilepost"].intValue
                    tollRate.stateRoute = subJson["StateRoute"].intValue
                    tollRate.startLatitude = subJson["StartLatitude"].doubleValue
                    tollRate.startLongitude = subJson["StartLongitude"].doubleValue
                    tollRate.trips.append(tripItem)
                    tollRates.append(tollRate)
                    
                }
            }
        }
        
        return tollRates.sorted(by: { $0.startLocationName < $1.startLocationName }).sorted(by: { $0.travelDirection < $1.travelDirection })
    }
    
    static func shouldSkipTrip(tripJson: JSON) -> Bool {
    
        /*
         * 405 trips to skip
         *
         * Removal of these routes since their displays are already shown
         * by other signs from the API.
         */
        if tripJson["StartLocationName"].stringValue == "NE 6th"
            && tripJson["TravelDirection"].stringValue == "N" {
            return true
        }

        if tripJson["StartLocationName"].stringValue == "216th ST SE"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }

        if tripJson["StartLocationName"].stringValue == "NE 145th"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }
        
        /*
         * Removal suggested by tolling division since it's very similar to another location
         * and difficult to come up with a label people will recognize.
         */
        if tripJson["StartLocationName"].stringValue == "NE 108th"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }
        
        // 167 trips to skip - Tolling suggested removal of these signs
        if tripJson["StartLocationName"].stringValue == "James St"
                && tripJson["TravelDirection"].stringValue == "N" {
            return true;
        }
        
        if tripJson["StartLocationName"].stringValue == "S 204th St"
                && tripJson["TravelDirection"].stringValue == "N" {
            return true;
        }
        
        if tripJson["StartLocationName"].stringValue == "1st Ave S"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }
        
        if tripJson["StartLocationName"].stringValue == "12th St NW"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }
        
        if tripJson["StartLocationName"].stringValue == "37th St NW"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }
        
        if tripJson["StartLocationName"].stringValue == "Green River"
                && tripJson["TravelDirection"].stringValue == "S" {
            return true;
        }

        return false;
    }

    // Changes names from API to common names suggested by tolling
    static func get405LocationTitle(location: String, direction: String) -> String {
    
        var title = location
    
        // Southbound name changes
        if direction == "S" {
            if location == "231st SE" {
                title = "SR 527"
            }

            if location == "NE 53rd" {
                title = "NE 70th Place"
            }
        }

        // Northbound name changes
        if direction == "N" {
            if location == "NE 97th" {
                title = "NE 85th St"
            }

            if location == "231st SE" {
                title = "SR 522"
            }

            if location == "216th SE" {
                title = "SR 527"
            }
        }

        if location == "SR 524" || location == "NE 4th" {
            let city = (direction == "N" ? "Bellevue" : "Lynnwood")
            title = "\(city) - Start of toll lanes"
        } else {
            title = "Lane entrance near \(title)"
        }
    
        return title
    }
    
    // Changes names from API to common names suggested by tolling
    static func get167LocationTitle(location: String, direction: String) -> String {
    
        var title = location
    
        // Southbound name changes
        if direction == "S" {
            if location == "4th Ave N" {
                title = "SR 516"
            }
            
            if location == "S 192nd St" {
                title = "S 180th St"
            }
            
            if location == "S 23rd St" {
                title = "I-405 (Renton)"
            }
        }

        // Northbound name changes
        if direction == "N" {
            if location == "15th St SW" {
                title = "SR 18 (Auburn)"
            }
            if location == "7th St NW" {
                title = "15th St SW"
            }
            if location == "30th St NW" {
                title = "S 277th St"
            }
            if location == "S 265th St" {
                title = "SR 516"
            }
        }

        title = "Lane entrance near \(title)"
    
        return title
    }

}
