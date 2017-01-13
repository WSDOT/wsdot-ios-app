//
//  MyCommuteStore.swift
//  WSDOT
//
//  Copyright (c) 2017 Washington State Department of Transportation
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

class MyCommuteRealmStore {

    
    static func getSavedCommute() -> MyCommuteItem? {
        let realm = try! Realm()
        return realm.objects(MyCommuteItem.self).first
    }


    // Saves a CLLocation Array to Realm DB as a MyCommuteItem()
    static func save(route: [CLLocation], name: String) throws -> Bool {
    
        let myCommuteItem = MyCommuteItem()
        
        myCommuteItem.name = name
        
        for location in route {
            let locationItem = MyCommuteLocationItem()
            locationItem.lat = location.coordinate.latitude
            locationItem.long = location.coordinate.longitude
            myCommuteItem.route.append(locationItem)
        }
    
        myCommuteItem.id = 1
        
        let realm = try! Realm()
        
        try realm.write{
            realm.add(myCommuteItem, update: true)
        }
        
        return true
    }
    
    static func delete(route: MyCommuteItem) -> Bool{
    
        let realm = try! Realm()
        
        do {
            try realm.write {
                realm.delete(route)
            }
        }catch {
            return false
        }
        return true
    
    }
    
    static func selectNearbyCameras(forCommute: MyCommuteItem) throws -> Bool {
        let realm = try! Realm()
        
        let cameras = realm.objects(CameraItem.self)
        
        try realm.write {
            for camera in cameras {
                if locationIsNearby(myCommute: forCommute, lat: camera.latitude, long: camera.longitude) {
                    camera.selected = true
                }
            }
            forCommute.hasFoundNearbyItems = true
        }
        
        return true
    }
    
    static func getNearbyAlerts(forCommute: MyCommuteItem, withAlerts: [HighwayAlertItem]) -> [HighwayAlertItem] {
    
        var nearbyAlerts = [HighwayAlertItem]()
        
        for alert in withAlerts{
        
            if locationIsNearby(myCommute: forCommute, lat: alert.endLatitude, long: alert.endLongitude) ||
                locationIsNearby(myCommute: forCommute, lat: alert.startLatitude, long: alert.startLongitude){
                print("adding alert: \(alert.headlineDesc)")
                nearbyAlerts.append(alert)
            }
        }
        return nearbyAlerts
    }
    
    static func locationIsNearby(myCommute: MyCommuteItem, lat: Double, long: Double) -> Bool {
    
        for location in myCommute.route {
            let locA = CLLocation(latitude: lat, longitude: long)
            let locB = CLLocation(latitude: location.lat, longitude: location.long)
        
            // distance in meters
            if locA.distance(from: locB) < 400 {
                return true
            }
        }
        return false
    }
}
