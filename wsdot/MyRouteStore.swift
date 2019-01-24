//
//  MyRouteStore.swift
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

// Used to define the type of content in a favorites section.
// raw value is index into sectionTitle array
enum FavoritesContent: Int {
    case route = 0 // traffic map showing users route.
    case ferrySchedule = 1
    case mountainPass = 2
    case mapLocation = 3
    case camera = 4 // User selected cameras or cameras on user route
    case travelTime = 5 // user selected travel times or time on users route
    case tollRate = 6
    case borderWait = 7
}

class MyRouteStore {
    
    // titles for each content type section.
    static let sectionTitles = ["My Routes", "Ferry Schedules", "Mountain Passes", "Traffic Map Locations", "Cameras", "Travel Times", "Toll Rates", "Border Waits"]
    
    static func getRoutes() -> [MyRouteItem] {
        let realm = try! Realm()
        return Array(realm.objects(MyRouteItem.self))
    }
    
    static func getRouteById(_ id: Int) -> MyRouteItem? {
        let realm = try! Realm()
        return realm.object(ofType: MyRouteItem.self, forPrimaryKey: id)
    }
    
    static func getSelectedRoutes() -> [MyRouteItem] {
        let realm = try! Realm()
        let selectedRoutes = realm.objects(MyRouteItem.self).filter("selected == true")
        return Array(selectedRoutes)
    }
    
    // Creates a new MyRouteItem, returns the id of the newly saved route, or -1 on error
    static func save(route: [CLLocation], name: String, displayLat: Double, displayLong: Double, displayZoom: Float) -> Int {
    
        let myRouteItem = MyRouteItem()
        
        myRouteItem.name = name
        myRouteItem.displayLatitude = displayLat
        myRouteItem.displayLongitude = displayLong
        myRouteItem.displayZoom = Double(displayZoom)
        myRouteItem.selected = true
        
        for location in route {
            let locationItem = MyRouteLocationItem()
            locationItem.lat = location.coordinate.latitude
            locationItem.long = location.coordinate.longitude
            myRouteItem.route.append(locationItem)
        }
    
        myRouteItem.id = Int(NSDate().timeIntervalSince1970)
        
        let realm = try! Realm()
        
        do {
            try realm.write{
                realm.add(myRouteItem, update: true)
            }
        } catch {
            return -1
        }
        
        return myRouteItem.id
    }
    
