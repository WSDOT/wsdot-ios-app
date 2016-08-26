//
//  BorderWaitRealmStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

class BorderWaitStore{

    typealias getBorderWaitsCompletion = (error: NSError?) -> ()

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
    
    static func updateWaits(force: Bool, completion: getBorderWaitsCompletion) {
        
        let deltaUpdated = NSCalendar.currentCalendar().components(.Second, fromDate: CachesStore.getUpdatedTime(CachedData.BorderWaits), toDate: NSDate(), options: []).second
        
        if ((deltaUpdated > TimeUtils.updateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/BorderCrossings.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                            let json = JSON(value)
                            let waits = BorderWaitStore.parseBorderWaitsJSON(json)
                            saveWaits(waits)
                            CachesStore.updateTime(CachedData.BorderWaits, updated: NSDate())
                            completion(error: nil)
                        }
                    }
                case .Failure(let error):
                    print(error)
                    completion(error: error)
                }
                
            }
        }else {
            completion(error: nil)
        }
    }
    
    private static func saveWaits(waits: [BorderWaitItem]){
        
        let realm = try! Realm()

        do {
            try realm.write{
                realm.add(waits, update: true)
            }
        }catch {
            print("BorderWaitStore.saveWaits: Realm write error")
        }
    }
    
    private static func parseBorderWaitsJSON(json: JSON) ->[BorderWaitItem]{
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