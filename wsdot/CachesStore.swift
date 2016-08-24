//
//  CachesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 7/14/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import RealmSwift

enum CachedData {
    case TravelTimes
    case HighwayAlerts
    case Ferries
    case Cameras
    case BorderWaits
}

class CachesStore {
    
    static func initCacheItem(){
        do {
            let realm = try Realm()
            let cacheItem = realm.objects(CacheItem.self).first
            
            if (cacheItem == nil){
                try! realm.write{
                    realm.add(CacheItem())
                }
            }
        } catch {
            print("Init Realm failed")
            exit(1)
        }
    }
    
    static func getUpdatedTime(data: CachedData) -> NSDate {
        
        let realm = try! Realm()
        let cacheItem = realm.objects(CacheItem.self).first
        
        switch(data){
        case .TravelTimes:
            return cacheItem!.travelTimesLastUpdate
        case .HighwayAlerts:
            return cacheItem!.highwayAlertsLastUpdate
        case .Ferries:
            return cacheItem!.ferriesLastUpdate
        case .Cameras:
            return cacheItem!.camerasLastUpdate
        case .BorderWaits:
            return cacheItem!.borderWaitsLastUpdate
        }
    }

    static func updateTime(data: CachedData, updated: NSDate){
        let realm = try! Realm()
        let cacheItem = realm.objects(CacheItem.self).first
        
        do {
            try realm.write{
                switch(data){
                case .TravelTimes:
                    cacheItem?.travelTimesLastUpdate = updated
                    break
                case .HighwayAlerts:
                    cacheItem?.highwayAlertsLastUpdate = updated
                    break
                case .Ferries:
                    cacheItem?.ferriesLastUpdate = updated
                    break
                case .Cameras:
                    cacheItem?.camerasLastUpdate = updated
                    break
                case .BorderWaits:
                    cacheItem?.borderWaitsLastUpdate = updated
                }
            }
        } catch {
            print("CachesStore.updateTime: Realm write error")
        }
    }
}
