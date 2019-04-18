//
//  TollRateTableStore.swift
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

class TollRateTableStore {

    typealias getTollRateTablesCompletion  = (_ error: Error?) -> ()

    static func getAllTollRateTables() -> [TollRateTableItem] {
        let realm = try! Realm()
        let tollTableItems = realm.objects(TollRateTableItem.self).filter("delete == false")
        return Array(tollTableItems)
    }
    
    static func getTollRateTableByRoute(route: Int) -> TollRateTableItem? {
        let realm = try! Realm()
        let tollTableItem = realm.objects(TollRateTableItem.self).filter( "delete == false").filter("route == \(route)").first
        return tollTableItem
        
    }
    
    static func updateTollRateTables(_ force: Bool, completion: @escaping getTollRateTablesCompletion) {
    
        var delta = TimeUtils.tollUpdateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.tollRates), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
        
        if ((delta > TimeUtils.updateTime) || force) {
            
            Alamofire.request("http://data.wsdot.wa.gov/mobile/StaticTollRates.js").validate().responseJSON { response in
                switch response.result {
                case .success:
                
                    if let value = response.result.value {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            
                            saveTollRateTables(json)
                            CachesStore.updateTime(CachedData.tollRates, updated: Date())
                        
                            completion(nil)
                        }
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    completion(error)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    fileprivate static func saveTollRateTables(_ json: JSON){
        
        let realm = try! Realm()
        
        let newTolls = List<TollRateTableItem>()
        
        for (_, tollJson):(String, JSON) in json["TollRates"] {
    
            let tollRate = TollRateTableItem()
    
            tollRate.route = tollJson["route"].intValue
            tollRate.message = tollJson["message"].stringValue
            tollRate.numCol = tollJson["numCol"].intValue
            
            for (_, rowJson):(String, JSON) in tollJson["tollTable"] {
            
                let tollRow = TollRateRowItem()
                
                tollRow.header = rowJson["header"].boolValue
                
                for (_, rows):(String, JSON) in rowJson["rows"] {
                    tollRow.rows.append(rows.stringValue)
                }
                
                if rowJson["start_time"].exists() && rowJson["end_time"].exists() {
                    tollRow.startHourString = rowJson["start_time"].stringValue
                    tollRow.endHourString = rowJson["end_time"].stringValue
                }

                if rowJson["weekday"].exists() {
                    tollRow.weekday = rowJson["weekday"].boolValue
                }

                tollRate.tollTable.append(tollRow)
            }
            
            newTolls.append(tollRate)
        }
        
        let oldTolls = getAllTollRateTables()

        do {
            try realm.write{
                for toll in oldTolls {
                    toll.delete = true
                }
                realm.add(newTolls, update: true)
                
            }
        } catch {
            print("TollRateTableStore.saveTollRateTables: Realm write error")
        }
    }
    
    static func flushOldData() {
        let realm = try! Realm()
        let tolls = realm.objects(TollRateTableItem.self).filter("delete == true")
        do {
            try realm.write{
                realm.delete(tolls)
            }
        } catch {
            print("TollRateTableStore.flushOldData: Realm write error")
        }
    }

    static func isTollActive(startHour: String, endHour: String) -> Bool {
    
        let start_time_array = startHour.split(separator: ":")

        if start_time_array.count != 2 {
            return false
        }

        guard let start_hour = Int( start_time_array[0] ) else { return false }
        guard let start_min = Int( start_time_array[1] ) else { return false }

        let end_time_array = endHour.split(separator: ":")
        
        if end_time_array.count != 2  {
            return false
        }
    
        guard let end_hour = Int( end_time_array[0] ) else { return false }
        guard let end_min = Int( end_time_array[1] ) else { return false }
    
        let calendar = Calendar.current
        let now = Date()

        let toll_start = calendar.date(
            bySettingHour: start_hour,
            minute: start_min,
            second: 0,
            of: now)!

        let toll_end = calendar.date(
            bySettingHour: end_hour,
            minute: end_min,
            second: 0,
            of: now)!

        if now >= toll_start && now <= toll_end {
            return true
        }
        
        return false
    }

    static func getSR99data() -> [ThreeColItem] {
        var data = [ThreeColItem]()
    
        var item = ThreeColItem(colOne: "Monday to Friday", colTwo: "Good To Go! Pass", colThree: "Pay By Mail", header: true)
        data.append(item)
        item = ThreeColItem(colOne: "6 AM to 7 AM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 AM to 9 AM", colTwo: "$1.50",colThree: "$3.50",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 AM to 3 PM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "3 PM to 6 PM", colTwo: "$2.25",colThree: "$4.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 11 PM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 6 AM", colTwo: "$1.00",colThree: "$3.00",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "Weekends and Holidays", colTwo: "Good To Go! Pass", colThree: "Pay By Mail",  header: true)
        data.append(item)
        item = ThreeColItem(colOne: "All day", colTwo: "$1.00",colThree: "$3.00",  header: false)
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
