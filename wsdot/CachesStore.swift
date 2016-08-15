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
    case Ferries
    case Cameras
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
        case .Ferries:
            return (cacheItem?.ferriesLastUpdate)!
        case .Cameras:
            return (cacheItem?.camerasLastUpdate)!
        }
    }

    static func updateTime(data: CachedData, updated: NSDate){
        let realm = try! Realm()
        let cacheItem = realm.objects(CacheItem.self).first
        
        do {
        
        try realm.write{
            switch(data){
            case .Ferries:
                cacheItem?.ferriesLastUpdate = updated
                break
            case .Cameras:
                cacheItem?.camerasLastUpdate = updated
                break
            }
        }
        } catch {
            print("CachesStore.updateTime: Realm write error")
        }
    }
}
