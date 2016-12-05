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

class BorderWaitStore{

    typealias getBorderWaitsCompletion = (_ error: Error?) -> ()

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
        var delta = TimeUtils.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.borderWaits), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > TimeUtils.updateTime) || force){
            
            Alamofire.request("http://data.wsdot.wa.gov/mobile/BorderCrossings.js").validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
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
    
    fileprivate static func saveWaits(_ waits: [BorderWaitItem]){
        
        let realm = try! Realm()

        do {
            try realm.write{
                realm.add(waits, update: true)
            }
        }catch {
            print("BorderWaitStore.saveWaits: Realm write error")
        }
    }
    
    fileprivate static func parseBorderWaitsJSON(_ json: JSON) ->[BorderWaitItem]{
        var waits = [BorderWaitItem]()
        
        for (_,subJson):(String, JSON) in json["waittimes"]["items"] {
            
            let wait = BorderWaitItem()
            wait.id = subJson["id"].intValue
            wait.waitTime = subJson["wait"].intValue
            wait.name = subJson["name"].stringValue
            wait.route = subJson["route"].intValue
            wait.direction = subJson["direction"].stringValue
            wait.updated = subJson["updated"].stringValue
            wait.lane = subJson["lane"].stringValue
            
            waits.append(wait)
        }
        
        return waits
    }






}
