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

    typealias UpdateHighwayAlertsCompletion = (error: NSError?) -> ()
    
    static func getAllAlerts() -> [HighwayAlertItem]{
        let realm = try! Realm()
        let alertItems = realm.objects(HighwayAlertItem.self)
        return Array(alertItems)
    }
    
    static func getHighestPriorityAlerts() -> [HighwayAlertItem]{
        let realm = try! Realm()
        let alertItems = realm.objects(HighwayAlertItem.self).filter("priority == \"Highest\"")
        return Array(alertItems)
    }
    
    static func updateAlerts(force: Bool, completion: UpdateHighwayAlertsCompletion) {
        
        let deltaUpdated = NSCalendar.currentCalendar().components(.Second, fromDate: CachesStore.getUpdatedTime(CachedData.HighwayAlerts), toDate: NSDate(), options: []).second
        
        if ((deltaUpdated > TimeUtils.updateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/HighwayAlerts.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                            let json = JSON(value)
                            self.saveAlerts(json)
                            CachesStore.updateTime(CachedData.HighwayAlerts, updated: NSDate())
                            completion(error: nil)
                        }
                    }
                case .Failure(let error):
                    print(error)
                    completion(error: error)
                }
            }
        }else{
            completion(error: nil)
        }
    }
    
    private static func saveAlerts(json: JSON){
        
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
        
        do {
            try realm.write{
                realm.delete(realm.objects(HighwayAlertItem))
                realm.add(newAlerts, update: true)
            }
        }catch{
            print("HighwayAlertsStore.saveAlerts: Realm write error")
        }
    }
}