    static func delete(route: MyRouteItem) -> Bool{
    
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
    
    static func updateFindNearby(forRoute: MyRouteItem, foundCameras: Bool, foundTimes: Bool, foundFerries: Bool, foundPasses: Bool) -> Bool {
        let realm = try! Realm()
        
        do {
            try realm.write {
                forRoute.foundCameras = foundCameras
                forRoute.foundTravelTimes = foundTimes
                forRoute.foundFerrySchedules = foundFerries
                forRoute.foundMountainPasses = foundPasses
            }
        }catch {
            return false
        }
        return true
    }
    
    static func updateSelected(_ selectedRoute: MyRouteItem, newValue: Bool) -> Bool {
    
        let realm = try! Realm()
        
        do {
            try realm.write{
                selectedRoute.selected = newValue
            }
            return true
        } catch {
            return false
        }
    
    }
    
    static func updateName(forRoute: MyRouteItem, _ newName: String) -> Bool{
        let realm = try! Realm()
        
        do {
            try realm.write {
                forRoute.name = newName
            }
        }catch {
            return false
        }
        return true
    }
    
    static func selectNearbyCameras(forRoute: MyRouteItem) -> Bool {
        let realm = try! Realm()
        
        let cameras = realm.objects(CameraItem.self)
        
        do {
            try realm.write {
                for camera in cameras {
                    if routeIsNearbyAny(locations: [CLLocation(latitude: camera.latitude, longitude: camera.longitude)], myRoute: forRoute) {
                        camera.selected = true
                    }
                }
            }
        }catch {
            return false
        }
        return true
    }
    
    static func selectNearbyTravelTimes(forRoute: MyRouteItem) -> Bool {
        let realm = try! Realm()
        
        let travelTimeGroups = realm.objects(TravelTimeItemGroup.self)
        do {
            try realm.write {
                for timeGroup in travelTimeGroups {
                    for time in timeGroup.routes {
                        if routeIsNearbyBoth(startLocation: CLLocation(latitude: time.startLatitude, longitude: time.startLongitude),
                                            endLocation: CLLocation(latitude: time.endLatitude, longitude: time.endLongitude),
                                            myRoute: forRoute){
                            timeGroup.selected = true
                        }
                    }
                }
            }
        } catch {
            return false
        }
        return true
    }
    
    static func getNearbyAlerts(forRoute: MyRouteItem, withAlerts: [HighwayAlertItem]) -> [HighwayAlertItem] {
    
        var nearbyAlerts = [HighwayAlertItem]()
        
        for alert in withAlerts{
        
            if routeIsNearbyAny(locations:
                [CLLocation(latitude: alert.startLatitude, longitude: alert.startLongitude),
                 CLLocation(latitude: alert.endLatitude, longitude: alert.endLongitude)], myRoute: forRoute) {
                nearbyAlerts.append(alert)
            }
        }
        return nearbyAlerts
    }
    
    
    static func selectNearbyFerries(forRoute: MyRouteItem) -> Bool {
    
        let realm = try! Realm()
        
        let ferrySchedules = realm.objects(FerryScheduleItem.self)
        
        let terminalMap = FerriesConsts().terminalMap
        
        do {
            try realm.write {
                for schedule in ferrySchedules {
            
                    for terminalPair in schedule.terminalPairs {
                
                        let terminalA = terminalMap[terminalPair.aTerminalId]!
                        let terminalB = terminalMap[terminalPair.bTerminalId]!
                
                        if routeIsNearbyBoth(startLocation: CLLocation(latitude: terminalA.latitude, longitude: terminalA.longitude),
                                                endLocation: CLLocation(latitude: terminalB.latitude, longitude: terminalB.longitude),
                                                myRoute: forRoute) {
                            schedule.selected = true
                        }
                    }
                }
            }
        
        } catch {
            return false
        }
        return true
    }
    
    static func selectNearbyPasses(forRoute: MyRouteItem) -> Bool {
    
        let realm = try! Realm()
        
        let mountainPasses = realm.objects(MountainPassItem.self)
        
        do {
            try realm.write {
            
                for pass in mountainPasses {
                    if routeIsNearbyAny(locations: [CLLocation(latitude: pass.latitude, longitude: pass.longitude)], myRoute: forRoute) {
                        pass.selected = true
                    }
                }
            }
        
        } catch {
            return false
        }
        return true
    }
    
    static func routeIsNearbyAny(locations: [CLLocation], myRoute: MyRouteItem) -> Bool {
    
        for point in myRoute.route {
            for location in locations {
                let pointLocation = CLLocation(latitude: point.lat, longitude: point.long)
        
                // distance in meters
                if location.distance(from: pointLocation) < 400 {
                    return true
                }
            }
        }
        return false
    }
    
    // All locations in allLocations must be next
    static func routeIsNearbyBoth(startLocation: CLLocation, endLocation: CLLocation, myRoute: MyRouteItem) -> Bool {
    
        var isNearbyStart = false
        var isNearbyEnd = false
    
        for point in myRoute.route {
        
            let pointLocation = CLLocation(latitude: point.lat, longitude: point.long)
        
            // distance in meters
            if startLocation.distance(from: pointLocation) < 400 {
                isNearbyStart = true
            }

            if endLocation.distance(from: pointLocation) < 400 {
                isNearbyEnd = true
            }

            if isNearbyStart && isNearbyEnd {
                return true
            }
        }
        return false
    }

    /**
     * Method name: getRouteMapRegion
     * Description: returns a region that contains all locations in the input array.
     * Parameters: locations: Array of CLLocations that make up the route.
     */
    static func getRouteMapRegion(locations: [CLLocation]) -> GMSVisibleRegion? {
        let initialLoc = locations.first
 
        if let initialLocValue = initialLoc {
 
            var minLat = initialLocValue.coordinate.latitude
            var minLng = initialLocValue.coordinate.longitude
            var maxLat = minLat
            var maxLng = minLng

            for location in locations {
                minLat = min(minLat, location.coordinate.latitude)
                minLng = min(minLng, location.coordinate.longitude)
                maxLat = max(maxLat, location.coordinate.latitude)
                maxLng = max(maxLng, location.coordinate.longitude)
            }
 
            var region: GMSVisibleRegion = GMSVisibleRegion()
            region.nearLeft = CLLocationCoordinate2DMake(maxLat, minLng)
            region.farRight = CLLocationCoordinate2DMake(minLat, maxLng)
            
            return region
        }
        return nil
    }
    }
