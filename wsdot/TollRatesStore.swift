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

class TollRatesStore {

    typealias getTollRatesCompletion  = (_ error: Error?) -> ()

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
    
    static func getAllTollRates() -> [TollRateSignItem]{
        let realm = try! Realm()
        let tollSignItems = realm.objects(TollRateSignItem.self).filter("delete == false")
        return Array(tollSignItems)
    }
    
    static func getTollRatesByRoute(route: String) -> [TollRateSignItem]{
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
    
    static func findFavoriteTolls() -> [TollRateSignItem]{
        let realm = try! Realm()
        let favoriteTollSignItems = realm.objects(TollRateSignItem.self).filter("selected == true").filter("delete == false")
        return Array(favoriteTollSignItems).sorted(by: { $0.travelDirection < $1.travelDirection }).sorted(by: {$0.stateRoute < $1.stateRoute})
    }

    static func updateTollRates(_ force: Bool, completion: @escaping getTollRatesCompletion) {
    
        var delta = TimeUtils.tollUpdateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.tollRates), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > TimeUtils.updateTime) || force) {
            
            Alamofire.request("http://wsdot.com/traffic/api/api/tolling?accesscode=" + ApiKeys.getWSDOTKey()).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            let tollRates = TollRatesStore.parseTollRatesJSON(json)
                            if tollRates.count != 0 {
                                saveTollRates(tollRates)
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
    fileprivate static func saveTollRates(_ tollSigns: [TollRateSignItem]){
        
        let realm = try! Realm()
        
        let oldFavoriteTolls = self.findFavoriteTolls()
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
                realm.add(newTolls, update: true)
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
    fileprivate static func parseTollRatesJSON(_ json: JSON) -> [TollRateSignItem]{
        
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

    static func getSR520data() -> [ThreeColItem] {
        var data = [ThreeColItem]()
        
        var item = ThreeColItem(colOne: "Monday to Friday", colTwo: "Good To Go! Pass", colThree: "Pay By Mail", header: true)
        data.append(item)
        item = ThreeColItem(colOne: "Midnight to 5 AM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "5 AM to 6 AM", colTwo: "$2.00",colThree: "$4.00",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 AM to 7 AM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 AM to 9 AM", colTwo: "$4.30",colThree: "$6.30",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 AM to 10 AM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "10 AM to 2 PM", colTwo: "$2.70",colThree: "$4.70",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "2 PM to 3 PM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "3 PM to 6 PM", colTwo: "$4.30",colThree: "$6.30",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 7 PM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 PM to 9 PM", colTwo: "$2.70",colThree: "$4.70",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 PM to 11 PM", colTwo: "$2.00",colThree: "$4.00",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 11:59 PM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "Weekends and Holidays", colTwo: "Good To Go! Pass", colThree: "Pay By Mail",  header: true)
        data.append(item)
        item = ThreeColItem(colOne: "Midnight to 5 AM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "5 AM to 8 AM", colTwo: "$1.40",colThree: "$3.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "8 AM to 11 AM", colTwo: "$2.05",colThree: "$4.05",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 AM to 6 PM", colTwo: "$2.65",colThree: "$4.65",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 9 PM", colTwo: "$2.05",colThree: "$4.05",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 PM to 11 PM", colTwo: "$1.40",colThree: "$3.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 11:59 PM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        return data
    }

    static func getSR16data() -> [FourColItem]{
        var data = [FourColItem]()
        
        var item = FourColItem(colOne: "Number of Axles", colTwo: "Good To Go! Pass",colThree: "Cash", colFour: "Pay By Mail", header: true)
        data.append(item)
        item = FourColItem(colOne: "Two (includes motorcycle)", colTwo: "$5.00",colThree: "$6.00", colFour: "$7.00", header: false)
        data.append(item)
        item = FourColItem(colOne: "Three", colTwo: "$7.50",colThree: "$9.00", colFour: "$10.50", header: false)
        data.append(item)
        item = FourColItem(colOne: "Four", colTwo: "$10.00",colThree: "$12.00", colFour: "$14.00", header: false)
        data.append(item)
        item = FourColItem(colOne: "Five", colTwo: "$12.50",colThree: "$15.00", colFour: "$17.50", header: false)
        data.append(item)
        item = FourColItem(colOne: "Six or more", colTwo: "$15.00",colThree: "$18.00", colFour: "$21.00", header: false)
        data.append(item)
        return data
    }
    
    static func getTollIndexForNow() -> Int {
    
        let today = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let date24 = dateFormatter.string(from: today)
        
        guard let hour = Int(date24) else {
            return -1
        }
    
        if today.isWeekend || today.is_WAC_468_270_071_Holiday {
    
            switch (hour) {
            case 0...4:
                // print("midnight to 5 am")
                return 14
            case 5...7:
                // print("5 am to 8 am")
                return 15
            case 8...10:
                // print("8 am to 11 am")
                return 16
            case 11...17:
                // print("11 am to 6 pm")
                return 17
            case 18...20:
                // print("6 pm to 9 pm")
                return 18
            case 21...22:
                // print("9 pm to 11 pm")
                return 19
            case 23:
                // print("11 pm")
                return 20
            default:
                return -1
            }
            
        } else {
        
            switch (hour) {
            case 0...4:
                // rint("Midnight to 5 am")
                return 1
            case 5:
                // print("5am to 6am")
                return 2
            case 6:
                // print("6am to 7am")
                return 3
            case 7...8:
                // print("7am to 9am")
                return 4
            case 9:
                // print("9am to 10am")
                return 5
            case 10...13:
                // print("10am to 2pm")
                return 6
            case 14:
                // print("2pm to 3pm")
                return 7
            case 15...17:
                // print("3pm to 6pm")
                return 8
            case 18:
                // print("6pm to 7pm")
                return 9
            case 19...20:
                // print("7pm to 9pm")
                return 10
            case 21...22:
                // print("9pm to 11pm")
                return 11
            case 23:
                // print("11pm")
                return 12
            default:
                return -1
            }
        }
    }
}

struct FourColItem{
    let colOne: String
    let colTwo: String
    let colThree: String
    let colFour: String
    let header: Bool
}

struct ThreeColItem{
    let colOne: String
    let colTwo: String
    let colThree: String
    let header: Bool
}


extension Date {

    var isWeekend: Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        
        if (components.weekday == 1) || (components.weekday == 0) {
           return true
        } else {
           return false
        }
    }

    var is_WAC_468_270_071_Holiday: Bool {

        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .weekdayOrdinal], from: self)
        guard let year = components.year,
            let month = components.month,
            let day = components.day,
            let weekday = components.weekday,
            let weekdayOrdinal = components.weekdayOrdinal else { return false }

        let memorialDay = Date.dateComponentsForMemorialDay(year: year)?.day ?? -1

        // weekday is Sunday==1 ... Saturday==7
        // weekdayOrdinal is nth instance of weekday in month
        switch (month, day, weekday, weekdayOrdinal) {
          case (1, 1, _, _): return true                // Happy New Years
          case (5, memorialDay, _, _): return true      // Memorial Day
          case (7, 4, _, _): return true                // Independence Day
          case (9, _, 2, 1): return true                // Labor Day - 1st Mon in Sept
          case (11, _, 5, 4): return true               // Happy Thanksgiving - 4th Thurs in Nov
          case (12, 25, _, _): return true              // Happy Holidays
          default: return false
        }
    }

    static func dateComponentsForMemorialDay(year: Int) -> DateComponents? {
        guard let memorialDay = Date.memorialDay(year: year) else { return nil }
        return NSCalendar.current.dateComponents([.year, .month, .day, .weekday, .weekdayOrdinal], from: memorialDay)
    }

    static func memorialDay(year: Int) -> Date? {
        let calendar = Calendar.current
        var firstMondayJune = DateComponents()
        firstMondayJune.month = 6
        firstMondayJune.weekdayOrdinal = 1  // 1st in month
        firstMondayJune.weekday = 2 // Monday
        firstMondayJune.year = year
        guard let refDate = calendar.date(from: firstMondayJune) else { return nil }
        var timeMachine = DateComponents()
        timeMachine.weekOfMonth = -1
        return calendar.date(byAdding: timeMachine, to: refDate)
    }
}
