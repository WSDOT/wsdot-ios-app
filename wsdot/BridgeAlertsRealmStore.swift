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

class BridgeAlertsStore {

    typealias UpdateBridgeAlertsCompletion = (_ error: Error?) -> ()
    
    static func findBridgeAlert(withId: Int) -> BridgeAlertItem? {
        let realm = try! Realm()
        let alertItem = realm.object(ofType: BridgeAlertItem.self, forPrimaryKey: withId)
        return alertItem
    }
    
    static func getAllBridgeAlerts() -> [BridgeAlertItem]{
        let realm = try! Realm()
        let alertItems = realm.objects(BridgeAlertItem.self).filter("delete == false")
        return Array(alertItems)
    }

    
    static func updateBridgeAlerts(_ force: Bool, completion: @escaping UpdateBridgeAlertsCompletion) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            var delta = CachesStore.updateTime
            let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.bridgeAlerts), to: Date(), options: []).second
        
            if let deltaValue = deltaUpdated {
                delta = deltaValue
            }
         
            if ((delta > CachesStore.bridgeCacheTime) || force) {
            
                let request = NetworkUtils.getJSONRequestNoLocalCache(forUrl: "https://data.wsdot.wa.gov/mobile/BridgeOpeningsTEST.js")
                
                AF.request(request).validate().responseJSON { response in
                    switch response.result {
                    case .success:
                        print("success")
                        if let value = response.data {
                            DispatchQueue.global().async {
                                let json = JSON(value)
                                print(json)
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
            alert.bridge = alertJson["BridgeLocation"]["Description"].stringValue
            alert.descText = alertJson["EventText"].stringValue
            alert.latitude = alertJson["BridgeLocation"]["Latitude"].doubleValue
            alert.longitude = alertJson["BridgeLocation"]["Longitude"].doubleValue
         
            if let timeJsonStringValue = alertJson["openingTime"].string {
                alert.openingTime = TimeUtils.parseJSONDateToNSDate(timeJsonStringValue)
            }

            alert.localCacheDate = Date()
            
            newAlerts.append(alert)
        }
        
        let oldAlerts = getAllBridgeAlerts()
        
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

