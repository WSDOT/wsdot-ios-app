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
    case TravelTimes
    case HighwayAlerts
    case Ferries
    case Cameras
    case BorderWaits
    case MountainPasses
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
        case .MountainPasses:
            return cacheItem!.mountainPassesLastUpdate
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
                    break
                case .MountainPasses:
                    cacheItem?.mountainPassesLastUpdate = updated
                    break
                }
            }
        } catch {
            print("CachesStore.updateTime: Realm write error")
        }
    }
}
