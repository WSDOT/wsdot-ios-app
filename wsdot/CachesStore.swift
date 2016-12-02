//
//  CachesStore.swift
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

enum CachedData {
    case travelTimes
    case highwayAlerts
    case ferries
    case cameras
    case borderWaits
    case mountainPasses
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
    
    static func getUpdatedTime(_ data: CachedData) -> Date {
        
        let realm = try! Realm()
        let cacheItem = realm.objects(CacheItem.self).first
        
        switch(data){
        case .travelTimes:
            return cacheItem!.travelTimesLastUpdate as Date
        case .highwayAlerts:
            return cacheItem!.highwayAlertsLastUpdate as Date
        case .ferries:
            return cacheItem!.ferriesLastUpdate as Date
        case .cameras:
            return cacheItem!.camerasLastUpdate as Date
        case .borderWaits:
            return cacheItem!.borderWaitsLastUpdate as Date
        case .mountainPasses:
            return cacheItem!.mountainPassesLastUpdate as Date
        }
    }

    static func updateTime(_ data: CachedData, updated: Date){
        let realm = try! Realm()
        let cacheItem = realm.objects(CacheItem.self).first
        
        do {
            try realm.write{
                switch(data){
                case .travelTimes:
                    cacheItem?.travelTimesLastUpdate = updated
                    break
                case .highwayAlerts:
                    cacheItem?.highwayAlertsLastUpdate = updated
                    break
                case .ferries:
                    cacheItem?.ferriesLastUpdate = updated
                    break
                case .cameras:
                    cacheItem?.camerasLastUpdate = updated
                    break
                case .borderWaits:
                    cacheItem?.borderWaitsLastUpdate = updated
                    break
                case .mountainPasses:
                    cacheItem?.mountainPassesLastUpdate = updated
                    break
                }
            }
        } catch {
            print("CachesStore.updateTime: Realm write error")
        }
    }
}
