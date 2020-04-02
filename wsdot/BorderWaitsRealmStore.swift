//
//  BorderWaitRealmStore.swift
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

class BorderWaitStore {

    typealias getBorderWaitsCompletion = (_ error: Error?) -> ()

    static func updateFavorite(_ borderWait: BorderWaitItem, newValue: Bool){
        do {
            let realm = try Realm()
            try realm.write{
                borderWait.selected = newValue
            }
        } catch {
            print("BorderWaitStore.updateFavorite: Realm write error")
        }
    }
    
    static func getFavoriteWaits() -> [BorderWaitItem]{
        let realm = try! Realm()
        let favoriteBorderWaitItems = realm.objects(BorderWaitItem.self).filter("selected == true")
        return Array(favoriteBorderWaitItems)
    }

    static func getNorthboundWaits() -> [BorderWaitItem]{
        let realm = try! Realm()
        let waitItems = realm.objects(BorderWaitItem.self).filter("direction == \"northbound\"")
        return Array(waitItems)
    }
    
    static func getSouthboundWaits() -> [BorderWaitItem]{
        let realm = try! Realm()
        let waitItems = realm.objects(BorderWaitItem.self).filter("direction == \"southbound\"")
        return Array(waitItems)
    }
    
    static func updateWaits(_ force: Bool, completion: @escaping getBorderWaitsCompletion) {
        var delta = CachesStore.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.borderWaits), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > CachesStore.updateTime) || force){
            
            let request = NetworkUtils.getNoCacheJSONRequest(forUrl: "https://data.wsdot.wa.gov/mobile/BorderCrossings.js")
        
            AF.request(request).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.data {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            let waits = BorderWaitStore.parseBorderWaitsJSON(json)
                            saveWaits(waits)
                            CachesStore.updateTime(CachedData.borderWaits, updated: Date())
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
    
    fileprivate static func saveWaits(_ waits: [BorderWaitItem]) {
        
        let realm = try! Realm()
        
        let oldFavoriteWaits = self.getFavoriteWaits()
        
        for wait in waits {
            if (oldFavoriteWaits.filter{ $0.id == wait.id}.first != nil) {
                wait.selected = true
            }
        }
        
        let oldWaits = self.getNorthboundWaits() + self.getSouthboundWaits()
        
        do {
            try realm.write{
                // mark old waits for removal. This will get over written if the new waits include updates for old ones.
                for oldWait in oldWaits {
                    oldWait.delete = true
                }
                realm.add(waits, update: .all)
            }
        }catch {
            print("TravelTimesStore.saveTravelTimes: Realm write error")
        }
    }
    
    static func flushOldData(){
        do {
            let realm = try Realm()
            let waits = realm.objects(BorderWaitItem.self).filter("delete == true")
            try! realm.write{
                realm.delete(waits)
            }
        }catch {
            print("BorderWaitsRealmStore.flushOldData: Realm write error")
        }
    }
    
    
    fileprivate static func parseBorderWaitsJSON(_ json: JSON) ->[BorderWaitItem]{
        var waits = [BorderWaitItem]()
        
        for (_,subJson):(String, JSON) in json["waittimes"]["items"] {
            
            // only add northbound until we can get more accurate southbound
            if (subJson["direction"].stringValue.lowercased() == "northbound") {
            
                let wait = BorderWaitItem()
                wait.id = subJson["id"].intValue
                wait.waitTime = subJson["wait"].intValue
                wait.name = subJson["name"].stringValue
                wait.route = subJson["route"].intValue
                wait.direction = subJson["direction"].stringValue
                wait.updated = subJson["updated"].stringValue
                wait.lane = subJson["lane"].stringValue
                wait.delete = false
            
                waits.append(wait)
            }
        }
        
        return waits
    }
}
