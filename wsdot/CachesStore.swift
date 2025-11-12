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
    case notifications
    case tollRates
    case staticTollRates
    case bridgeAlerts
}

class CachesStore {
    
    static let tollUpdateTime: Int = 60 // once a minute
    static let staticTollUpdateTime: Int = 300 // once every 5 minutes
    
    static let updateTime: Int = 900 // once every 15 minutes

    static let cameraUpdateTime: Int = 300 // once every 5 minutes
    static let cameraRefreshTime: Int = 300 // once every 5 minutes

    static let vesselUpdateTime: TimeInterval = 30 // once every 30 seconds
    static let spacesUpdateTime: TimeInterval = 60 // once a minute
    static let ferryUpdateTime: Int = 300 // once every 5 minutes
    static let ferryDetailUpdateTime: TimeInterval = 60 // once a minute
    static let terminalUpdateTime: TimeInterval = 60 // once a minute

    static let alertsUpdateTime: TimeInterval = 60 // once a minute
    static let alertsCacheTime: Int = 60 // once a minute
    
    static let bridgeUpdateTime: TimeInterval = 60 // once a minute
    static let bridgeCacheTime: Int = 60 // once a minute
    
    static let mountainPassCacheTime: Int = 300 // once every 5 minutes
    
    static let travelTimeCacheTime: Int = 300 // once every 5 minutes


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
        
        switch(data) {
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
        case .notifications:
            return cacheItem!.notificationsLastUpdate as Date
        case .tollRates:
            return cacheItem!.tollRatesLastUpdate as Date
        case .staticTollRates:
            return cacheItem!.staticTollRatesLastUpdate as Date
        case .bridgeAlerts:
            return cacheItem!.bridgeAlertsLastUpdate as Date
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
                case .notifications:
                    cacheItem?.notificationsLastUpdate = updated
                case .tollRates:
                    cacheItem?.tollRatesLastUpdate = updated
                case .staticTollRates:
                    cacheItem?.staticTollRatesLastUpdate = updated
                case .bridgeAlerts:
                    cacheItem?.bridgeAlertsLastUpdate = updated
                }
            }
        } catch {
            print("CachesStore.updateTime: Realm write error")
        }
    }
}
