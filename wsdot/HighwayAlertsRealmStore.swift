//
//  HighwayAlertsRealmStore.swift
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
import RealmSwift
import Alamofire
import SwiftyJSON

class HighwayAlertsStore {

    typealias UpdateHighwayAlertsCompletion = (_ error: Error?) -> ()
    
    static func getAllAlerts() -> [HighwayAlertItem]{
        let realm = try! Realm()
        let alertItems = realm.objects(HighwayAlertItem.self).filter("delete == false")
        return Array(alertItems)
    }
    
    static func getHighestPriorityAlerts() -> [HighwayAlertItem]{
        let realm = try! Realm()
        let alertItems = realm.objects(HighwayAlertItem.self).filter("priority == \"Highest\"").filter("delete == false")
        return Array(alertItems)
    }
    
    static func updateAlerts(_ force: Bool, completion: @escaping UpdateHighwayAlertsCompletion) {
        var delta = TimeUtils.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.highwayAlerts), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > TimeUtils.alertsCacheTime) || force){
            
            Alamofire.request("http://data.wsdot.wa.gov/mobile/HighwayAlerts.js").validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            self.saveAlerts(json)
                            CachesStore.updateTime(CachedData.highwayAlerts, updated: Date())
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(error)
                }
            }
        }else{
            completion(nil)
        }
    }
    
    fileprivate static func saveAlerts(_ json: JSON){
        
        let realm = try! Realm()
        
        let newAlerts = List<HighwayAlertItem>()
        
        for (_, alertJson):(String, JSON) in json["alerts"]["items"] {
        
            let alert = HighwayAlertItem()
            
            alert.alertId = alertJson["AlertID"].intValue
            alert.priority = alertJson["Priority"].stringValue
            alert.region = alertJson["Region"].stringValue
            alert.eventCategory = alertJson["EventCategory"].stringValue
            alert.headlineDesc = alertJson["HeadlineDescription"].stringValue
            alert.eventStatus = alertJson["EventStatus"].stringValue
            alert.startDirection = alertJson["StartRoadwayLocation"]["Direction"].stringValue
            alert.lastUpdatedTime = TimeUtils.parseJSONDateToNSDate(alertJson["LastUpdatedTime"].stringValue)
            alert.startTime = TimeUtils.parseJSONDateToNSDate(alertJson["StartTime"].stringValue)
            alert.startLatitude = alertJson["StartRoadwayLocation"]["Latitude"].doubleValue
            alert.startLongitude = alertJson["StartRoadwayLocation"]["Longitude"].doubleValue
            alert.endLatitude = alertJson["EndRoadwayLocation"]["Latitude"].doubleValue
            alert.endLongitude = alertJson["EndRoadwayLocation"]["Longitude"].doubleValue
            
            alert.county = alertJson["County"].string
            
            if let endTimeJsonStringValue = alertJson["EndTime"].string {
                alert.endTime = TimeUtils.parseJSONDateToNSDate(endTimeJsonStringValue)
            }

            alert.extendedDesc = alertJson["ExtendedDescription"].string
            
            newAlerts.append(alert)
        }
        
        let oldAlerts = getAllAlerts()
        
        
        do {
            try realm.write{
                for alert in oldAlerts {
                    alert.delete = true
                }
                realm.add(newAlerts, update: true)
            }
        }catch{
            print("HighwayAlertsStore.saveAlerts: Realm write error")
        }
    }
    
    static func flushOldData() {
        let realm = try! Realm()
        let alerts = realm.objects(HighwayAlertItem.self).filter("delete == true")
        do {
            try realm.write{
                realm.delete(alerts)
            }
        }catch{
            print("HighwatAlertsStore.flushOldData: Realm write error")
        }
    }

}
