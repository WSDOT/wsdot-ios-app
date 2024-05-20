//
//  BridgeAlertsRealmStore.swift
//  WSDOT
//
//  Copyright (c) 2021 Washington State Department of Transportation
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

class BridgeAlertsStore: Decodable {

    typealias UpdateBridgeAlertsCompletion = (_ error: Error?) -> ()
    
    static func findBridgeAlert(withId: Int) -> BridgeAlertItem? {
        let realm = try! Realm()
        let alertItem = realm.object(ofType: BridgeAlertItem.self, forPrimaryKey: withId)
        return alertItem
    }
    
    static func getAllBridgeAlerts() -> [String : [BridgeAlertItem]] {
        let realm = try! Realm()
        let alertItems = realm.objects(BridgeAlertItem.self).filter("delete == false")
        return sortTopicsByCategory(topics:Array(alertItems))

    }
    
    fileprivate static func sortTopicsByCategory(topics: [BridgeAlertItem]) -> [String : [BridgeAlertItem]]{
    
        var topicCategoriesMap = [String: [BridgeAlertItem]]()
        
        let sortedTopics = topics.sorted(by: {$0.bridge < $1.bridge })
        
        for topic in sortedTopics {
            if topicCategoriesMap[topic.bridge] != nil {
                topicCategoriesMap[topic.bridge]!.append(topic)
            } else {
                topicCategoriesMap[topic.bridge] = [topic]
            }
        }
        
        return topicCategoriesMap
    }


    
    static func updateBridgeAlerts(_ force: Bool, completion: @escaping UpdateBridgeAlertsCompletion) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            var delta = CachesStore.bridgeCacheTime
            let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.bridgeAlerts), to: Date(), options: []).second
        
            if let deltaValue = deltaUpdated {
                delta = deltaValue
            }
         
            if ((delta > CachesStore.bridgeCacheTime) || force) {
            
                let request = NetworkUtils.getJSONRequestNoLocalCache(forUrl: "https://data.wsdot.wa.gov/mobile/BridgeOpenings.js")
                
                AF.request(request).validate().responseDecodable(of: BridgeAlertsStore.self) { response in
                    switch response.result {
                    case .success:
                        if let value = response.data {
                            DispatchQueue.global().async {
                                let json = JSON(value)
                                self.saveBridgeAlerts(json)
                                CachesStore.updateTime(CachedData.bridgeAlerts, updated: Date())
                                completion(nil)
                            }
                        }
                    case .failure(let error):
                        print("error")
                        print(error)
                        completion(error)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    fileprivate static func saveBridgeAlerts(_ json: JSON){
        
        let realm = try! Realm()
        
        let newAlerts = List<BridgeAlertItem>()
        
        for (_, alertJson):(String, JSON) in json {
        
            let alert = BridgeAlertItem()

            alert.alertId = alertJson["BridgeOpeningId"].intValue
            alert.descText = alertJson["EventText"].stringValue
            alert.status = alertJson["Status"].stringValue
            alert.duration = alertJson["Duration"].stringValue
            alert.priority = alertJson["Priority"].stringValue
            alert.travelCenterPriorityId = alertJson["TravelCenterPriorityId"].intValue
            alert.eventCategory = alertJson["EventCategory"].stringValue
            alert.bridge = alertJson["BridgeLocation"]["Description"].stringValue
            alert.descText = alertJson["EventText"].stringValue
            alert.status = alertJson["Status"].stringValue
            alert.latitude = alertJson["BridgeLocation"]["Latitude"].doubleValue
            alert.longitude = alertJson["BridgeLocation"]["Longitude"].doubleValue
            alert.milepost = alertJson["BridgeLocation"]["MilePost"].doubleValue
            alert.direction = alertJson["BridgeLocation"]["Direction"].stringValue
            alert.roadName = alertJson["BridgeLocation"]["RoadName"].stringValue
            if let timeJsonStringValue = alertJson["OpeningTime"].string {
                do {
                    alert.openingTime =
                        try TimeUtils.formatTimeStamp(timeJsonStringValue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss") //ex. 2021-04-06T22:00:00
                } catch {
                    print("error formatting date")
                }
            }

            alert.localCacheDate = Date()
            
            // Update "Hood Canal" bridge name to display "Hood Canal Bridge"
                       if (alert.bridge == "Hood Canal") {
                           alert.bridge = "Hood Canal Bridge"
                       }
            
            newAlerts.append(alert)
        }
        
        let oldAlerts = realm.objects(BridgeAlertItem.self)
        
        do {
            try realm.write{
                for alert in oldAlerts {
                    alert.delete = true
                }
                realm.add(newAlerts, update: .all)
            }
        }catch{
            print("BridgeAlertsStore.saveAlerts: Realm write error")
        }
    }
    
    static func flushOldData() {
        let realm = try! Realm()
        let alerts = realm.objects(BridgeAlertItem.self).filter("delete == true")
        do {
            try realm.write{
                realm.delete(alerts)
            }
        }catch{
            print("BridgeAlertsStore.flushOldData: Realm write error")
        }
    }

}

