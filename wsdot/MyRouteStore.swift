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

}

class MyRouteStore {
    
    // titles for each content type section.
    static let sectionTitles = ["Saved Route", "Ferry Schedules", "Mountain Passes", "Traffic Map Locations", "Cameras", "Travel Times"]
    
    static func getRoutes() -> [MyRouteItem] {
        let realm = try! Realm()
        return Array(realm.objects(MyRouteItem.self))
    }
    
    static func getSavedRoute() -> MyRouteItem? {
        let realm = try! Realm()
        let selectedRoute = realm.objects(MyRouteItem.self).filter("selected == true")
        return selectedRoute.first
    }


    // Creates a new MyRouteItem, sets selected to true, while setting selected to false for all other routes.
    static func save(route: [CLLocation], name: String, displayLat: Double, displayLong: Double, displayZoom: Float) -> Bool {
    
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
    
        myRouteItem.id = getSavedRouteId()
        
        let realm = try! Realm()
        
        let routes = getRoutes()
        
        do {
            try realm.write{
                for route in routes {
                    route.selected = false
                }
                realm.add(myRouteItem, update: true)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    fileprivate static func getSavedRouteId() -> Int {
        
        // IDs avaliable for a saved route.
        var availableIds = [1, 2, 3]

        // Remove any IDs already in use
        for route in getRoutes() {
            availableIds.remove(at: availableIds.index(of: route.id)!)
        }

        // return the first avaliable ID
        return availableIds.first!
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
    
    static func turnOffFindNearby(route: MyRouteItem) -> Bool {
        let realm = try! Realm()
        
        do {
            try realm.write {
                route.hasFoundNearbyItems = true
            }
        }catch {
            return false
        }
        return true
    }
    
    static func setSelected(_ selectedRoute: MyRouteItem) -> Bool {
    
        let realm = try! Realm()
        let routes = getRoutes()
        
        do {
            try realm.write{
                for route in routes {
                    route.selected = false
                }
                selectedRoute.selected = true
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
        
        let travelTimes = realm.objects(TravelTimeItem.self)
        do{
            try realm.write {
                for time in travelTimes {
                    if routeIsNearbyBoth(startLocation: CLLocation(latitude: time.startLatitude, longitude: time.startLongitude),
                                            endLocation: CLLocation(latitude: time.endLatitude, longitude: time.endLongitude),
                                            myRoute: forRoute){
                        time.selected = true
                    }
                }
            }
        }catch {
            return false
        }
        return true
    }
    
    static func selectNearbyAlerts(forRoute: MyRouteItem, withAlerts: [HighwayAlertItem]) -> [HighwayAlertItem] {
    
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
        
    static func getFakeData() -> [CLLocation] {
    
        var route = [CLLocation]()
        
   route.append(CLLocation(latitude:47.6248584, longitude:-122.520992))
   route.append(CLLocation(latitude:47.62485, longitude:-122.52068))
   route.append(CLLocation(latitude:47.62485, longitude:-122.52043))
   route.append(CLLocation(latitude:47.62484, longitude:-122.51963))
    route.append(CLLocation(latitude:47.62484, longitude:-122.5184))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51829))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51816))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51796))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51766))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51748))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51701))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51671))
     
   
   route.append(CLLocation(latitude:47.62484, longitude:-122.51635))
     
   
   route.append(CLLocation(latitude:47.62485, longitude:-122.51617))
     
   
   route.append(CLLocation(latitude:47.62485, longitude:-122.51603))
     
   
   route.append(CLLocation(latitude:47.62485, longitude:-122.51592))
     
   
   route.append(CLLocation(latitude:47.62487, longitude:-122.51551))
     
   
   route.append(CLLocation(latitude:47.62487, longitude:-122.51509))
     
   
   route.append(CLLocation(latitude:47.62487, longitude:-122.51477))
     
   
   route.append(CLLocation(latitude:47.62487, longitude:-122.51436))
     
   
   route.append(CLLocation(latitude:47.62487, longitude:-122.51415))
     
   
   route.append(CLLocation(latitude:47.6248668, longitude:-122.5141534))
     
   
   route.append(CLLocation(latitude:47.62473, longitude:-122.51417))
     
   
   route.append(CLLocation(latitude:47.62468, longitude:-122.51416))
     
   
   route.append(CLLocation(latitude:47.62463, longitude:-122.51415))
     
   
   route.append(CLLocation(latitude:47.62459, longitude:-122.51414))
     
   
   route.append(CLLocation(latitude:47.62455, longitude:-122.51412))
     
   
   route.append(CLLocation(latitude:47.62451, longitude:-122.5141))
     
   
   route.append(CLLocation(latitude:47.62448, longitude:-122.51407))
     
   
   route.append(CLLocation(latitude:47.62445, longitude:-122.51404))
     
   
   route.append(CLLocation(latitude:47.62441, longitude:-122.514))
     
   
   route.append(CLLocation(latitude:47.62438, longitude:-122.51395))
     
   
   route.append(CLLocation(latitude:47.62433, longitude:-122.51387))
     
   
   route.append(CLLocation(latitude:47.62419, longitude:-122.51359))
     
   
   route.append(CLLocation(latitude:47.62399, longitude:-122.51321))
     
   
   route.append(CLLocation(latitude:47.62391, longitude:-122.51301))
     
   
   route.append(CLLocation(latitude:47.62387, longitude:-122.513))
     
   
   route.append(CLLocation(latitude:47.62386, longitude:-122.51299))
     
   
   route.append(CLLocation(latitude:47.62384, longitude:-122.51298))
     
   
   route.append(CLLocation(latitude:47.62381, longitude:-122.51296))
     
   
   route.append(CLLocation(latitude:47.62378, longitude:-122.51293))
     
   
   route.append(CLLocation(latitude:47.62365, longitude:-122.51278))
     
   
   route.append(CLLocation(latitude:47.62356, longitude:-122.51269))
     
   
   route.append(CLLocation(latitude:47.62351, longitude:-122.51264))
     
   
   route.append(CLLocation(latitude:47.62346, longitude:-122.51259))
     
   
   route.append(CLLocation(latitude:47.62342, longitude:-122.51255))
     
   
   route.append(CLLocation(latitude:47.62339, longitude:-122.5125))
     
   
   route.append(CLLocation(latitude:47.62332, longitude:-122.51239))
     
   
   route.append(CLLocation(latitude:47.62328, longitude:-122.51229))
     
   
   route.append(CLLocation(latitude:47.62323, longitude:-122.5122))
     
   
   route.append(CLLocation(latitude:47.62318, longitude:-122.5121))
     
   
   route.append(CLLocation(latitude:47.62314, longitude:-122.51202))
     
   
   route.append(CLLocation(latitude:47.62308, longitude:-122.51191))
     
   
   route.append(CLLocation(latitude:47.62306, longitude:-122.51186))
     
   
   route.append(CLLocation(latitude:47.62305, longitude:-122.51183))
     
   
   route.append(CLLocation(latitude:47.62304, longitude:-122.5118))
     
   
   route.append(CLLocation(latitude:47.62302, longitude:-122.51168))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51158))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51151))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51143))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51141))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51139))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51136))
     
   
   route.append(CLLocation(latitude:47.62301, longitude:-122.51133))
     
   
   route.append(CLLocation(latitude:47.623, longitude:-122.5113))
     
   
   route.append(CLLocation(latitude:47.62298, longitude:-122.51119))
     
   
   route.append(CLLocation(latitude:47.62295, longitude:-122.51109))
     
   
   route.append(CLLocation(latitude:47.62293, longitude:-122.51102))
     
   
   route.append(CLLocation(latitude:47.6229, longitude:-122.51097))
     
   
   route.append(CLLocation(latitude:47.62289, longitude:-122.51095))
     
   
   route.append(CLLocation(latitude:47.62285, longitude:-122.51087))
     
   
   route.append(CLLocation(latitude:47.62283, longitude:-122.51084))
     
   
   route.append(CLLocation(latitude:47.62271, longitude:-122.51066))
     
   
   route.append(CLLocation(latitude:47.62266, longitude:-122.51058))
     
   
   route.append(CLLocation(latitude:47.62264, longitude:-122.51054))
     
   
   route.append(CLLocation(latitude:47.62263, longitude:-122.51051))
     
   
   route.append(CLLocation(latitude:47.62263, longitude:-122.51048))
     
   
   route.append(CLLocation(latitude:47.62262, longitude:-122.51044))
     
   
   route.append(CLLocation(latitude:47.62259, longitude:-122.51028))
     
   
   route.append(CLLocation(latitude:47.6225906, longitude:-122.5102807))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51023))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51021))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51019))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51015))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51012))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51008))
     
   
   route.append(CLLocation(latitude:47.6226, longitude:-122.51006))
     
   
   route.append(CLLocation(latitude:47.62258, longitude:-122.50995))
     
   
   route.append(CLLocation(latitude:47.62258, longitude:-122.50994))
     
   
   route.append(CLLocation(latitude:47.62253, longitude:-122.50959))
     
   
   route.append(CLLocation(latitude:47.62251, longitude:-122.50946))
     
   
   route.append(CLLocation(latitude:47.62251, longitude:-122.5094587))
     
   
   route.append(CLLocation(latitude:47.62209, longitude:-122.50636))
     
   
   route.append(CLLocation(latitude:47.62198, longitude:-122.50563))
     
   
   route.append(CLLocation(latitude:47.62186, longitude:-122.50499))
     
   
   route.append(CLLocation(latitude:47.62173, longitude:-122.50431))
     
   
   route.append(CLLocation(latitude:47.62112, longitude:-122.50171))
     
   
   route.append(CLLocation(latitude:47.6207, longitude:-122.49988))
     
   
   route.append(CLLocation(latitude:47.62036, longitude:-122.49857))
     
   
   route.append(CLLocation(latitude:47.62011, longitude:-122.49781))
     
   
   route.append(CLLocation(latitude:47.61979, longitude:-122.49706))
     
   
   route.append(CLLocation(latitude:47.61941, longitude:-122.49639))
     
   
   route.append(CLLocation(latitude:47.61899, longitude:-122.49583))
     
   
   route.append(CLLocation(latitude:47.61852, longitude:-122.49534))
     
   
   route.append(CLLocation(latitude:47.61801, longitude:-122.49493))
     
   
   route.append(CLLocation(latitude:47.61748, longitude:-122.49462))
     
   
   route.append(CLLocation(latitude:47.61673, longitude:-122.49427))
     
   
   route.append(CLLocation(latitude:47.61595, longitude:-122.49399))
     
   
   route.append(CLLocation(latitude:47.61006, longitude:-122.49185))
     
   
   route.append(CLLocation(latitude:47.60822, longitude:-122.49105))
     
   
   route.append(CLLocation(latitude:47.60763, longitude:-122.49059))
     
   
   route.append(CLLocation(latitude:47.60718, longitude:-122.4901))
     
   
   route.append(CLLocation(latitude:47.60648, longitude:-122.48907))
     
   
   route.append(CLLocation(latitude:47.60601, longitude:-122.48797))
     
   
   route.append(CLLocation(latitude:47.60575, longitude:-122.48685))
     
   
   route.append(CLLocation(latitude:47.60554, longitude:-122.48554))
     
   
   route.append(CLLocation(latitude:47.60538, longitude:-122.48381))
     
   
   route.append(CLLocation(latitude:47.60534, longitude:-122.48203))
     
   
   route.append(CLLocation(latitude:47.60458, longitude:-122.41586))
     
   
   route.append(CLLocation(latitude:47.60447, longitude:-122.39115))
     
   
   route.append(CLLocation(latitude:47.6043, longitude:-122.36611))
     
   
   route.append(CLLocation(latitude:47.60422, longitude:-122.35559))
     
   
   route.append(CLLocation(latitude:47.60421, longitude:-122.3539))
     
   
   route.append(CLLocation(latitude:47.60417, longitude:-122.35252))
     
   
   route.append(CLLocation(latitude:47.60406, longitude:-122.35139))
     
   
   route.append(CLLocation(latitude:47.60395, longitude:-122.35052))
     
   
   route.append(CLLocation(latitude:47.60326, longitude:-122.34526))
     
   
   route.append(CLLocation(latitude:47.60312, longitude:-122.34399))
     
   
   route.append(CLLocation(latitude:47.60301, longitude:-122.3429))
     
   
   route.append(CLLocation(latitude:47.60294, longitude:-122.34207))
     
   
   route.append(CLLocation(latitude:47.60294, longitude:-122.34168))
     
   
   route.append(CLLocation(latitude:47.60289, longitude:-122.33976))
     
   
   route.append(CLLocation(latitude:47.6028868, longitude:-122.3397593))
     
   
   route.append(CLLocation(latitude:47.60289, longitude:-122.3394))
     
   
   route.append(CLLocation(latitude:47.60289, longitude:-122.33932))
     
   
   route.append(CLLocation(latitude:47.6029, longitude:-122.33929))
     
   
   route.append(CLLocation(latitude:47.6029, longitude:-122.33926))
     
   
   route.append(CLLocation(latitude:47.60291, longitude:-122.33921))
     
   
   route.append(CLLocation(latitude:47.60294, longitude:-122.33913))
     
   
   route.append(CLLocation(latitude:47.60295, longitude:-122.3391))
     
   
   route.append(CLLocation(latitude:47.6029511, longitude:-122.3390966))
     
   
   route.append(CLLocation(latitude:47.60297, longitude:-122.33903))
     
   
   route.append(CLLocation(latitude:47.60298, longitude:-122.33898))
     
   
   route.append(CLLocation(latitude:47.60299, longitude:-122.33894))
     
   
   route.append(CLLocation(latitude:47.603, longitude:-122.33892))
     
   
   route.append(CLLocation(latitude:47.603, longitude:-122.33888))
     
   
   route.append(CLLocation(latitude:47.603, longitude:-122.33825))
     
   
   route.append(CLLocation(latitude:47.603, longitude:-122.33807))
     
   
   route.append(CLLocation(latitude:47.603, longitude:-122.33803))
     
   
   route.append(CLLocation(latitude:47.603, longitude:-122.33802))
     
   
   route.append(CLLocation(latitude:47.60301, longitude:-122.338))
     
   
   route.append(CLLocation(latitude:47.60301, longitude:-122.33797))
     
   
   route.append(CLLocation(latitude:47.60301, longitude:-122.33795))
     
   
   route.append(CLLocation(latitude:47.60302, longitude:-122.33793))
     
   
   route.append(CLLocation(latitude:47.60305, longitude:-122.33784))
     
   
   route.append(CLLocation(latitude:47.6030518, longitude:-122.3378399))
     
   
   route.append(CLLocation(latitude:47.60311, longitude:-122.33773))
     
   
   route.append(CLLocation(latitude:47.60315, longitude:-122.33766))
     
   
   route.append(CLLocation(latitude:47.60317, longitude:-122.33761))
     
   
   route.append(CLLocation(latitude:47.60317, longitude:-122.33759))
     
   
   route.append(CLLocation(latitude:47.60317, longitude:-122.33758))
     
   
   route.append(CLLocation(latitude:47.60319, longitude:-122.33755))
     
   
   route.append(CLLocation(latitude:47.6032, longitude:-122.33752))
     
   
   route.append(CLLocation(latitude:47.6032, longitude:-122.33751))
     
   
   route.append(CLLocation(latitude:47.60322, longitude:-122.33748))
     
   
   route.append(CLLocation(latitude:47.60329, longitude:-122.33731))
     
   
   route.append(CLLocation(latitude:47.60333, longitude:-122.33719))
     
   
   route.append(CLLocation(latitude:47.60346, longitude:-122.33687))
     
   
   route.append(CLLocation(latitude:47.60353, longitude:-122.3367))
     
   
   route.append(CLLocation(latitude:47.60375, longitude:-122.33618))
     
   
   route.append(CLLocation(latitude:47.60398, longitude:-122.3356))
     
   
   route.append(CLLocation(latitude:47.60444, longitude:-122.33448))
     
   
   route.append(CLLocation(latitude:47.60467, longitude:-122.33393))
     
   
   route.append(CLLocation(latitude:47.60487, longitude:-122.33345))
     
   
   route.append(CLLocation(latitude:47.60491, longitude:-122.33337))
     
   
   route.append(CLLocation(latitude:47.60495, longitude:-122.33328))
     
   
   route.append(CLLocation(latitude:47.60514, longitude:-122.33282))
     
   
   route.append(CLLocation(latitude:47.60516, longitude:-122.33278))
     
   
   route.append(CLLocation(latitude:47.60538, longitude:-122.33226))
     
   
   route.append(CLLocation(latitude:47.60558, longitude:-122.33177))
     
   
   route.append(CLLocation(latitude:47.60562, longitude:-122.33168))
     
   
   route.append(CLLocation(latitude:47.60584, longitude:-122.33115))
     
   
   route.append(CLLocation(latitude:47.60599, longitude:-122.33079))
     
   
   route.append(CLLocation(latitude:47.60625, longitude:-122.33016))
     
   
   route.append(CLLocation(latitude:47.60625, longitude:-122.330156))
     
   
   route.append(CLLocation(latitude:47.60624, longitude:-122.33006))
     
   
   route.append(CLLocation(latitude:47.60623, longitude:-122.33))
     
   
   route.append(CLLocation(latitude:47.60622, longitude:-122.32997))
     
   
   route.append(CLLocation(latitude:47.60621, longitude:-122.32994))
     
   
   route.append(CLLocation(latitude:47.6062, longitude:-122.32991))
     
   
   route.append(CLLocation(latitude:47.60618, longitude:-122.32989))
     
   
   route.append(CLLocation(latitude:47.60616, longitude:-122.32986))
     
   
   route.append(CLLocation(latitude:47.60614, longitude:-122.32984))
     
   
   route.append(CLLocation(latitude:47.60607, longitude:-122.32977))
     
   
   route.append(CLLocation(latitude:47.60605, longitude:-122.32974))
     
   
   route.append(CLLocation(latitude:47.60601, longitude:-122.32969))
     
   
   route.append(CLLocation(latitude:47.60561, longitude:-122.32937))
     
   
   route.append(CLLocation(latitude:47.60525, longitude:-122.32906))
     
   
   route.append(CLLocation(latitude:47.60523, longitude:-122.32904))
     
   
   route.append(CLLocation(latitude:47.6052, longitude:-122.32901))
     
   
   route.append(CLLocation(latitude:47.60518, longitude:-122.32899))
     
   
   route.append(CLLocation(latitude:47.60517, longitude:-122.32899))
     
   
   route.append(CLLocation(latitude:47.60516, longitude:-122.32898))
     
   
   route.append(CLLocation(latitude:47.60487, longitude:-122.32872))
     
   
   route.append(CLLocation(latitude:47.60454, longitude:-122.32842))
     
   
   route.append(CLLocation(latitude:47.60427, longitude:-122.32817))
     
   
   route.append(CLLocation(latitude:47.60425, longitude:-122.32815))
     
   
   route.append(CLLocation(latitude:47.60424, longitude:-122.32815))
     
   
   route.append(CLLocation(latitude:47.60416, longitude:-122.32808))
     
   
   route.append(CLLocation(latitude:47.60392, longitude:-122.32786))
     
   
   route.append(CLLocation(latitude:47.60368, longitude:-122.32765))
     
   
   route.append(CLLocation(latitude:47.60355, longitude:-122.32752))
     
   
   route.append(CLLocation(latitude:47.60346, longitude:-122.32745))
     
   
   route.append(CLLocation(latitude:47.60309, longitude:-122.32712))
     
   
   route.append(CLLocation(latitude:47.6030921, longitude:-122.3271169))
     
   
   route.append(CLLocation(latitude:47.60294, longitude:-122.32694))
     
   
   route.append(CLLocation(latitude:47.60277, longitude:-122.32677))
     
   
   route.append(CLLocation(latitude:47.60272, longitude:-122.32672))
     
   
   route.append(CLLocation(latitude:47.60268, longitude:-122.32667))
     
   
   route.append(CLLocation(latitude:47.60263, longitude:-122.32661))
     
   
   route.append(CLLocation(latitude:47.60258, longitude:-122.32654))
     
   
   route.append(CLLocation(latitude:47.60223, longitude:-122.32603))
     
   
   route.append(CLLocation(latitude:47.60192, longitude:-122.32559))
     
   
   route.append(CLLocation(latitude:47.60172, longitude:-122.32532))
     
   
   route.append(CLLocation(latitude:47.60164, longitude:-122.32519))
     
   
   route.append(CLLocation(latitude:47.60163, longitude:-122.32516))
     
   
   route.append(CLLocation(latitude:47.60162, longitude:-122.32515))
     
   
   route.append(CLLocation(latitude:47.60158, longitude:-122.32503))
     
   
   route.append(CLLocation(latitude:47.60119, longitude:-122.32454))
     
   
   route.append(CLLocation(latitude:47.60093, longitude:-122.3242))
     
   
   route.append(CLLocation(latitude:47.60052, longitude:-122.32367))
     
   
   route.append(CLLocation(latitude:47.60034, longitude:-122.32345))
     
   
   route.append(CLLocation(latitude:47.60026, longitude:-122.32334))
     
   
   route.append(CLLocation(latitude:47.60002, longitude:-122.32305))
     
   
   route.append(CLLocation(latitude:47.59988, longitude:-122.32289))
     
   
   route.append(CLLocation(latitude:47.59966, longitude:-122.32264))
     
   
   route.append(CLLocation(latitude:47.59949, longitude:-122.32246))
     
   
   route.append(CLLocation(latitude:47.59941, longitude:-122.32238))
     
   
   route.append(CLLocation(latitude:47.59934, longitude:-122.32231))
     
   
   route.append(CLLocation(latitude:47.59921, longitude:-122.3222))
     
   
   route.append(CLLocation(latitude:47.59919, longitude:-122.32218))
     
   
   route.append(CLLocation(latitude:47.59918, longitude:-122.32218))
     
   
   route.append(CLLocation(latitude:47.59916, longitude:-122.32216))
     
   
   route.append(CLLocation(latitude:47.59908, longitude:-122.3221))
     
   
   route.append(CLLocation(latitude:47.59895, longitude:-122.32199))
     
   
   route.append(CLLocation(latitude:47.59876, longitude:-122.32185))
     
   
   route.append(CLLocation(latitude:47.59867, longitude:-122.32179))
     
   
   route.append(CLLocation(latitude:47.59849, longitude:-122.32168))
     
   
   route.append(CLLocation(latitude:47.59835, longitude:-122.3216))
     
   
   route.append(CLLocation(latitude:47.59832, longitude:-122.32158))
     
   
   route.append(CLLocation(latitude:47.59824, longitude:-122.32155))
     
   
   route.append(CLLocation(latitude:47.59812, longitude:-122.3215))
     
   
   route.append(CLLocation(latitude:47.59792, longitude:-122.3214))
     
   
   route.append(CLLocation(latitude:47.59736, longitude:-122.32115))
     
   
   route.append(CLLocation(latitude:47.5973602, longitude:-122.3211492))
     
   
   route.append(CLLocation(latitude:47.5972, longitude:-122.32103))
     
   
   route.append(CLLocation(latitude:47.59709, longitude:-122.32096))
     
   
   route.append(CLLocation(latitude:47.59695, longitude:-122.3209))
     
   
   route.append(CLLocation(latitude:47.5968, longitude:-122.32085))
     
   
   route.append(CLLocation(latitude:47.59664, longitude:-122.32081))
     
   
   route.append(CLLocation(latitude:47.59641, longitude:-122.32078))
     
   
   route.append(CLLocation(latitude:47.59612, longitude:-122.32075))
     
   
   route.append(CLLocation(latitude:47.59528, longitude:-122.32068))
     
   
   route.append(CLLocation(latitude:47.59517, longitude:-122.32065))
     
   
   route.append(CLLocation(latitude:47.5951, longitude:-122.32063))
     
   
   route.append(CLLocation(latitude:47.59503, longitude:-122.3206))
     
   
   route.append(CLLocation(latitude:47.59502, longitude:-122.32059))
     
   
   route.append(CLLocation(latitude:47.59496, longitude:-122.32056))
     
   
   route.append(CLLocation(latitude:47.59489, longitude:-122.32051))
     
   
   route.append(CLLocation(latitude:47.59479, longitude:-122.32041))
     
   
   route.append(CLLocation(latitude:47.59476, longitude:-122.32039))
     
   
   route.append(CLLocation(latitude:47.59464, longitude:-122.32024))
     
   
   route.append(CLLocation(latitude:47.59456, longitude:-122.3201))
     
   
   route.append(CLLocation(latitude:47.5945, longitude:-122.31998))
     
   
   route.append(CLLocation(latitude:47.5945, longitude:-122.31997))
     
   
   route.append(CLLocation(latitude:47.59446, longitude:-122.31986))
     
   
   route.append(CLLocation(latitude:47.59445, longitude:-122.31985))
     
   
   route.append(CLLocation(latitude:47.59444, longitude:-122.31982))
     
   
   route.append(CLLocation(latitude:47.59443, longitude:-122.31978))
     
   
   route.append(CLLocation(latitude:47.5944, longitude:-122.31966))
     
   
   route.append(CLLocation(latitude:47.59438, longitude:-122.31954))
     
   
   route.append(CLLocation(latitude:47.59437, longitude:-122.31949))
     
   
   route.append(CLLocation(latitude:47.59436, longitude:-122.31938))
     
   
   route.append(CLLocation(latitude:47.59434, longitude:-122.31918))
     
   
   route.append(CLLocation(latitude:47.59434, longitude:-122.31905))
     
   
   route.append(CLLocation(latitude:47.59435, longitude:-122.3189))
     
   
   route.append(CLLocation(latitude:47.59436, longitude:-122.31878))
     
   
   route.append(CLLocation(latitude:47.59438, longitude:-122.31865))
     
   
   route.append(CLLocation(latitude:47.59445, longitude:-122.31834))
     
   
   route.append(CLLocation(latitude:47.59461, longitude:-122.31775))
     
   
   route.append(CLLocation(latitude:47.59469, longitude:-122.31741))
     
   
   route.append(CLLocation(latitude:47.59471, longitude:-122.31734))
     
   
   route.append(CLLocation(latitude:47.59472, longitude:-122.31725))
     
   
   route.append(CLLocation(latitude:47.59472, longitude:-122.31717))
     
   
   route.append(CLLocation(latitude:47.59473, longitude:-122.31697))
     
   
   route.append(CLLocation(latitude:47.59476, longitude:-122.31684))
     
   
   route.append(CLLocation(latitude:47.5948, longitude:-122.31671))
     
   
   route.append(CLLocation(latitude:47.59483, longitude:-122.31651))
     
   
   route.append(CLLocation(latitude:47.59485, longitude:-122.31632))
     
   
   route.append(CLLocation(latitude:47.59486, longitude:-122.31607))
     
   
   route.append(CLLocation(latitude:47.59485, longitude:-122.31586))
     
   
   route.append(CLLocation(latitude:47.59484, longitude:-122.31567))
     
   
   route.append(CLLocation(latitude:47.59483, longitude:-122.31545))
     
   
   route.append(CLLocation(latitude:47.5948, longitude:-122.31522))
     
   
   route.append(CLLocation(latitude:47.59476, longitude:-122.31502))
     
   
   route.append(CLLocation(latitude:47.5947, longitude:-122.31471))
     
   
   route.append(CLLocation(latitude:47.59462, longitude:-122.31441))
     
   
   route.append(CLLocation(latitude:47.5946, longitude:-122.31433))
     
   
   route.append(CLLocation(latitude:47.59452, longitude:-122.31412))
     
   
   route.append(CLLocation(latitude:47.59447, longitude:-122.31398))
     
   
   route.append(CLLocation(latitude:47.59433, longitude:-122.3137))
     
   
   route.append(CLLocation(latitude:47.59419, longitude:-122.31347))
     
   
   route.append(CLLocation(latitude:47.59406, longitude:-122.31326))
     
   
   route.append(CLLocation(latitude:47.59399, longitude:-122.31317))
     
   
   route.append(CLLocation(latitude:47.59394, longitude:-122.31311))
     
   
   route.append(CLLocation(latitude:47.59392, longitude:-122.31308))
     
   
   route.append(CLLocation(latitude:47.5939, longitude:-122.31306))
     
   
   route.append(CLLocation(latitude:47.59388, longitude:-122.31305))
     
   
   route.append(CLLocation(latitude:47.59372, longitude:-122.31289))
     
   
   route.append(CLLocation(latitude:47.59219, longitude:-122.31172))
     
   
   route.append(CLLocation(latitude:47.59166, longitude:-122.31133))
     
   
   route.append(CLLocation(latitude:47.59144, longitude:-122.31115))
     
   
   route.append(CLLocation(latitude:47.59134, longitude:-122.31107))
     
   
   route.append(CLLocation(latitude:47.59123, longitude:-122.31098))
     
   
   route.append(CLLocation(latitude:47.59113, longitude:-122.31088))
     
   
   route.append(CLLocation(latitude:47.59107, longitude:-122.3108))
     
   
   route.append(CLLocation(latitude:47.59085, longitude:-122.31052))
     
   
   route.append(CLLocation(latitude:47.59083, longitude:-122.31049))
     
   
   route.append(CLLocation(latitude:47.59081, longitude:-122.31047))
     
   
   route.append(CLLocation(latitude:47.5907, longitude:-122.31031))
     
   
   route.append(CLLocation(latitude:47.59069, longitude:-122.3103))
     
   
   route.append(CLLocation(latitude:47.59063, longitude:-122.3102))
     
   
   route.append(CLLocation(latitude:47.5905, longitude:-122.30998))
     
   
   route.append(CLLocation(latitude:47.59042, longitude:-122.30981))
     
   
   route.append(CLLocation(latitude:47.59033, longitude:-122.30959))
     
   
   route.append(CLLocation(latitude:47.59025, longitude:-122.30938))
     
   
   route.append(CLLocation(latitude:47.59016, longitude:-122.3091))
     
   
   route.append(CLLocation(latitude:47.59009, longitude:-122.30882))
     
   
   route.append(CLLocation(latitude:47.59004, longitude:-122.30858))
     
   
   route.append(CLLocation(latitude:47.59, longitude:-122.30833))
     
   
   route.append(CLLocation(latitude:47.58997, longitude:-122.30807))
     
   
   route.append(CLLocation(latitude:47.58995, longitude:-122.30745))
     
   
   route.append(CLLocation(latitude:47.58995, longitude:-122.30741))
     
   
   route.append(CLLocation(latitude:47.58996, longitude:-122.30703))
     
   
   route.append(CLLocation(latitude:47.58996, longitude:-122.30683))
     
   
   route.append(CLLocation(latitude:47.58997, longitude:-122.30633))
     
   
   route.append(CLLocation(latitude:47.58999, longitude:-122.30483))
     
   
   route.append(CLLocation(latitude:47.59, longitude:-122.30452))
     
   
   route.append(CLLocation(latitude:47.59, longitude:-122.30435))
     
   
   route.append(CLLocation(latitude:47.59, longitude:-122.3038))
     
   
   route.append(CLLocation(latitude:47.59001, longitude:-122.30314))
     
   
   route.append(CLLocation(latitude:47.59002, longitude:-122.30247))
     
   
   route.append(CLLocation(latitude:47.59007, longitude:-122.30078))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.29914))
     
   
   route.append(CLLocation(latitude:47.5901081, longitude:-122.2991351))
     
   
   route.append(CLLocation(latitude:47.59012, longitude:-122.29862))
     
   
   route.append(CLLocation(latitude:47.59012, longitude:-122.29854))
     
   
   route.append(CLLocation(latitude:47.59013, longitude:-122.29729))
     
   
   route.append(CLLocation(latitude:47.59013, longitude:-122.29686))
     
   
   route.append(CLLocation(latitude:47.59012, longitude:-122.29636))
     
   
   route.append(CLLocation(latitude:47.59012, longitude:-122.29554))
     
   
   route.append(CLLocation(latitude:47.59012, longitude:-122.29551))
     
   
   route.append(CLLocation(latitude:47.59012, longitude:-122.2955))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.29463))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.29462))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.2946))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.29347))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.29345))
     
   
   route.append(CLLocation(latitude:47.59011, longitude:-122.29283))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29241))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29239))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29191))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29136))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29135))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29134))
     
   
   route.append(CLLocation(latitude:47.5901, longitude:-122.29099))
     
   
   route.append(CLLocation(latitude:47.59009, longitude:-122.29046))
     
   
   route.append(CLLocation(latitude:47.59009, longitude:-122.29045))
     
   
   route.append(CLLocation(latitude:47.59009, longitude:-122.29044))
     
   
   route.append(CLLocation(latitude:47.59009, longitude:-122.2902))
     
   
   route.append(CLLocation(latitude:47.59009, longitude:-122.28973))
     
   
   route.append(CLLocation(latitude:47.59008, longitude:-122.28916))
     
   
   route.append(CLLocation(latitude:47.59008, longitude:-122.28915))
     
   
   route.append(CLLocation(latitude:47.59008, longitude:-122.28913))
     
   
   route.append(CLLocation(latitude:47.59007, longitude:-122.28906))
     
   
   route.append(CLLocation(latitude:47.59006, longitude:-122.28844))
     
   
   route.append(CLLocation(latitude:47.59006, longitude:-122.28841))
     
   
   route.append(CLLocation(latitude:47.59006, longitude:-122.28827))
     
   
   route.append(CLLocation(latitude:47.59005, longitude:-122.28814))
     
   
   route.append(CLLocation(latitude:47.59002, longitude:-122.28751))
     
   
   route.append(CLLocation(latitude:47.58997, longitude:-122.28686))
     
   
   route.append(CLLocation(latitude:47.58997, longitude:-122.28675))
     
   
   route.append(CLLocation(latitude:47.58996, longitude:-122.28645))
     
   
   route.append(CLLocation(latitude:47.58995, longitude:-122.28643))
     
   
   route.append(CLLocation(latitude:47.58991, longitude:-122.28544))
     
   
   route.append(CLLocation(latitude:47.58953, longitude:-122.26816))
     
   
   route.append(CLLocation(latitude:47.58939, longitude:-122.26253))
     
   
   route.append(CLLocation(latitude:47.58928, longitude:-122.25782))
     
   
   route.append(CLLocation(latitude:47.58927, longitude:-122.25671))
     
   
   route.append(CLLocation(latitude:47.58922, longitude:-122.25428))
     
   
   route.append(CLLocation(latitude:47.58926, longitude:-122.25319))
     
   
   route.append(CLLocation(latitude:47.5893, longitude:-122.25292))
     
   
   route.append(CLLocation(latitude:47.58935, longitude:-122.25252))
     
   
   route.append(CLLocation(latitude:47.58942, longitude:-122.25218))
     
   
   route.append(CLLocation(latitude:47.58946, longitude:-122.25197))
     
   
   route.append(CLLocation(latitude:47.58949, longitude:-122.25184))
     
   
   route.append(CLLocation(latitude:47.5896, longitude:-122.25142))
     
   
   route.append(CLLocation(latitude:47.5897, longitude:-122.25109))
     
   
   route.append(CLLocation(latitude:47.58972, longitude:-122.25102))
     
   
   route.append(CLLocation(latitude:47.58992, longitude:-122.25049))
     
   
   route.append(CLLocation(latitude:47.59019, longitude:-122.24987))
     
   
   route.append(CLLocation(latitude:47.59042, longitude:-122.24935))
     
   
   route.append(CLLocation(latitude:47.59043, longitude:-122.24933))
     
   
   route.append(CLLocation(latitude:47.59044, longitude:-122.24933))
     
   
   route.append(CLLocation(latitude:47.59052, longitude:-122.24917))
     
   
   route.append(CLLocation(latitude:47.59053, longitude:-122.24916))
     
   
   route.append(CLLocation(latitude:47.59106, longitude:-122.24815))
     
   
   route.append(CLLocation(latitude:47.59121, longitude:-122.24782))
     
   
   route.append(CLLocation(latitude:47.59129, longitude:-122.24762))
     
   
   route.append(CLLocation(latitude:47.59131, longitude:-122.24757))
     
   
   route.append(CLLocation(latitude:47.59143, longitude:-122.24728))
     
   
   route.append(CLLocation(latitude:47.59159, longitude:-122.24687))
     
   
   route.append(CLLocation(latitude:47.5917, longitude:-122.24655))
     
   
   route.append(CLLocation(latitude:47.59178, longitude:-122.24629))
     
   
   route.append(CLLocation(latitude:47.59184, longitude:-122.24602))
     
   
   route.append(CLLocation(latitude:47.59186, longitude:-122.2459))
     
   
   route.append(CLLocation(latitude:47.59189, longitude:-122.24573))
     
   
   route.append(CLLocation(latitude:47.59192, longitude:-122.24544))
     
   
   route.append(CLLocation(latitude:47.59194, longitude:-122.24517))
     
   
   route.append(CLLocation(latitude:47.59197, longitude:-122.2447))
     
   
   route.append(CLLocation(latitude:47.59197, longitude:-122.24459))
     
   
   route.append(CLLocation(latitude:47.59197, longitude:-122.24458))
     
   
   route.append(CLLocation(latitude:47.59198, longitude:-122.24421))
     
   
   route.append(CLLocation(latitude:47.59197, longitude:-122.24386))
     
   
   route.append(CLLocation(latitude:47.59196, longitude:-122.24368))
     
   
   route.append(CLLocation(latitude:47.59193, longitude:-122.24333))
     
   
   route.append(CLLocation(latitude:47.59193, longitude:-122.24328))
     
   
   route.append(CLLocation(latitude:47.59191, longitude:-122.24315))
     
   
   route.append(CLLocation(latitude:47.5919, longitude:-122.2431))
     
   
   route.append(CLLocation(latitude:47.5919, longitude:-122.24309))
     
   
   route.append(CLLocation(latitude:47.5919, longitude:-122.24305))
     
   
   route.append(CLLocation(latitude:47.59189, longitude:-122.24302))
     
   
   route.append(CLLocation(latitude:47.59186, longitude:-122.2428))
     
   
   route.append(CLLocation(latitude:47.59181, longitude:-122.24257))
     
   
   route.append(CLLocation(latitude:47.59172, longitude:-122.24219))
     
   
   route.append(CLLocation(latitude:47.59162, longitude:-122.24183))
     
   
   route.append(CLLocation(latitude:47.5915, longitude:-122.24147))
     
   
   route.append(CLLocation(latitude:47.59132, longitude:-122.24097))
     
   
   route.append(CLLocation(latitude:47.59116, longitude:-122.24062))
     
   
   route.append(CLLocation(latitude:47.59108, longitude:-122.24044))
     
   
   route.append(CLLocation(latitude:47.59099, longitude:-122.24027))
     
   
   route.append(CLLocation(latitude:47.5909, longitude:-122.24011))
     
   
   route.append(CLLocation(latitude:47.59076, longitude:-122.23986))
     
   
   route.append(CLLocation(latitude:47.59072, longitude:-122.23979))
     
   
   route.append(CLLocation(latitude:47.59048, longitude:-122.23931))
     
   
   route.append(CLLocation(latitude:47.58975, longitude:-122.238))
     
   
   route.append(CLLocation(latitude:47.58969, longitude:-122.23789))
     
   
   route.append(CLLocation(latitude:47.58965, longitude:-122.23781))
     
   
   route.append(CLLocation(latitude:47.58962, longitude:-122.23775))
     
   
   route.append(CLLocation(latitude:47.58959, longitude:-122.23768))
     
   
   route.append(CLLocation(latitude:47.58958, longitude:-122.23767))
     
   
   route.append(CLLocation(latitude:47.58951, longitude:-122.23749))
     
   
   route.append(CLLocation(latitude:47.58951, longitude:-122.23748))
     
   
   route.append(CLLocation(latitude:47.58948, longitude:-122.23742))
     
   
   route.append(CLLocation(latitude:47.58936, longitude:-122.23714))
     
   
   route.append(CLLocation(latitude:47.58926, longitude:-122.23693))
     
   
   route.append(CLLocation(latitude:47.58921, longitude:-122.23683))
     
   
   route.append(CLLocation(latitude:47.58904, longitude:-122.23644))
     
   
   route.append(CLLocation(latitude:47.58892, longitude:-122.23617))
     
   
   route.append(CLLocation(latitude:47.58887, longitude:-122.23603))
     
   
   route.append(CLLocation(latitude:47.58877, longitude:-122.23575))
     
   
   route.append(CLLocation(latitude:47.58852, longitude:-122.23502))
     
   
   route.append(CLLocation(latitude:47.58837, longitude:-122.23461))
     
   
   route.append(CLLocation(latitude:47.58829, longitude:-122.23439))
     
   
   route.append(CLLocation(latitude:47.58812, longitude:-122.23392))
     
   
   route.append(CLLocation(latitude:47.58767, longitude:-122.23268))
     
   
   route.append(CLLocation(latitude:47.58707, longitude:-122.23098))
     
   
   route.append(CLLocation(latitude:47.58678, longitude:-122.2303))
     
   
   route.append(CLLocation(latitude:47.5858, longitude:-122.22815))
     
   
   route.append(CLLocation(latitude:47.58544, longitude:-122.2273))
     
   
   route.append(CLLocation(latitude:47.58524, longitude:-122.22683))
     
   
   route.append(CLLocation(latitude:47.5849, longitude:-122.22611))
     
   
   route.append(CLLocation(latitude:47.58434, longitude:-122.22483))
     
   
   route.append(CLLocation(latitude:47.58413, longitude:-122.2243))
     
   
   route.append(CLLocation(latitude:47.58389, longitude:-122.2237))
     
   
   route.append(CLLocation(latitude:47.5831, longitude:-122.22187))
     
   
   route.append(CLLocation(latitude:47.58289, longitude:-122.22137))
     
   
   route.append(CLLocation(latitude:47.58284, longitude:-122.22126))
     
   
   route.append(CLLocation(latitude:47.58213, longitude:-122.21962))
     
   
   route.append(CLLocation(latitude:47.58197, longitude:-122.21933))
     
   
   route.append(CLLocation(latitude:47.58196, longitude:-122.21931))
     
   
   route.append(CLLocation(latitude:47.58192, longitude:-122.21924))
     
   
   route.append(CLLocation(latitude:47.58183, longitude:-122.21907))
     
   
   route.append(CLLocation(latitude:47.58172, longitude:-122.21888))
     
   
   route.append(CLLocation(latitude:47.58166, longitude:-122.21879))
     
   
   route.append(CLLocation(latitude:47.58159, longitude:-122.21867))
     
   
   route.append(CLLocation(latitude:47.58151, longitude:-122.21855))
     
   
   route.append(CLLocation(latitude:47.58139, longitude:-122.21837))
     
   
   route.append(CLLocation(latitude:47.58122, longitude:-122.21812))
     
   
   route.append(CLLocation(latitude:47.5807, longitude:-122.21738))
     
   
   route.append(CLLocation(latitude:47.57983, longitude:-122.21613))
     
   
   route.append(CLLocation(latitude:47.57974, longitude:-122.21598))
     
   
   route.append(CLLocation(latitude:47.57961, longitude:-122.21574))
     
   
   route.append(CLLocation(latitude:47.57949, longitude:-122.21552))
     
   
   route.append(CLLocation(latitude:47.57935, longitude:-122.21522))
     
   
   route.append(CLLocation(latitude:47.57925, longitude:-122.21496))
     
   
   route.append(CLLocation(latitude:47.57917, longitude:-122.21478))
     
   
   route.append(CLLocation(latitude:47.57908, longitude:-122.21454))
     
   
   route.append(CLLocation(latitude:47.579, longitude:-122.21429))
     
   
   route.append(CLLocation(latitude:47.57895, longitude:-122.21414))
     
   
   route.append(CLLocation(latitude:47.5789, longitude:-122.21399))
     
   
   route.append(CLLocation(latitude:47.57885, longitude:-122.2138))
     
   
   route.append(CLLocation(latitude:47.57878, longitude:-122.21353))
     
   
   route.append(CLLocation(latitude:47.57872, longitude:-122.21329))
     
   
   route.append(CLLocation(latitude:47.57867, longitude:-122.21302))
     
   
   route.append(CLLocation(latitude:47.57866, longitude:-122.21299))
     
   
   route.append(CLLocation(latitude:47.57862, longitude:-122.21274))
     
   
   route.append(CLLocation(latitude:47.5786, longitude:-122.21265))
     
   
   route.append(CLLocation(latitude:47.57857, longitude:-122.21245))
     
   
   route.append(CLLocation(latitude:47.57849, longitude:-122.21192))
     
   
   route.append(CLLocation(latitude:47.57845, longitude:-122.21165))
     
   
   route.append(CLLocation(latitude:47.57843, longitude:-122.21147))
     
   
   route.append(CLLocation(latitude:47.57839, longitude:-122.21121))
     
   
   route.append(CLLocation(latitude:47.57835, longitude:-122.21084))
     
   
   route.append(CLLocation(latitude:47.57826, longitude:-122.2102))
     
   
   route.append(CLLocation(latitude:47.57817, longitude:-122.20961))
     
   
   route.append(CLLocation(latitude:47.57806, longitude:-122.20883))
     
   
   route.append(CLLocation(latitude:47.57795, longitude:-122.20801))
     
   
   route.append(CLLocation(latitude:47.57787, longitude:-122.20747))
     
   
   route.append(CLLocation(latitude:47.57784, longitude:-122.20726))
     
   
   route.append(CLLocation(latitude:47.57781, longitude:-122.20703))
     
   
   route.append(CLLocation(latitude:47.57778, longitude:-122.20678))
     
   
   route.append(CLLocation(latitude:47.57776, longitude:-122.20663))
     
   
   route.append(CLLocation(latitude:47.57775, longitude:-122.20644))
     
   
   route.append(CLLocation(latitude:47.57773, longitude:-122.20629))
     
   
   route.append(CLLocation(latitude:47.57772, longitude:-122.20618))
     
   
   route.append(CLLocation(latitude:47.57772, longitude:-122.20605))
     
   
   route.append(CLLocation(latitude:47.57771, longitude:-122.20588))
     
   
   route.append(CLLocation(latitude:47.57771, longitude:-122.20573))
     
   
   route.append(CLLocation(latitude:47.57771, longitude:-122.20559))
     
   
   route.append(CLLocation(latitude:47.57771, longitude:-122.20547))
     
   
   route.append(CLLocation(latitude:47.57771, longitude:-122.20531))
     
   
   route.append(CLLocation(latitude:47.57771, longitude:-122.2052))
     
   
   route.append(CLLocation(latitude:47.57772, longitude:-122.20507))
     
   
   route.append(CLLocation(latitude:47.57772, longitude:-122.20496))
     
   
   route.append(CLLocation(latitude:47.57772, longitude:-122.20484))
     
   
   route.append(CLLocation(latitude:47.57774, longitude:-122.20471))
     
   
   route.append(CLLocation(latitude:47.57775, longitude:-122.20455))
     
   
   route.append(CLLocation(latitude:47.57777, longitude:-122.20437))
     
   
   route.append(CLLocation(latitude:47.57778, longitude:-122.20424))
     
   
   route.append(CLLocation(latitude:47.5778, longitude:-122.20409))
     
   
   route.append(CLLocation(latitude:47.57782, longitude:-122.20392))
     
   
   route.append(CLLocation(latitude:47.57784, longitude:-122.20377))
     
   
   route.append(CLLocation(latitude:47.57787, longitude:-122.20357))
     
   
   route.append(CLLocation(latitude:47.57793, longitude:-122.20328))
     
   
   route.append(CLLocation(latitude:47.57797, longitude:-122.20309))
     
   
   route.append(CLLocation(latitude:47.578, longitude:-122.20295))
     
   
   route.append(CLLocation(latitude:47.57805, longitude:-122.20275))
     
   
   route.append(CLLocation(latitude:47.57808, longitude:-122.20261))
     
   
   route.append(CLLocation(latitude:47.57811, longitude:-122.20249))
     
   
   route.append(CLLocation(latitude:47.57815, longitude:-122.20236))
     
   
   route.append(CLLocation(latitude:47.57818, longitude:-122.20221))
     
   
   route.append(CLLocation(latitude:47.57827, longitude:-122.20189))
     
   
   route.append(CLLocation(latitude:47.57847, longitude:-122.20111))
     
   
   route.append(CLLocation(latitude:47.57856, longitude:-122.20076))
     
   
   route.append(CLLocation(latitude:47.57868, longitude:-122.20031))
     
   
   route.append(CLLocation(latitude:47.57873, longitude:-122.20009))
     
   
   route.append(CLLocation(latitude:47.57877, longitude:-122.19993))
     
   
   route.append(CLLocation(latitude:47.57881, longitude:-122.19977))
     
   
   route.append(CLLocation(latitude:47.57885, longitude:-122.1996))
     
   
   route.append(CLLocation(latitude:47.5789, longitude:-122.19943))
     
   
   route.append(CLLocation(latitude:47.57942, longitude:-122.19745))
     
   
   route.append(CLLocation(latitude:47.57946, longitude:-122.19725))
     
   
   route.append(CLLocation(latitude:47.57954, longitude:-122.19692))
     
   
   route.append(CLLocation(latitude:47.5796, longitude:-122.19667))
     
   
   route.append(CLLocation(latitude:47.57965, longitude:-122.19636))
     
   
   route.append(CLLocation(latitude:47.57967, longitude:-122.19621))
     
   
   route.append(CLLocation(latitude:47.57969, longitude:-122.19607))
     
   
   route.append(CLLocation(latitude:47.57971, longitude:-122.19594))
     
   
   route.append(CLLocation(latitude:47.57972, longitude:-122.19577))
     
   
   route.append(CLLocation(latitude:47.57973, longitude:-122.19565))
     
   
   route.append(CLLocation(latitude:47.57974, longitude:-122.19553))
     
   
   route.append(CLLocation(latitude:47.57975, longitude:-122.19534))
     
   
   route.append(CLLocation(latitude:47.57975, longitude:-122.19511))
     
   
   route.append(CLLocation(latitude:47.57975, longitude:-122.19493))
     
   
   route.append(CLLocation(latitude:47.57974, longitude:-122.19462))
     
   
   route.append(CLLocation(latitude:47.57973, longitude:-122.19446))
     
   
   route.append(CLLocation(latitude:47.57971, longitude:-122.19416))
     
   
   route.append(CLLocation(latitude:47.57963, longitude:-122.19369))
     
   
   route.append(CLLocation(latitude:47.57932, longitude:-122.19196))
     
   
   route.append(CLLocation(latitude:47.5792, longitude:-122.19133))
     
   
   route.append(CLLocation(latitude:47.57916, longitude:-122.19113))
     
   
   route.append(CLLocation(latitude:47.57913, longitude:-122.19094))
     
   
   route.append(CLLocation(latitude:47.57909, longitude:-122.19061))
     
   
   route.append(CLLocation(latitude:47.57907, longitude:-122.19032))
     
   
   route.append(CLLocation(latitude:47.57905, longitude:-122.18986))
     
   
   route.append(CLLocation(latitude:47.57906, longitude:-122.18941))
     
   
   route.append(CLLocation(latitude:47.57908, longitude:-122.18898))
     
   
   route.append(CLLocation(latitude:47.5791, longitude:-122.1887))
     
   
   route.append(CLLocation(latitude:47.57913, longitude:-122.18842))
     
   
   route.append(CLLocation(latitude:47.57955, longitude:-122.18342))
     
   
   route.append(CLLocation(latitude:47.57963, longitude:-122.18251))
     
   
   route.append(CLLocation(latitude:47.57969, longitude:-122.18184))
     
   
   route.append(CLLocation(latitude:47.57972, longitude:-122.18152))
     
   
   route.append(CLLocation(latitude:47.57973, longitude:-122.18133))
     
   
   route.append(CLLocation(latitude:47.57983, longitude:-122.18016))
     
   
   route.append(CLLocation(latitude:47.57986, longitude:-122.17989))
     
   
   route.append(CLLocation(latitude:47.57991, longitude:-122.17928))
     
   
   route.append(CLLocation(latitude:47.57993, longitude:-122.17898))
     
   
   route.append(CLLocation(latitude:47.57997, longitude:-122.17853))
     
   
   route.append(CLLocation(latitude:47.58001, longitude:-122.17808))
     
   
   route.append(CLLocation(latitude:47.58011, longitude:-122.17691))
     
   
   route.append(CLLocation(latitude:47.58014, longitude:-122.17647))
     
   
   route.append(CLLocation(latitude:47.58016, longitude:-122.17626))
     
   
   route.append(CLLocation(latitude:47.58017, longitude:-122.17608))
     
   
   route.append(CLLocation(latitude:47.58019, longitude:-122.17588))
     
   
   route.append(CLLocation(latitude:47.5802, longitude:-122.17569))
     
   
   route.append(CLLocation(latitude:47.5802, longitude:-122.17553))
     
   
   route.append(CLLocation(latitude:47.58021, longitude:-122.17514))
     
   
   route.append(CLLocation(latitude:47.58024, longitude:-122.17469))
     
   
   route.append(CLLocation(latitude:47.58025, longitude:-122.17414))
     
   
   route.append(CLLocation(latitude:47.58025, longitude:-122.1733))
     
   
   route.append(CLLocation(latitude:47.58023, longitude:-122.17233))
     
   
   route.append(CLLocation(latitude:47.58016, longitude:-122.1708))
     
   
   route.append(CLLocation(latitude:47.58013, longitude:-122.17025))
     
   
   route.append(CLLocation(latitude:47.58011, longitude:-122.16963))
     
   
   route.append(CLLocation(latitude:47.58009, longitude:-122.16923))
     
   
   route.append(CLLocation(latitude:47.58007, longitude:-122.16887))
     
   
   route.append(CLLocation(latitude:47.58001, longitude:-122.16748))
     
   
   route.append(CLLocation(latitude:47.57985, longitude:-122.16257))
     
   
   route.append(CLLocation(latitude:47.57983, longitude:-122.16205))
     
   
   route.append(CLLocation(latitude:47.57983, longitude:-122.16199))
     
   
   route.append(CLLocation(latitude:47.57981, longitude:-122.16164))
     
   
   route.append(CLLocation(latitude:47.57976, longitude:-122.16055))
     
   
   route.append(CLLocation(latitude:47.57961, longitude:-122.1577))
     
   
   route.append(CLLocation(latitude:47.5796, longitude:-122.15746))
     
   
   route.append(CLLocation(latitude:47.57955, longitude:-122.15638))
     
   
   route.append(CLLocation(latitude:47.57952, longitude:-122.15584))
     
   
   route.append(CLLocation(latitude:47.57949, longitude:-122.15506))
     
   
   route.append(CLLocation(latitude:47.57945, longitude:-122.15439))
     
   
   route.append(CLLocation(latitude:47.57942, longitude:-122.15371))
     
   
   route.append(CLLocation(latitude:47.5794, longitude:-122.15338))
     
   
   route.append(CLLocation(latitude:47.57938, longitude:-122.15294))
     
   
   route.append(CLLocation(latitude:47.57931, longitude:-122.15167))
     
   
   route.append(CLLocation(latitude:47.57927, longitude:-122.15076))
     
   
   route.append(CLLocation(latitude:47.57914, longitude:-122.14823))
     
   
   route.append(CLLocation(latitude:47.5791, longitude:-122.14733))
     
   
   route.append(CLLocation(latitude:47.57907, longitude:-122.14651))
     
   
   route.append(CLLocation(latitude:47.57906, longitude:-122.14617))
     
   
   route.append(CLLocation(latitude:47.57903, longitude:-122.14538))
     
   
   route.append(CLLocation(latitude:47.579, longitude:-122.14471))
     
   
   route.append(CLLocation(latitude:47.57895, longitude:-122.14382))
     
   
   route.append(CLLocation(latitude:47.57892, longitude:-122.14315))
     
   
   route.append(CLLocation(latitude:47.57889, longitude:-122.14255))
     
   
   route.append(CLLocation(latitude:47.57884, longitude:-122.14158))
     
   
   route.append(CLLocation(latitude:47.57881, longitude:-122.14097))
     
   
   route.append(CLLocation(latitude:47.57881, longitude:-122.14084))
     
   
   route.append(CLLocation(latitude:47.57879, longitude:-122.14062))
     
   
   route.append(CLLocation(latitude:47.57875, longitude:-122.13969))
     
   
   route.append(CLLocation(latitude:47.57871, longitude:-122.13888))
     
   
   route.append(CLLocation(latitude:47.57866, longitude:-122.13791))
     
   
   route.append(CLLocation(latitude:47.57861, longitude:-122.13698))
     
   
   route.append(CLLocation(latitude:47.57858, longitude:-122.1364))
     
   
   route.append(CLLocation(latitude:47.57855, longitude:-122.1359))
     
   
   route.append(CLLocation(latitude:47.57853, longitude:-122.13562))
     
   
   route.append(CLLocation(latitude:47.57851, longitude:-122.13532))
     
   
   route.append(CLLocation(latitude:47.57848, longitude:-122.13507))
     
   
   route.append(CLLocation(latitude:47.57846, longitude:-122.13489))
     
   
   route.append(CLLocation(latitude:47.57843, longitude:-122.13467))
     
   
   route.append(CLLocation(latitude:47.57841, longitude:-122.13449))
     
   
   route.append(CLLocation(latitude:47.57839, longitude:-122.13438))
     
   
   route.append(CLLocation(latitude:47.57836, longitude:-122.1342))
     
   
   route.append(CLLocation(latitude:47.57833, longitude:-122.13397))
     
   
   route.append(CLLocation(latitude:47.57824, longitude:-122.13346))
     
   
   route.append(CLLocation(latitude:47.5782, longitude:-122.13328))
     
   
   route.append(CLLocation(latitude:47.5781, longitude:-122.13287))
     
   
   route.append(CLLocation(latitude:47.57807, longitude:-122.13269))
     
   
   route.append(CLLocation(latitude:47.57803, longitude:-122.13256))
     
   
   route.append(CLLocation(latitude:47.578, longitude:-122.13241))
     
   
   route.append(CLLocation(latitude:47.57794, longitude:-122.13219))
     
   
   route.append(CLLocation(latitude:47.57784, longitude:-122.13184))
     
   
   route.append(CLLocation(latitude:47.57774, longitude:-122.13148))
     
   
   route.append(CLLocation(latitude:47.57746, longitude:-122.1307))
     
   
   route.append(CLLocation(latitude:47.57671, longitude:-122.12855))
     
   
   route.append(CLLocation(latitude:47.57641, longitude:-122.12772))
     
   
   route.append(CLLocation(latitude:47.57621, longitude:-122.12714))
     
   
   route.append(CLLocation(latitude:47.5759, longitude:-122.12626))
     
   
   route.append(CLLocation(latitude:47.57571, longitude:-122.12574))
     
   
   route.append(CLLocation(latitude:47.57483, longitude:-122.1233))
     
   
   route.append(CLLocation(latitude:47.57428, longitude:-122.12173))
     
   
   route.append(CLLocation(latitude:47.57415, longitude:-122.12137))
     
   
   route.append(CLLocation(latitude:47.57298, longitude:-122.11813))
     
   
   route.append(CLLocation(latitude:47.57292, longitude:-122.11797))
     
   
   route.append(CLLocation(latitude:47.57146, longitude:-122.11387))
     
   
   route.append(CLLocation(latitude:47.57084, longitude:-122.11213))
     
   
   route.append(CLLocation(latitude:47.57053, longitude:-122.11124))
     
   
   route.append(CLLocation(latitude:47.56991, longitude:-122.1095))
     
   
   route.append(CLLocation(latitude:47.56932, longitude:-122.10783))
     
   
   route.append(CLLocation(latitude:47.56906, longitude:-122.1071))
     
   
   route.append(CLLocation(latitude:47.56884, longitude:-122.1065))
     
   
   route.append(CLLocation(latitude:47.56869, longitude:-122.10612))
     
   
   route.append(CLLocation(latitude:47.56861, longitude:-122.10592))
     
   
   route.append(CLLocation(latitude:47.56854, longitude:-122.10576))
     
   
   route.append(CLLocation(latitude:47.56849, longitude:-122.10565))
     
   
   route.append(CLLocation(latitude:47.56839, longitude:-122.1054))
     
   
   route.append(CLLocation(latitude:47.56823, longitude:-122.10507))
     
   
   route.append(CLLocation(latitude:47.56805, longitude:-122.10472))
     
   
   route.append(CLLocation(latitude:47.5679, longitude:-122.10445))
     
   
   route.append(CLLocation(latitude:47.56772, longitude:-122.10412))
     
   
   route.append(CLLocation(latitude:47.56696, longitude:-122.10276))
     
   
   route.append(CLLocation(latitude:47.56523, longitude:-122.09964))
     
   
   route.append(CLLocation(latitude:47.56515, longitude:-122.0995))
     
   
   route.append(CLLocation(latitude:47.56508, longitude:-122.09939))
     
   
   route.append(CLLocation(latitude:47.56498, longitude:-122.0992))
     
   
   route.append(CLLocation(latitude:47.56476, longitude:-122.09881))
     
   
   route.append(CLLocation(latitude:47.56434, longitude:-122.09802))
     
   
   route.append(CLLocation(latitude:47.56426, longitude:-122.09789))
     
   
   route.append(CLLocation(latitude:47.56363, longitude:-122.09674))
     
   
   route.append(CLLocation(latitude:47.56327, longitude:-122.09608))
     
   
   route.append(CLLocation(latitude:47.56296, longitude:-122.09553))
     
   
   route.append(CLLocation(latitude:47.56263, longitude:-122.09494))
     
   
   route.append(CLLocation(latitude:47.5624, longitude:-122.09453))
     
   
   route.append(CLLocation(latitude:47.56209, longitude:-122.09397))
     
   
   route.append(CLLocation(latitude:47.56185, longitude:-122.09352))
     
   
   route.append(CLLocation(latitude:47.56088, longitude:-122.09178))
     
   
   route.append(CLLocation(latitude:47.56052, longitude:-122.09112))
     
   
   route.append(CLLocation(latitude:47.55983, longitude:-122.08988))
     
   
   route.append(CLLocation(latitude:47.55958, longitude:-122.08943))
     
   
   route.append(CLLocation(latitude:47.55928, longitude:-122.08889))
     
   
   route.append(CLLocation(latitude:47.55908, longitude:-122.08851))
     
   
   route.append(CLLocation(latitude:47.55897, longitude:-122.08832))
     
   
   route.append(CLLocation(latitude:47.55883, longitude:-122.08805))
     
   
   route.append(CLLocation(latitude:47.55869, longitude:-122.08777))
     
   
   route.append(CLLocation(latitude:47.55857, longitude:-122.08753))
     
   
   route.append(CLLocation(latitude:47.5584, longitude:-122.08714))
     
   
   route.append(CLLocation(latitude:47.55819, longitude:-122.08665))
     
   
   route.append(CLLocation(latitude:47.55805, longitude:-122.08629))
     
   
   route.append(CLLocation(latitude:47.55792, longitude:-122.08597))
     
   
   route.append(CLLocation(latitude:47.55754, longitude:-122.085))
     
   
   route.append(CLLocation(latitude:47.55735, longitude:-122.08449))
     
   
   route.append(CLLocation(latitude:47.55675, longitude:-122.08297))
     
   
   route.append(CLLocation(latitude:47.55527, longitude:-122.07913))
     
   
   route.append(CLLocation(latitude:47.55519, longitude:-122.07892))
     
   
   route.append(CLLocation(latitude:47.55491, longitude:-122.07822))
     
   
   route.append(CLLocation(latitude:47.55475, longitude:-122.0778))
     
   
   route.append(CLLocation(latitude:47.55452, longitude:-122.07722))
     
   
   route.append(CLLocation(latitude:47.5541, longitude:-122.07611))
     
   
   route.append(CLLocation(latitude:47.55384, longitude:-122.07544))
     
   
   route.append(CLLocation(latitude:47.55344, longitude:-122.07441))
     
   
   route.append(CLLocation(latitude:47.55335, longitude:-122.07417))
     
   
   route.append(CLLocation(latitude:47.55311, longitude:-122.07354))
     
   
   route.append(CLLocation(latitude:47.55295, longitude:-122.07309))
     
   
   route.append(CLLocation(latitude:47.55289, longitude:-122.07295))
     
   
   route.append(CLLocation(latitude:47.55272, longitude:-122.07247))
     
   
   route.append(CLLocation(latitude:47.55259, longitude:-122.07214))
     
   
   route.append(CLLocation(latitude:47.55238, longitude:-122.07158))
     
   
   route.append(CLLocation(latitude:47.55219, longitude:-122.07105))
     
   
   route.append(CLLocation(latitude:47.55192, longitude:-122.07035))
     
   
   route.append(CLLocation(latitude:47.55098, longitude:-122.0679))
     
   
   route.append(CLLocation(latitude:47.55061, longitude:-122.06693))
     
   
   route.append(CLLocation(latitude:47.55012, longitude:-122.06569))
     
   
   route.append(CLLocation(latitude:47.54992, longitude:-122.06518))
     
   
   route.append(CLLocation(latitude:47.54968, longitude:-122.06454))
     
   
   route.append(CLLocation(latitude:47.5493, longitude:-122.06356))
     
   
   route.append(CLLocation(latitude:47.54889, longitude:-122.06252))
     
   
   route.append(CLLocation(latitude:47.54881, longitude:-122.06231))
     
   
   route.append(CLLocation(latitude:47.54851, longitude:-122.06154))
     
   
   route.append(CLLocation(latitude:47.54829, longitude:-122.06097))
     
   
   route.append(CLLocation(latitude:47.54789, longitude:-122.05992))
     
   
   route.append(CLLocation(latitude:47.54754, longitude:-122.05901))
     
   
   route.append(CLLocation(latitude:47.54727, longitude:-122.05834))
     
   
   route.append(CLLocation(latitude:47.54709, longitude:-122.05786))
     
   
   route.append(CLLocation(latitude:47.54693, longitude:-122.05744))
     
   
   route.append(CLLocation(latitude:47.54673, longitude:-122.05692))
     
   
   route.append(CLLocation(latitude:47.54647, longitude:-122.05627))
     
   
   route.append(CLLocation(latitude:47.54635, longitude:-122.05594))
     
   
   route.append(CLLocation(latitude:47.5462, longitude:-122.05551))
     
   
   route.append(CLLocation(latitude:47.54608, longitude:-122.05518))
     
   
   route.append(CLLocation(latitude:47.54595, longitude:-122.05476))
     
   
   route.append(CLLocation(latitude:47.54584, longitude:-122.0544))
     
   
   route.append(CLLocation(latitude:47.54578, longitude:-122.05415))
     
   
   route.append(CLLocation(latitude:47.54572, longitude:-122.05392))
     
   
   route.append(CLLocation(latitude:47.54566, longitude:-122.05364))
     
   
   route.append(CLLocation(latitude:47.54558, longitude:-122.05324))
     
   
   route.append(CLLocation(latitude:47.54553, longitude:-122.05299))
     
   
   route.append(CLLocation(latitude:47.54549, longitude:-122.05276))
     
   
   route.append(CLLocation(latitude:47.54546, longitude:-122.05258))
     
   
   route.append(CLLocation(latitude:47.54543, longitude:-122.05234))
     
   
   route.append(CLLocation(latitude:47.5454, longitude:-122.05208))
     
   
   route.append(CLLocation(latitude:47.54535, longitude:-122.0517))
     
   
   route.append(CLLocation(latitude:47.54533, longitude:-122.0515))
     
   
   route.append(CLLocation(latitude:47.54531, longitude:-122.05118))
     
   
   route.append(CLLocation(latitude:47.54529, longitude:-122.05095))
     
   
   route.append(CLLocation(latitude:47.54524, longitude:-122.05038))
     
   
   route.append(CLLocation(latitude:47.54518, longitude:-122.04977))
     
   
   route.append(CLLocation(latitude:47.54512, longitude:-122.04904))
     
   
   route.append(CLLocation(latitude:47.54507, longitude:-122.04852))
     
   
   route.append(CLLocation(latitude:47.54504, longitude:-122.04821))
     
   
   route.append(CLLocation(latitude:47.545, longitude:-122.04767))
     
   
   route.append(CLLocation(latitude:47.54496, longitude:-122.04737))
     
   
   route.append(CLLocation(latitude:47.54495, longitude:-122.04721))
     
   
   route.append(CLLocation(latitude:47.54492, longitude:-122.04699))
     
   
   route.append(CLLocation(latitude:47.54488, longitude:-122.04678))
     
   
   route.append(CLLocation(latitude:47.54485, longitude:-122.04656))
     
   
   route.append(CLLocation(latitude:47.5448, longitude:-122.04628))
     
   
   route.append(CLLocation(latitude:47.54475, longitude:-122.04607))
     
   
   route.append(CLLocation(latitude:47.54472, longitude:-122.0459))
     
   
   route.append(CLLocation(latitude:47.54466, longitude:-122.04564))
     
   
   route.append(CLLocation(latitude:47.54461, longitude:-122.04546))
     
   
   route.append(CLLocation(latitude:47.54457, longitude:-122.04528))
     
   
   route.append(CLLocation(latitude:47.54452, longitude:-122.04511))
     
   
   route.append(CLLocation(latitude:47.54449, longitude:-122.045))
     
   
   route.append(CLLocation(latitude:47.54441, longitude:-122.04471))
     
   
   route.append(CLLocation(latitude:47.54436, longitude:-122.04459))
     
   
   route.append(CLLocation(latitude:47.54431, longitude:-122.04444))
     
   
   route.append(CLLocation(latitude:47.54424, longitude:-122.04424))
     
   
   route.append(CLLocation(latitude:47.54416, longitude:-122.04402))
     
   
   route.append(CLLocation(latitude:47.54406, longitude:-122.04375))
     
   
   route.append(CLLocation(latitude:47.54398, longitude:-122.04355))
     
   
   route.append(CLLocation(latitude:47.54386, longitude:-122.04329))
     
   
   route.append(CLLocation(latitude:47.54379, longitude:-122.04312))
     
   
   route.append(CLLocation(latitude:47.54371, longitude:-122.04295))
     
   
   route.append(CLLocation(latitude:47.54364, longitude:-122.0428))
     
   
   route.append(CLLocation(latitude:47.5434, longitude:-122.0423))
     
   
   route.append(CLLocation(latitude:47.54319, longitude:-122.04185))
     
   
   route.append(CLLocation(latitude:47.54256, longitude:-122.04058))
     
   
   route.append(CLLocation(latitude:47.54247, longitude:-122.04043))
     
   
   route.append(CLLocation(latitude:47.54242, longitude:-122.04033))
     
   
   route.append(CLLocation(latitude:47.54236, longitude:-122.04022))
     
   
   route.append(CLLocation(latitude:47.54228, longitude:-122.04006))
     
   
   route.append(CLLocation(latitude:47.54212, longitude:-122.03968))
     
   
   route.append(CLLocation(latitude:47.54206, longitude:-122.03952))
     
   
   route.append(CLLocation(latitude:47.54198, longitude:-122.03934))
     
   
   route.append(CLLocation(latitude:47.54183, longitude:-122.03906))
     
   
   route.append(CLLocation(latitude:47.54167, longitude:-122.03873))
     
   
   route.append(CLLocation(latitude:47.54153, longitude:-122.03843))
     
   
   route.append(CLLocation(latitude:47.54142, longitude:-122.0382))
     
   
   route.append(CLLocation(latitude:47.54128, longitude:-122.03792))
     
   
   route.append(CLLocation(latitude:47.54116, longitude:-122.03767))
     
   
   route.append(CLLocation(latitude:47.54098, longitude:-122.03733))
     
   
   route.append(CLLocation(latitude:47.54089, longitude:-122.03716))
     
   
   route.append(CLLocation(latitude:47.54068, longitude:-122.0368))
     
   
   route.append(CLLocation(latitude:47.5406, longitude:-122.03667))
     
   
   route.append(CLLocation(latitude:47.54047, longitude:-122.03647))
     
   
   route.append(CLLocation(latitude:47.54031, longitude:-122.03622))
     
   
   route.append(CLLocation(latitude:47.54022, longitude:-122.03609))
     
   
   route.append(CLLocation(latitude:47.53999, longitude:-122.03575))
     
   
   route.append(CLLocation(latitude:47.53964, longitude:-122.03528))
     
   
   route.append(CLLocation(latitude:47.53942, longitude:-122.03502))
     
   
   route.append(CLLocation(latitude:47.53924, longitude:-122.03481))
     
   
   route.append(CLLocation(latitude:47.53898, longitude:-122.03451))
     
   
   route.append(CLLocation(latitude:47.5388, longitude:-122.03433))
     
   
   route.append(CLLocation(latitude:47.5386, longitude:-122.03413))
     
   
   route.append(CLLocation(latitude:47.53836, longitude:-122.03389))
     
   
   route.append(CLLocation(latitude:47.53823, longitude:-122.03378))
     
   
   route.append(CLLocation(latitude:47.53782, longitude:-122.03342))
     
   
   route.append(CLLocation(latitude:47.53741, longitude:-122.03307))
     
   
   route.append(CLLocation(latitude:47.53714, longitude:-122.03283))
     
   
   route.append(CLLocation(latitude:47.53611, longitude:-122.03192))
     
   
   route.append(CLLocation(latitude:47.53589, longitude:-122.03173))
     
   
   route.append(CLLocation(latitude:47.53571, longitude:-122.03157))
     
   
   route.append(CLLocation(latitude:47.53523, longitude:-122.03115))
     
   
   route.append(CLLocation(latitude:47.53502, longitude:-122.03097))
     
   
   route.append(CLLocation(latitude:47.53462, longitude:-122.03061))
     
   
   route.append(CLLocation(latitude:47.53431, longitude:-122.03034))
     
   
   route.append(CLLocation(latitude:47.53389, longitude:-122.02994))
     
   
   route.append(CLLocation(latitude:47.5336, longitude:-122.02966))
     
   
   route.append(CLLocation(latitude:47.53337, longitude:-122.02941))
     
   
   route.append(CLLocation(latitude:47.53319, longitude:-122.02919))
     
   
   route.append(CLLocation(latitude:47.53304, longitude:-122.02897))
     
   
   route.append(CLLocation(latitude:47.5327, longitude:-122.02843))
     
   
   route.append(CLLocation(latitude:47.53252, longitude:-122.0281))
     
   
   route.append(CLLocation(latitude:47.53237, longitude:-122.02778))
     
   
   route.append(CLLocation(latitude:47.53223, longitude:-122.02744))
     
   
   route.append(CLLocation(latitude:47.53212, longitude:-122.02715))
     
   
   route.append(CLLocation(latitude:47.53199, longitude:-122.02676))
     
   
   route.append(CLLocation(latitude:47.53191, longitude:-122.02649))
     
   
   route.append(CLLocation(latitude:47.53183, longitude:-122.02619))
     
   
   route.append(CLLocation(latitude:47.5317, longitude:-122.02555))
     
   
   route.append(CLLocation(latitude:47.53163, longitude:-122.02499))
     
   
   route.append(CLLocation(latitude:47.53159, longitude:-122.02454))
     
   
   route.append(CLLocation(latitude:47.53157, longitude:-122.02408))
     
   
   route.append(CLLocation(latitude:47.53156, longitude:-122.0237))
     
   
   route.append(CLLocation(latitude:47.53157, longitude:-122.02341))
     
   
   route.append(CLLocation(latitude:47.53161, longitude:-122.02284))
     
   
   route.append(CLLocation(latitude:47.53166, longitude:-122.02244))
     
   
   route.append(CLLocation(latitude:47.53175, longitude:-122.0219))
     
   
   route.append(CLLocation(latitude:47.53185, longitude:-122.02145))
     
   
   route.append(CLLocation(latitude:47.53198, longitude:-122.02095))
     
   
   route.append(CLLocation(latitude:47.5321, longitude:-122.02058))
     
   
   route.append(CLLocation(latitude:47.53229, longitude:-122.0201))
     
   
   route.append(CLLocation(latitude:47.53251, longitude:-122.01961))
     
   
   route.append(CLLocation(latitude:47.53269, longitude:-122.01928))
     
   
   route.append(CLLocation(latitude:47.53405, longitude:-122.01684))
     
   
   route.append(CLLocation(latitude:47.53433, longitude:-122.01633))
     
   
   route.append(CLLocation(latitude:47.53446, longitude:-122.0161))
     
   
   route.append(CLLocation(latitude:47.53483, longitude:-122.01542))
     
   
   route.append(CLLocation(latitude:47.53508, longitude:-122.01497))
     
   
   route.append(CLLocation(latitude:47.53517, longitude:-122.01479))
     
   
   route.append(CLLocation(latitude:47.53528, longitude:-122.01458))
     
   
   route.append(CLLocation(latitude:47.5355, longitude:-122.01408))
     
   
   route.append(CLLocation(latitude:47.53563, longitude:-122.01376))
     
   
   route.append(CLLocation(latitude:47.53572, longitude:-122.01352))
     
   
   route.append(CLLocation(latitude:47.53588, longitude:-122.01309))
     
   
   route.append(CLLocation(latitude:47.53601, longitude:-122.01267))
     
   
   route.append(CLLocation(latitude:47.53613, longitude:-122.01221))
     
   
   route.append(CLLocation(latitude:47.5362, longitude:-122.01191))
     
   
   route.append(CLLocation(latitude:47.53628, longitude:-122.01158))
     
   
   route.append(CLLocation(latitude:47.53634, longitude:-122.01126))
     
   
   route.append(CLLocation(latitude:47.53639, longitude:-122.01092))
     
   
   route.append(CLLocation(latitude:47.53644, longitude:-122.0106))
     
   
   route.append(CLLocation(latitude:47.53646, longitude:-122.01031))
     
   
   route.append(CLLocation(latitude:47.53649, longitude:-122.00999))
     
   
   route.append(CLLocation(latitude:47.53651, longitude:-122.00966))
     
   
   route.append(CLLocation(latitude:47.53652, longitude:-122.00933))
     
   
   route.append(CLLocation(latitude:47.53651, longitude:-122.00894))
     
   
   route.append(CLLocation(latitude:47.5365, longitude:-122.0087))
     
   
   route.append(CLLocation(latitude:47.53648, longitude:-122.0083))
     
   
   route.append(CLLocation(latitude:47.53643, longitude:-122.00788))
     
   
   route.append(CLLocation(latitude:47.5364, longitude:-122.00762))
     
   
   route.append(CLLocation(latitude:47.53636, longitude:-122.0074))
     
   
   route.append(CLLocation(latitude:47.5363, longitude:-122.00707))
     
   
   route.append(CLLocation(latitude:47.5362, longitude:-122.00661))
     
   
   route.append(CLLocation(latitude:47.53615, longitude:-122.00644))
     
   
   route.append(CLLocation(latitude:47.53611, longitude:-122.0063))
     
   
   route.append(CLLocation(latitude:47.53609, longitude:-122.0062))
     
   
   route.append(CLLocation(latitude:47.53601, longitude:-122.00597))
     
   
   route.append(CLLocation(latitude:47.53596, longitude:-122.00582))
     
   
   route.append(CLLocation(latitude:47.53589, longitude:-122.0056))
     
   
   route.append(CLLocation(latitude:47.53583, longitude:-122.00544))
     
   
   route.append(CLLocation(latitude:47.53573, longitude:-122.0052))
     
   
   route.append(CLLocation(latitude:47.53559, longitude:-122.00488))
     
   
   route.append(CLLocation(latitude:47.53531, longitude:-122.00428))
     
   
   route.append(CLLocation(latitude:47.53508, longitude:-122.00377))
     
   
   route.append(CLLocation(latitude:47.53431, longitude:-122.00207))
     
   
   route.append(CLLocation(latitude:47.53406, longitude:-122.00152))
     
   
   route.append(CLLocation(latitude:47.5338, longitude:-122.00091))
     
   
   route.append(CLLocation(latitude:47.53347, longitude:-122.00007))
     
   
   route.append(CLLocation(latitude:47.53331, longitude:-121.99963))
     
   
   route.append(CLLocation(latitude:47.53319, longitude:-121.99929))
     
   
   route.append(CLLocation(latitude:47.53299, longitude:-121.99872))
     
   
   route.append(CLLocation(latitude:47.53276, longitude:-121.99803))
     
   
   route.append(CLLocation(latitude:47.53253, longitude:-121.99725))
     
   
   route.append(CLLocation(latitude:47.53238, longitude:-121.9967))
     
   
   route.append(CLLocation(latitude:47.53224, longitude:-121.99619))
     
   
   route.append(CLLocation(latitude:47.53212, longitude:-121.99573))
     
   
   route.append(CLLocation(latitude:47.53204, longitude:-121.99538))
     
   
   route.append(CLLocation(latitude:47.53194, longitude:-121.99496))
     
   
   route.append(CLLocation(latitude:47.53182, longitude:-121.99436))
     
   
   route.append(CLLocation(latitude:47.53172, longitude:-121.99389))
     
   
   route.append(CLLocation(latitude:47.53159, longitude:-121.99317))
     
   
   route.append(CLLocation(latitude:47.53153, longitude:-121.99281))
     
   
   route.append(CLLocation(latitude:47.53146, longitude:-121.99234))
     
   
   route.append(CLLocation(latitude:47.53138, longitude:-121.99177))
     
   
   route.append(CLLocation(latitude:47.5313, longitude:-121.99118))
     
   
   route.append(CLLocation(latitude:47.53124, longitude:-121.99067))
     
   
   route.append(CLLocation(latitude:47.53119, longitude:-121.99019))
     
   
   route.append(CLLocation(latitude:47.53111, longitude:-121.9893))
     
   
   route.append(CLLocation(latitude:47.53106, longitude:-121.9886))
     
   
   route.append(CLLocation(latitude:47.53091, longitude:-121.98533))
     
   
   route.append(CLLocation(latitude:47.53087, longitude:-121.9846))
     
   
   route.append(CLLocation(latitude:47.53084, longitude:-121.98394))
     
   
   route.append(CLLocation(latitude:47.5308, longitude:-121.98316))
     
   
   route.append(CLLocation(latitude:47.53079, longitude:-121.98287))
     
   
   route.append(CLLocation(latitude:47.53079, longitude:-121.98258))
     
   
   route.append(CLLocation(latitude:47.5308, longitude:-121.98222))
     
   
   route.append(CLLocation(latitude:47.53083, longitude:-121.9818))
     
   
   route.append(CLLocation(latitude:47.53086, longitude:-121.98153))
     
   
   route.append(CLLocation(latitude:47.53089, longitude:-121.9812))
     
   
   route.append(CLLocation(latitude:47.53093, longitude:-121.98092))
     
   
   route.append(CLLocation(latitude:47.53099, longitude:-121.98061))
     
   
   route.append(CLLocation(latitude:47.53104, longitude:-121.98033))
     
   
   route.append(CLLocation(latitude:47.53112, longitude:-121.97996))
     
   
   route.append(CLLocation(latitude:47.53114, longitude:-121.97989))
     
   
   route.append(CLLocation(latitude:47.53114, longitude:-121.97988))
     
   
   route.append(CLLocation(latitude:47.53125, longitude:-121.97951))
     
   
   route.append(CLLocation(latitude:47.53133, longitude:-121.97928))
     
   
   route.append(CLLocation(latitude:47.53145, longitude:-121.97897))
     
   
   route.append(CLLocation(latitude:47.53166, longitude:-121.97846))
     
   
   route.append(CLLocation(latitude:47.53177, longitude:-121.97823))
     
   
   route.append(CLLocation(latitude:47.53183, longitude:-121.97811))
     
   
   route.append(CLLocation(latitude:47.53199, longitude:-121.97781))
     
   
   route.append(CLLocation(latitude:47.53214, longitude:-121.97753))
     
   
   route.append(CLLocation(latitude:47.53227, longitude:-121.97732))
     
   
   route.append(CLLocation(latitude:47.53241, longitude:-121.97714))
     
   
   route.append(CLLocation(latitude:47.53257, longitude:-121.9769))
     
   
   route.append(CLLocation(latitude:47.53276, longitude:-121.97665))
     
   
   route.append(CLLocation(latitude:47.53298, longitude:-121.9764))
     
   
   route.append(CLLocation(latitude:47.53329, longitude:-121.97606))
     
   
   route.append(CLLocation(latitude:47.5336, longitude:-121.97571))
     
   
   route.append(CLLocation(latitude:47.53396, longitude:-121.97531))
     
   
   route.append(CLLocation(latitude:47.53409, longitude:-121.97516))
     
   
   route.append(CLLocation(latitude:47.53424, longitude:-121.97498))
     
   
   route.append(CLLocation(latitude:47.53439, longitude:-121.97479))
     
   
   route.append(CLLocation(latitude:47.53455, longitude:-121.97456))
     
   
   route.append(CLLocation(latitude:47.53458, longitude:-121.97451))
     
   
   route.append(CLLocation(latitude:47.53469, longitude:-121.97433))
     
   
   route.append(CLLocation(latitude:47.53477, longitude:-121.9742))
     
   
   route.append(CLLocation(latitude:47.53486, longitude:-121.97403))
     
   
   route.append(CLLocation(latitude:47.53498, longitude:-121.97381))
     
   
   route.append(CLLocation(latitude:47.5351, longitude:-121.97355))
     
   
   route.append(CLLocation(latitude:47.53521, longitude:-121.97329))
     
   
   route.append(CLLocation(latitude:47.53528, longitude:-121.9731))
     
   
   route.append(CLLocation(latitude:47.53537, longitude:-121.97285))
     
   
   route.append(CLLocation(latitude:47.53543, longitude:-121.97263))
     
   
   route.append(CLLocation(latitude:47.5355, longitude:-121.9724))
     
   
   route.append(CLLocation(latitude:47.53558, longitude:-121.97208))
     
   
   route.append(CLLocation(latitude:47.53566, longitude:-121.97167))
     
   
   route.append(CLLocation(latitude:47.5357, longitude:-121.97144))
     
   
   route.append(CLLocation(latitude:47.53574, longitude:-121.97118))
     
   
   route.append(CLLocation(latitude:47.53577, longitude:-121.97079))
     
   
   route.append(CLLocation(latitude:47.5358, longitude:-121.9704))
     
   
   route.append(CLLocation(latitude:47.5358, longitude:-121.97009))
     
   
   route.append(CLLocation(latitude:47.5358, longitude:-121.96971))
     
   
   route.append(CLLocation(latitude:47.53578, longitude:-121.96933))
     
   
   route.append(CLLocation(latitude:47.53574, longitude:-121.96895))
     
   
   route.append(CLLocation(latitude:47.53568, longitude:-121.96855))
     
   
   route.append(CLLocation(latitude:47.53562, longitude:-121.9682))
     
   
   route.append(CLLocation(latitude:47.53558, longitude:-121.96799))
     
   
   route.append(CLLocation(latitude:47.53554, longitude:-121.96784))
     
   
   route.append(CLLocation(latitude:47.5355, longitude:-121.96768))
     
   
   route.append(CLLocation(latitude:47.53546, longitude:-121.96753))
     
   
   route.append(CLLocation(latitude:47.53542, longitude:-121.96737))
     
   
   route.append(CLLocation(latitude:47.53534, longitude:-121.96712))
     
   
   route.append(CLLocation(latitude:47.53518, longitude:-121.96664))
     
   
   route.append(CLLocation(latitude:47.5349, longitude:-121.96576))
     
   
   route.append(CLLocation(latitude:47.53441, longitude:-121.96426))
     
   
   route.append(CLLocation(latitude:47.53397, longitude:-121.96292))
     
   
   route.append(CLLocation(latitude:47.53366, longitude:-121.96201))
     
   
   route.append(CLLocation(latitude:47.53357, longitude:-121.96175))
     
   
   route.append(CLLocation(latitude:47.53351, longitude:-121.96157))
     
   
   route.append(CLLocation(latitude:47.53342, longitude:-121.96126))
     
   
   route.append(CLLocation(latitude:47.53336, longitude:-121.96107))
     
   
   route.append(CLLocation(latitude:47.53329, longitude:-121.96078))
     
   
   route.append(CLLocation(latitude:47.53323, longitude:-121.96052))
     
   
   route.append(CLLocation(latitude:47.53315, longitude:-121.96017))
     
   
   route.append(CLLocation(latitude:47.53306, longitude:-121.95971))
     
   
   route.append(CLLocation(latitude:47.53294, longitude:-121.9589))
     
   
   route.append(CLLocation(latitude:47.53283, longitude:-121.95783))
     
   
   route.append(CLLocation(latitude:47.53277, longitude:-121.95726))
     
   
   route.append(CLLocation(latitude:47.53224, longitude:-121.95173))
     
   
   route.append(CLLocation(latitude:47.53187, longitude:-121.9479))
     
   
   route.append(CLLocation(latitude:47.53183, longitude:-121.94743))
     
   
   route.append(CLLocation(latitude:47.53179, longitude:-121.94704))
     
   
   route.append(CLLocation(latitude:47.53177, longitude:-121.94682))
     
   
   route.append(CLLocation(latitude:47.53174, longitude:-121.94658))
     
   
   route.append(CLLocation(latitude:47.5317, longitude:-121.9463))
     
   
   route.append(CLLocation(latitude:47.53165, longitude:-121.94604))
     
   
   route.append(CLLocation(latitude:47.53159, longitude:-121.94577))
     
   
   route.append(CLLocation(latitude:47.53154, longitude:-121.94554))
     
   
   route.append(CLLocation(latitude:47.53148, longitude:-121.94528))
     
   
   route.append(CLLocation(latitude:47.53141, longitude:-121.94502))
     
   
   route.append(CLLocation(latitude:47.53134, longitude:-121.9448))
     
   
   route.append(CLLocation(latitude:47.53126, longitude:-121.94454))
     
   
   route.append(CLLocation(latitude:47.53118, longitude:-121.94433))
     
   
   route.append(CLLocation(latitude:47.53112, longitude:-121.94415))
     
   
   route.append(CLLocation(latitude:47.53107, longitude:-121.94404))
     
   
   route.append(CLLocation(latitude:47.53102, longitude:-121.9439))
     
   
   route.append(CLLocation(latitude:47.53095, longitude:-121.94375))
     
   
   route.append(CLLocation(latitude:47.53086, longitude:-121.94356))
     
   
   route.append(CLLocation(latitude:47.5308, longitude:-121.94343))
     
   
   route.append(CLLocation(latitude:47.53072, longitude:-121.94327))
     
   
   route.append(CLLocation(latitude:47.53063, longitude:-121.9431))
     
   
   route.append(CLLocation(latitude:47.53056, longitude:-121.94296))
     
   
   route.append(CLLocation(latitude:47.53047, longitude:-121.94281))
     
   
   route.append(CLLocation(latitude:47.53036, longitude:-121.94264))
     
   
   route.append(CLLocation(latitude:47.53028, longitude:-121.94251))
     
   
   route.append(CLLocation(latitude:47.53021, longitude:-121.94242))
     
   
   route.append(CLLocation(latitude:47.53012, longitude:-121.94228))
     
   
   route.append(CLLocation(latitude:47.53002, longitude:-121.94215))
     
   
   route.append(CLLocation(latitude:47.52995, longitude:-121.94206))
     
   
   route.append(CLLocation(latitude:47.52988, longitude:-121.94196))
     
   
   route.append(CLLocation(latitude:47.5298, longitude:-121.94187))
     
   
   route.append(CLLocation(latitude:47.52958, longitude:-121.94162))
     
   
   route.append(CLLocation(latitude:47.52946, longitude:-121.9415))
     
   
   route.append(CLLocation(latitude:47.52938, longitude:-121.94142))
     
   
   route.append(CLLocation(latitude:47.52929, longitude:-121.94134))
     
   
   route.append(CLLocation(latitude:47.52919, longitude:-121.94124))
     
   
   route.append(CLLocation(latitude:47.52908, longitude:-121.94115))
     
   
   route.append(CLLocation(latitude:47.52891, longitude:-121.94102))
     
   
   route.append(CLLocation(latitude:47.52879, longitude:-121.94092))
     
   
   route.append(CLLocation(latitude:47.52865, longitude:-121.94082))
     
   
   route.append(CLLocation(latitude:47.52822, longitude:-121.9405))
     
   
   route.append(CLLocation(latitude:47.52757, longitude:-121.94))
     
   
   route.append(CLLocation(latitude:47.52698, longitude:-121.93956))
     
   
   route.append(CLLocation(latitude:47.52636, longitude:-121.93909))
     
   
   route.append(CLLocation(latitude:47.5242, longitude:-121.93746))
     
   
   route.append(CLLocation(latitude:47.52402, longitude:-121.93732))
     
   
   route.append(CLLocation(latitude:47.52384, longitude:-121.93719))
     
   
   route.append(CLLocation(latitude:47.52371, longitude:-121.9371))
     
   
   route.append(CLLocation(latitude:47.52359, longitude:-121.937))
     
   
   route.append(CLLocation(latitude:47.52346, longitude:-121.93689))
     
   
   route.append(CLLocation(latitude:47.52334, longitude:-121.93678))
     
   
   route.append(CLLocation(latitude:47.52323, longitude:-121.93667))
     
   
   route.append(CLLocation(latitude:47.52313, longitude:-121.93657))
     
   
   route.append(CLLocation(latitude:47.52302, longitude:-121.93646))
     
   
   route.append(CLLocation(latitude:47.52293, longitude:-121.93636))
     
   
   route.append(CLLocation(latitude:47.52283, longitude:-121.93624))
     
   
   route.append(CLLocation(latitude:47.52272, longitude:-121.93609))
     
   
   route.append(CLLocation(latitude:47.52225, longitude:-121.93545))
     
   
   route.append(CLLocation(latitude:47.5222, longitude:-121.93536))
     
   
   route.append(CLLocation(latitude:47.52214, longitude:-121.93527))
     
   
   route.append(CLLocation(latitude:47.52207, longitude:-121.93514))
     
   
   route.append(CLLocation(latitude:47.52201, longitude:-121.93503))
     
   
   route.append(CLLocation(latitude:47.52194, longitude:-121.93489))
     
   
   route.append(CLLocation(latitude:47.52185, longitude:-121.93471))
     
   
   route.append(CLLocation(latitude:47.52169, longitude:-121.93436))
     
   
   route.append(CLLocation(latitude:47.52154, longitude:-121.93399))
     
   
   route.append(CLLocation(latitude:47.52147, longitude:-121.9338))
     
   
   route.append(CLLocation(latitude:47.52139, longitude:-121.93356))
     
   
   route.append(CLLocation(latitude:47.52129, longitude:-121.93326))
     
   
   route.append(CLLocation(latitude:47.52122, longitude:-121.933))
     
   
   route.append(CLLocation(latitude:47.52116, longitude:-121.93278))
     
   
   route.append(CLLocation(latitude:47.52112, longitude:-121.9326))
     
   
   route.append(CLLocation(latitude:47.52105, longitude:-121.93237))
     
   
   route.append(CLLocation(latitude:47.52078, longitude:-121.93136))
     
   
   route.append(CLLocation(latitude:47.52065, longitude:-121.93093))
     
   
   route.append(CLLocation(latitude:47.52058, longitude:-121.93067))
     
   
   route.append(CLLocation(latitude:47.52042, longitude:-121.93011))
     
   
   route.append(CLLocation(latitude:47.52034, longitude:-121.92987))
     
   
   route.append(CLLocation(latitude:47.52021, longitude:-121.92952))
     
   
   route.append(CLLocation(latitude:47.51845, longitude:-121.92531))
     
   
   route.append(CLLocation(latitude:47.51818, longitude:-121.92466))
     
   
   route.append(CLLocation(latitude:47.51814, longitude:-121.92457))
     
   
   route.append(CLLocation(latitude:47.5179, longitude:-121.924))
     
   
   route.append(CLLocation(latitude:47.51771, longitude:-121.92355))
     
   
   route.append(CLLocation(latitude:47.51746, longitude:-121.92295))
     
   
   route.append(CLLocation(latitude:47.51723, longitude:-121.92243))
     
   
   route.append(CLLocation(latitude:47.5169, longitude:-121.92167))
     
   
   route.append(CLLocation(latitude:47.5167, longitude:-121.92123))
     
   
   route.append(CLLocation(latitude:47.51644, longitude:-121.92069))
     
   
   route.append(CLLocation(latitude:47.51598, longitude:-121.91977))
     
   
   route.append(CLLocation(latitude:47.51579, longitude:-121.91942))
     
   
   route.append(CLLocation(latitude:47.51442, longitude:-121.91688))
     
   
   route.append(CLLocation(latitude:47.51434, longitude:-121.91673))
     
   
   route.append(CLLocation(latitude:47.51371, longitude:-121.91554))
     
   
   route.append(CLLocation(latitude:47.51262, longitude:-121.91341))
     
   
   route.append(CLLocation(latitude:47.5122, longitude:-121.9126))
     
   
   route.append(CLLocation(latitude:47.51196, longitude:-121.91214))
     
   
   route.append(CLLocation(latitude:47.51181, longitude:-121.91186))
     
   
   route.append(CLLocation(latitude:47.51161, longitude:-121.91148))
     
   
   route.append(CLLocation(latitude:47.51147, longitude:-121.91125))
     
   
   route.append(CLLocation(latitude:47.51135, longitude:-121.91105))
     
   
   route.append(CLLocation(latitude:47.51123, longitude:-121.91086))
     
   
   route.append(CLLocation(latitude:47.51113, longitude:-121.91069))
     
   
   route.append(CLLocation(latitude:47.51102, longitude:-121.91052))
     
   
   route.append(CLLocation(latitude:47.51086, longitude:-121.91028))
     
   
   route.append(CLLocation(latitude:47.51062, longitude:-121.90993))
     
   
   route.append(CLLocation(latitude:47.51045, longitude:-121.9097))
     
   
   route.append(CLLocation(latitude:47.51024, longitude:-121.90941))
     
   
   route.append(CLLocation(latitude:47.51003, longitude:-121.90914))
     
   
   route.append(CLLocation(latitude:47.50981, longitude:-121.90886))
     
   
   route.append(CLLocation(latitude:47.50939, longitude:-121.90835))
     
   
   route.append(CLLocation(latitude:47.50891, longitude:-121.90776))
     
   
   route.append(CLLocation(latitude:47.50852, longitude:-121.90729))
     
   
   route.append(CLLocation(latitude:47.5083, longitude:-121.90701))
     
   
   route.append(CLLocation(latitude:47.50813, longitude:-121.90679))
     
   
   route.append(CLLocation(latitude:47.50797, longitude:-121.90656))
     
   
   route.append(CLLocation(latitude:47.50786, longitude:-121.9064))
     
   
   route.append(CLLocation(latitude:47.50773, longitude:-121.9062))
     
   
   route.append(CLLocation(latitude:47.50765, longitude:-121.90607))
     
   
   route.append(CLLocation(latitude:47.50753, longitude:-121.90585))
     
   
   route.append(CLLocation(latitude:47.5073, longitude:-121.90544))
     
   
   route.append(CLLocation(latitude:47.5072, longitude:-121.90524))
     
   
   route.append(CLLocation(latitude:47.50709, longitude:-121.90502))
     
   
   route.append(CLLocation(latitude:47.50697, longitude:-121.90475))
     
   
   route.append(CLLocation(latitude:47.50678, longitude:-121.90427))
     
   
   route.append(CLLocation(latitude:47.5066, longitude:-121.90378))
     
   
   route.append(CLLocation(latitude:47.50644, longitude:-121.90327))
     
   
   route.append(CLLocation(latitude:47.50637, longitude:-121.90299))
     
   
   route.append(CLLocation(latitude:47.50629, longitude:-121.90271))
     
   
   route.append(CLLocation(latitude:47.50622, longitude:-121.90239))
     
   
   route.append(CLLocation(latitude:47.50615, longitude:-121.90207))
     
   
   route.append(CLLocation(latitude:47.50614, longitude:-121.902))
     
   
   route.append(CLLocation(latitude:47.50606, longitude:-121.90154))
     
   
   route.append(CLLocation(latitude:47.50599, longitude:-121.90102))
     
   
   route.append(CLLocation(latitude:47.50596, longitude:-121.90074))
     
   
   route.append(CLLocation(latitude:47.50593, longitude:-121.90046))
     
   
   route.append(CLLocation(latitude:47.5059, longitude:-121.89994))
     
   
   route.append(CLLocation(latitude:47.50589, longitude:-121.89941))
     
   
   route.append(CLLocation(latitude:47.5059, longitude:-121.89895))
     
   
   route.append(CLLocation(latitude:47.50591, longitude:-121.89866))
     
   
   route.append(CLLocation(latitude:47.50592, longitude:-121.89837))
     
   
   route.append(CLLocation(latitude:47.50594, longitude:-121.89807))
     
   
   route.append(CLLocation(latitude:47.50597, longitude:-121.89778))
     
   
   route.append(CLLocation(latitude:47.506, longitude:-121.89749))
     
   
   route.append(CLLocation(latitude:47.50604, longitude:-121.89721))
     
   
   route.append(CLLocation(latitude:47.50608, longitude:-121.89688))
     
   
   route.append(CLLocation(latitude:47.5065, longitude:-121.89438))
     
   
   route.append(CLLocation(latitude:47.5068, longitude:-121.8927))
     
   
   route.append(CLLocation(latitude:47.50695, longitude:-121.8918))
     
   
   route.append(CLLocation(latitude:47.50712, longitude:-121.89083))
     
   
   route.append(CLLocation(latitude:47.5072, longitude:-121.89035))
     
   
   route.append(CLLocation(latitude:47.50817, longitude:-121.88457))
     
   
   route.append(CLLocation(latitude:47.5083, longitude:-121.88377))
     
   
   route.append(CLLocation(latitude:47.50833, longitude:-121.88358))
     
   
   route.append(CLLocation(latitude:47.50849, longitude:-121.8826))
     
   
   route.append(CLLocation(latitude:47.50893, longitude:-121.88002))
     
   
   route.append(CLLocation(latitude:47.50925, longitude:-121.87805))
     
   
   route.append(CLLocation(latitude:47.50954, longitude:-121.87633))
     
   
   route.append(CLLocation(latitude:47.50973, longitude:-121.87521))
     
   
   route.append(CLLocation(latitude:47.50989, longitude:-121.87425))
     
   
   route.append(CLLocation(latitude:47.50998, longitude:-121.87367))
     
   
   route.append(CLLocation(latitude:47.51061, longitude:-121.86992))
     
   
   route.append(CLLocation(latitude:47.51065, longitude:-121.86965))
     
   
   route.append(CLLocation(latitude:47.51089, longitude:-121.8682))
     
   
   route.append(CLLocation(latitude:47.51094, longitude:-121.86783))
     
   
   route.append(CLLocation(latitude:47.51099, longitude:-121.86746))
     
   
   route.append(CLLocation(latitude:47.51103, longitude:-121.86716))
     
   
   route.append(CLLocation(latitude:47.51106, longitude:-121.86689))
     
   
   route.append(CLLocation(latitude:47.51109, longitude:-121.86656))
     
   
   route.append(CLLocation(latitude:47.51112, longitude:-121.86623))
     
   
   route.append(CLLocation(latitude:47.51114, longitude:-121.86583))
     
   
   route.append(CLLocation(latitude:47.51116, longitude:-121.86552))
     
   
   route.append(CLLocation(latitude:47.51117, longitude:-121.86519))
     
   
   route.append(CLLocation(latitude:47.51118, longitude:-121.86487))
     
   
   route.append(CLLocation(latitude:47.51118, longitude:-121.86465))
     
   
   route.append(CLLocation(latitude:47.51118, longitude:-121.86441))
     
   
   route.append(CLLocation(latitude:47.51118, longitude:-121.86418))
     
   
   route.append(CLLocation(latitude:47.51116, longitude:-121.86332))
     
   
   route.append(CLLocation(latitude:47.51112, longitude:-121.86249))
     
   
   route.append(CLLocation(latitude:47.51105, longitude:-121.86033))
     
   
   route.append(CLLocation(latitude:47.51096, longitude:-121.85818))
     
   
   route.append(CLLocation(latitude:47.51096, longitude:-121.85791))
     
   
   route.append(CLLocation(latitude:47.51096, longitude:-121.85773))
     
   
   route.append(CLLocation(latitude:47.51097, longitude:-121.85751))
     
   
   route.append(CLLocation(latitude:47.51099, longitude:-121.85726))
     
   
   route.append(CLLocation(latitude:47.511, longitude:-121.85699))
     
   
   route.append(CLLocation(latitude:47.51103, longitude:-121.85671))
     
   
   route.append(CLLocation(latitude:47.51106, longitude:-121.85648))
     
   
   route.append(CLLocation(latitude:47.51108, longitude:-121.85628))
     
   
   route.append(CLLocation(latitude:47.51111, longitude:-121.8561))
     
   
   route.append(CLLocation(latitude:47.51113, longitude:-121.85599))
     
   
   route.append(CLLocation(latitude:47.51116, longitude:-121.85578))
     
   
   route.append(CLLocation(latitude:47.51121, longitude:-121.85552))
     
   
   route.append(CLLocation(latitude:47.51126, longitude:-121.85531))
     
   
   route.append(CLLocation(latitude:47.51132, longitude:-121.85506))
     
   
   route.append(CLLocation(latitude:47.51139, longitude:-121.85479))
     
   
   route.append(CLLocation(latitude:47.51172, longitude:-121.85359))
     
   
   route.append(CLLocation(latitude:47.51215, longitude:-121.85198))
     
   
   route.append(CLLocation(latitude:47.51275, longitude:-121.84978))
     
   
   route.append(CLLocation(latitude:47.51302, longitude:-121.84878))
     
   
   route.append(CLLocation(latitude:47.51329, longitude:-121.84779))
     
   
   route.append(CLLocation(latitude:47.51366, longitude:-121.8464))
     
   
   route.append(CLLocation(latitude:47.51417, longitude:-121.84455))
     
   
   route.append(CLLocation(latitude:47.5142, longitude:-121.84441))
     
   
   route.append(CLLocation(latitude:47.51425, longitude:-121.84421))
     
   
   route.append(CLLocation(latitude:47.51433, longitude:-121.84388))
     
   
   route.append(CLLocation(latitude:47.5144, longitude:-121.84356))
     
   
   route.append(CLLocation(latitude:47.51446, longitude:-121.8432))
     
   
   route.append(CLLocation(latitude:47.51451, longitude:-121.84287))
     
   
   route.append(CLLocation(latitude:47.51455, longitude:-121.84257))
     
   
   route.append(CLLocation(latitude:47.51458, longitude:-121.84224))
     
   
   route.append(CLLocation(latitude:47.51461, longitude:-121.8419))
     
   
   route.append(CLLocation(latitude:47.51463, longitude:-121.84157))
     
   
   route.append(CLLocation(latitude:47.51464, longitude:-121.84123))
     
   
   route.append(CLLocation(latitude:47.51464, longitude:-121.84086))
     
   
   route.append(CLLocation(latitude:47.51464, longitude:-121.8405))
     
   
   route.append(CLLocation(latitude:47.51463, longitude:-121.84017))
     
   
   route.append(CLLocation(latitude:47.51461, longitude:-121.83984))
     
   
   route.append(CLLocation(latitude:47.51458, longitude:-121.83948))
     
   
   route.append(CLLocation(latitude:47.51455, longitude:-121.83915))
     
   
   route.append(CLLocation(latitude:47.5145, longitude:-121.83882))
     
   
   route.append(CLLocation(latitude:47.51444, longitude:-121.8384))
     
   
   route.append(CLLocation(latitude:47.51438, longitude:-121.83808))
     
   
   route.append(CLLocation(latitude:47.51432, longitude:-121.83782))
     
   
   route.append(CLLocation(latitude:47.51422, longitude:-121.83737))
     
   
   route.append(CLLocation(latitude:47.51413, longitude:-121.83703))
     
   
   route.append(CLLocation(latitude:47.51396, longitude:-121.83646))
     
   
   route.append(CLLocation(latitude:47.51385, longitude:-121.83615))
     
   
   route.append(CLLocation(latitude:47.51375, longitude:-121.83587))
     
   
   route.append(CLLocation(latitude:47.51365, longitude:-121.83562))
     
   
   route.append(CLLocation(latitude:47.5135, longitude:-121.83528))
     
   
   route.append(CLLocation(latitude:47.51334, longitude:-121.83495))
     
   
   route.append(CLLocation(latitude:47.51315, longitude:-121.83459))
     
   
   route.append(CLLocation(latitude:47.51294, longitude:-121.8342))
     
   
   route.append(CLLocation(latitude:47.51277, longitude:-121.83393))
     
   
   route.append(CLLocation(latitude:47.51261, longitude:-121.83369))
     
   
   route.append(CLLocation(latitude:47.51243, longitude:-121.83345))
     
   
   route.append(CLLocation(latitude:47.51225, longitude:-121.83322))
     
   
   route.append(CLLocation(latitude:47.51203, longitude:-121.83294))
     
   
   route.append(CLLocation(latitude:47.5109, longitude:-121.83168))
     
   
   route.append(CLLocation(latitude:47.50983, longitude:-121.83052))
     
   
   route.append(CLLocation(latitude:47.50858, longitude:-121.82913))
     
   
   route.append(CLLocation(latitude:47.50786, longitude:-121.82832))
     
   
   route.append(CLLocation(latitude:47.50737, longitude:-121.82776))
     
   
   route.append(CLLocation(latitude:47.50561, longitude:-121.82584))
     
   
   route.append(CLLocation(latitude:47.50407, longitude:-121.82407))
     
   
   route.append(CLLocation(latitude:47.5031, longitude:-121.82295))
     
   
   route.append(CLLocation(latitude:47.50258, longitude:-121.82235))
     
   
   route.append(CLLocation(latitude:47.5013, longitude:-121.82088))
     
   
   route.append(CLLocation(latitude:47.50067, longitude:-121.82014))
     
   
   route.append(CLLocation(latitude:47.49946, longitude:-121.81862))
     
   
   route.append(CLLocation(latitude:47.49927, longitude:-121.81839))
     
   
   route.append(CLLocation(latitude:47.49893, longitude:-121.81797))
     
   
   route.append(CLLocation(latitude:47.49879, longitude:-121.8178))
     
   
   route.append(CLLocation(latitude:47.49849, longitude:-121.81744))
     
   
   route.append(CLLocation(latitude:47.49809, longitude:-121.81697))
     
   
   route.append(CLLocation(latitude:47.49768, longitude:-121.81647))
     
   
   route.append(CLLocation(latitude:47.49599, longitude:-121.8145))
     
   
   route.append(CLLocation(latitude:47.49579, longitude:-121.81425))
     
   
   route.append(CLLocation(latitude:47.4956, longitude:-121.814))
     
   
   route.append(CLLocation(latitude:47.49541, longitude:-121.81371))
     
   
   route.append(CLLocation(latitude:47.49528, longitude:-121.8135))
     
   
   route.append(CLLocation(latitude:47.49509, longitude:-121.81319))
     
   
   route.append(CLLocation(latitude:47.49494, longitude:-121.81291))
     
   
   route.append(CLLocation(latitude:47.49482, longitude:-121.81267))
     
   
   route.append(CLLocation(latitude:47.49468, longitude:-121.81238))
     
   
   route.append(CLLocation(latitude:47.49455, longitude:-121.81207))
     
   
   route.append(CLLocation(latitude:47.49448, longitude:-121.81192))
     
   
   route.append(CLLocation(latitude:47.49443, longitude:-121.81179))
     
   
   route.append(CLLocation(latitude:47.49432, longitude:-121.81151))
     
   
   route.append(CLLocation(latitude:47.49422, longitude:-121.81122))
     
   
   route.append(CLLocation(latitude:47.49263, longitude:-121.80632))
     
   
   route.append(CLLocation(latitude:47.49259, longitude:-121.8062))
     
   
   route.append(CLLocation(latitude:47.49225, longitude:-121.80517))
     
   
   route.append(CLLocation(latitude:47.49192, longitude:-121.80415))
     
   
   route.append(CLLocation(latitude:47.4915, longitude:-121.80287))
     
   
   route.append(CLLocation(latitude:47.49122, longitude:-121.80203))
     
   
   route.append(CLLocation(latitude:47.49114, longitude:-121.80179))
     
   
   route.append(CLLocation(latitude:47.49107, longitude:-121.8016))
     
   
   route.append(CLLocation(latitude:47.49099, longitude:-121.8014))
     
   
   route.append(CLLocation(latitude:47.49093, longitude:-121.80126))
     
   
   route.append(CLLocation(latitude:47.49087, longitude:-121.80111))
     
   
   route.append(CLLocation(latitude:47.49083, longitude:-121.80099))
     
   
   route.append(CLLocation(latitude:47.49078, longitude:-121.80087))
     
   
   route.append(CLLocation(latitude:47.49075, longitude:-121.80078))
     
   
   route.append(CLLocation(latitude:47.49066, longitude:-121.80057))
     
   
   route.append(CLLocation(latitude:47.49054, longitude:-121.80031))
     
   
   route.append(CLLocation(latitude:47.49036, longitude:-121.79992))
     
   
   route.append(CLLocation(latitude:47.49019, longitude:-121.79959))
     
   
   route.append(CLLocation(latitude:47.49003, longitude:-121.7993))
     
   
   route.append(CLLocation(latitude:47.4898, longitude:-121.7989))
     
   
   route.append(CLLocation(latitude:47.4896, longitude:-121.79855))
     
   
   route.append(CLLocation(latitude:47.48935, longitude:-121.79817))
     
   
   route.append(CLLocation(latitude:47.48916, longitude:-121.79789))
     
   
   route.append(CLLocation(latitude:47.4889, longitude:-121.79753))
     
   
   route.append(CLLocation(latitude:47.48875, longitude:-121.79734))
     
   
   route.append(CLLocation(latitude:47.48863, longitude:-121.79718))
     
   
   route.append(CLLocation(latitude:47.48812, longitude:-121.79655))
     
   
   route.append(CLLocation(latitude:47.48805, longitude:-121.79647))
     
   
   route.append(CLLocation(latitude:47.48755, longitude:-121.79596))
     
   
   route.append(CLLocation(latitude:47.48675, longitude:-121.79517))
     
   
   route.append(CLLocation(latitude:47.48646, longitude:-121.79488))
     
   
   route.append(CLLocation(latitude:47.4864, longitude:-121.79482))
     
   
   route.append(CLLocation(latitude:47.48594, longitude:-121.79436))
     
   
   route.append(CLLocation(latitude:47.4853, longitude:-121.79372))
     
   
   route.append(CLLocation(latitude:47.48488, longitude:-121.7933))
     
   
   route.append(CLLocation(latitude:47.48263, longitude:-121.791))
     
   
   route.append(CLLocation(latitude:47.48037, longitude:-121.78874))
     
   
   route.append(CLLocation(latitude:47.4792, longitude:-121.78757))
     
   
   route.append(CLLocation(latitude:47.47756, longitude:-121.78598))
     
   
   route.append(CLLocation(latitude:47.4774, longitude:-121.78581))
     
   
   route.append(CLLocation(latitude:47.47647, longitude:-121.78485))
     
   
   route.append(CLLocation(latitude:47.47623, longitude:-121.78461))
     
   
   route.append(CLLocation(latitude:47.47608, longitude:-121.78446))
     
   
   route.append(CLLocation(latitude:47.47595, longitude:-121.78432))
     
   
   route.append(CLLocation(latitude:47.47585, longitude:-121.78421))
     
   
   route.append(CLLocation(latitude:47.47576, longitude:-121.78411))
     
   
   route.append(CLLocation(latitude:47.47565, longitude:-121.78398))
     
   
   route.append(CLLocation(latitude:47.47553, longitude:-121.78383))
     
   
   route.append(CLLocation(latitude:47.47539, longitude:-121.78364))
     
   
   route.append(CLLocation(latitude:47.47527, longitude:-121.78347))
     
   
   route.append(CLLocation(latitude:47.47508, longitude:-121.7832))
     
   
   route.append(CLLocation(latitude:47.47485, longitude:-121.78282))
     
   
   route.append(CLLocation(latitude:47.47467, longitude:-121.7825))
     
   
   route.append(CLLocation(latitude:47.47456, longitude:-121.78228))
     
   
   route.append(CLLocation(latitude:47.47438, longitude:-121.78193))
     
   
   route.append(CLLocation(latitude:47.47425, longitude:-121.78164))
     
   
   route.append(CLLocation(latitude:47.47409, longitude:-121.78125))
     
   
   route.append(CLLocation(latitude:47.47392, longitude:-121.7808))
     
   
   route.append(CLLocation(latitude:47.47383, longitude:-121.78049))
     
   
   route.append(CLLocation(latitude:47.47374, longitude:-121.7802))
     
   
   route.append(CLLocation(latitude:47.47366, longitude:-121.77992))
     
   
   route.append(CLLocation(latitude:47.47359, longitude:-121.77966))
     
   
   route.append(CLLocation(latitude:47.4735, longitude:-121.77929))
     
   
   route.append(CLLocation(latitude:47.47346, longitude:-121.77912))
     
   
   route.append(CLLocation(latitude:47.47343, longitude:-121.77892))
     
   
   route.append(CLLocation(latitude:47.47339, longitude:-121.7787))
     
   
   route.append(CLLocation(latitude:47.47336, longitude:-121.77852))
     
   
   route.append(CLLocation(latitude:47.47333, longitude:-121.77834))
     
   
   route.append(CLLocation(latitude:47.4733, longitude:-121.77812))
     
   
   route.append(CLLocation(latitude:47.47328, longitude:-121.77794))
     
   
   route.append(CLLocation(latitude:47.47324, longitude:-121.77758))
     
   
   route.append(CLLocation(latitude:47.47321, longitude:-121.77715))
     
   
   route.append(CLLocation(latitude:47.47319, longitude:-121.77688))
     
   
   route.append(CLLocation(latitude:47.47319, longitude:-121.77651))
     
   
   route.append(CLLocation(latitude:47.47318, longitude:-121.77474))
     
   
   route.append(CLLocation(latitude:47.47318, longitude:-121.77442))
     
   
   route.append(CLLocation(latitude:47.47319, longitude:-121.7741))
     
   
   route.append(CLLocation(latitude:47.4732, longitude:-121.76427))
     
   
   route.append(CLLocation(latitude:47.47323, longitude:-121.75856))
     
   
   route.append(CLLocation(latitude:47.47323, longitude:-121.75838))
     
   
   route.append(CLLocation(latitude:47.47324, longitude:-121.7527))
     
   
   route.append(CLLocation(latitude:47.47324, longitude:-121.75187))
     
   
   route.append(CLLocation(latitude:47.47324, longitude:-121.75136))
     
   
   route.append(CLLocation(latitude:47.47325, longitude:-121.74862))
     
   
   route.append(CLLocation(latitude:47.47326, longitude:-121.74453))
     
   
   route.append(CLLocation(latitude:47.47326, longitude:-121.74402))
     
   
   route.append(CLLocation(latitude:47.47325, longitude:-121.7437))
     
   
   route.append(CLLocation(latitude:47.47324, longitude:-121.74335))
     
   
   route.append(CLLocation(latitude:47.47323, longitude:-121.743))
     
   
   route.append(CLLocation(latitude:47.4732, longitude:-121.74268))
     
   
   route.append(CLLocation(latitude:47.47317, longitude:-121.74235))
     
   
   route.append(CLLocation(latitude:47.47312, longitude:-121.74199))
     
   
   route.append(CLLocation(latitude:47.47308, longitude:-121.74164))
     
   
   route.append(CLLocation(latitude:47.47302, longitude:-121.74126))
     
   
   route.append(CLLocation(latitude:47.47296, longitude:-121.74092))
     
   
   route.append(CLLocation(latitude:47.47288, longitude:-121.74054))
     
   
   route.append(CLLocation(latitude:47.47279, longitude:-121.74017))
     
   
   route.append(CLLocation(latitude:47.47273, longitude:-121.73992))
     
   
   route.append(CLLocation(latitude:47.47231, longitude:-121.73851))
     
   
   route.append(CLLocation(latitude:47.47165, longitude:-121.73626))
     
   
   route.append(CLLocation(latitude:47.47136, longitude:-121.7353))
     
   
   route.append(CLLocation(latitude:47.47118, longitude:-121.73466))
     
   
   route.append(CLLocation(latitude:47.47108, longitude:-121.73434))
     
   
   route.append(CLLocation(latitude:47.47082, longitude:-121.73345))
     
   
   route.append(CLLocation(latitude:47.47036, longitude:-121.73189))
     
   
   route.append(CLLocation(latitude:47.47004, longitude:-121.73088))
     
   
   route.append(CLLocation(latitude:47.46978, longitude:-121.73009))
     
   
   route.append(CLLocation(latitude:47.46955, longitude:-121.72944))
     
   
   route.append(CLLocation(latitude:47.46918, longitude:-121.72845))
     
   
   route.append(CLLocation(latitude:47.46885, longitude:-121.72757))
     
   
   route.append(CLLocation(latitude:47.46836, longitude:-121.7263))
     
   
   route.append(CLLocation(latitude:47.46684, longitude:-121.72227))
     
   
   route.append(CLLocation(latitude:47.46625, longitude:-121.72069))
     
   
   route.append(CLLocation(latitude:47.46571, longitude:-121.71928))
     
   
   route.append(CLLocation(latitude:47.46538, longitude:-121.71834))
     
   
   route.append(CLLocation(latitude:47.465, longitude:-121.7172))
     
   
   route.append(CLLocation(latitude:47.46481, longitude:-121.71658))
     
   
   route.append(CLLocation(latitude:47.46467, longitude:-121.71609))
     
   
   route.append(CLLocation(latitude:47.46454, longitude:-121.71563))
     
   
   route.append(CLLocation(latitude:47.46439, longitude:-121.71506))
     
   
   route.append(CLLocation(latitude:47.46426, longitude:-121.71454))
     
   
   route.append(CLLocation(latitude:47.46416, longitude:-121.71406))
     
   
   route.append(CLLocation(latitude:47.46395, longitude:-121.7131))
     
   
   route.append(CLLocation(latitude:47.46367, longitude:-121.7117))
     
   
   route.append(CLLocation(latitude:47.46355, longitude:-121.71105))
     
   
   route.append(CLLocation(latitude:47.46346, longitude:-121.71065))
     
   
   route.append(CLLocation(latitude:47.46327, longitude:-121.70977))
     
   
   route.append(CLLocation(latitude:47.46316, longitude:-121.70932))
     
   
   route.append(CLLocation(latitude:47.46306, longitude:-121.70897))
     
   
   route.append(CLLocation(latitude:47.46294, longitude:-121.70861))
     
   
   route.append(CLLocation(latitude:47.46279, longitude:-121.70819))
     
   
   route.append(CLLocation(latitude:47.46261, longitude:-121.70771))
     
   
   route.append(CLLocation(latitude:47.46236, longitude:-121.70717))
     
   
   route.append(CLLocation(latitude:47.46214, longitude:-121.70675))
     
   
   route.append(CLLocation(latitude:47.46184, longitude:-121.70622))
     
   
   route.append(CLLocation(latitude:47.46167, longitude:-121.70594))
     
   
   route.append(CLLocation(latitude:47.46148, longitude:-121.70568))
     
   
   route.append(CLLocation(latitude:47.46134, longitude:-121.70548))
     
   
   route.append(CLLocation(latitude:47.46113, longitude:-121.70522))
     
   
   route.append(CLLocation(latitude:47.46081, longitude:-121.70485))
     
   
   route.append(CLLocation(latitude:47.46049, longitude:-121.70451))
     
   
   route.append(CLLocation(latitude:47.46022, longitude:-121.70425))
     
   
   route.append(CLLocation(latitude:47.46004, longitude:-121.70411))
     
   
   route.append(CLLocation(latitude:47.45983, longitude:-121.70394))
     
   
   route.append(CLLocation(latitude:47.45966, longitude:-121.70382))
     
   
   route.append(CLLocation(latitude:47.45921, longitude:-121.70353))
     
   
   route.append(CLLocation(latitude:47.459, longitude:-121.70341))
     
   
   route.append(CLLocation(latitude:47.45862, longitude:-121.70322))
     
   
   route.append(CLLocation(latitude:47.45806, longitude:-121.70301))
     
   
   route.append(CLLocation(latitude:47.45785, longitude:-121.70295))
     
   
   route.append(CLLocation(latitude:47.45765, longitude:-121.7029))
     
   
   route.append(CLLocation(latitude:47.45704, longitude:-121.70278))
     
   
   route.append(CLLocation(latitude:47.45658, longitude:-121.7027))
     
   
   route.append(CLLocation(latitude:47.45617, longitude:-121.70262))
     
   
   route.append(CLLocation(latitude:47.45581, longitude:-121.70256))
     
   
   route.append(CLLocation(latitude:47.45543, longitude:-121.70248))
     
   
   route.append(CLLocation(latitude:47.4549, longitude:-121.70235))
     
   
   route.append(CLLocation(latitude:47.45468, longitude:-121.70229))
     
   
   route.append(CLLocation(latitude:47.45402, longitude:-121.70204))
     
   
   route.append(CLLocation(latitude:47.4535, longitude:-121.70182))
     
   
   route.append(CLLocation(latitude:47.45254, longitude:-121.70137))
     
   
   route.append(CLLocation(latitude:47.45155, longitude:-121.70096))
     
   
   route.append(CLLocation(latitude:47.45125, longitude:-121.70083))
     
   
   route.append(CLLocation(latitude:47.45088, longitude:-121.70064))
     
   
   route.append(CLLocation(latitude:47.45073, longitude:-121.70056))
     
   
   route.append(CLLocation(latitude:47.45033, longitude:-121.70035))
     
   
   route.append(CLLocation(latitude:47.44991, longitude:-121.70007))
     
   
   route.append(CLLocation(latitude:47.4497, longitude:-121.69993))
     
   
   route.append(CLLocation(latitude:47.44933, longitude:-121.69966))
     
   
   route.append(CLLocation(latitude:47.44913, longitude:-121.69949))
     
   
   route.append(CLLocation(latitude:47.44866, longitude:-121.69906))
     
   
   route.append(CLLocation(latitude:47.44848, longitude:-121.69888))
     
   
   route.append(CLLocation(latitude:47.44795, longitude:-121.69829))
     
   
   route.append(CLLocation(latitude:47.44768, longitude:-121.69797))
     
   
   route.append(CLLocation(latitude:47.44754, longitude:-121.69779))
     
   
   route.append(CLLocation(latitude:47.44731, longitude:-121.69747))
     
   
   route.append(CLLocation(latitude:47.44705, longitude:-121.69707))
     
   
   route.append(CLLocation(latitude:47.44668, longitude:-121.69648))
     
   
   route.append(CLLocation(latitude:47.44641, longitude:-121.696))
     
   
   route.append(CLLocation(latitude:47.44625, longitude:-121.69573))
     
   
   route.append(CLLocation(latitude:47.44604, longitude:-121.69527))
     
   
   route.append(CLLocation(latitude:47.44575, longitude:-121.6946))
     
   
   route.append(CLLocation(latitude:47.44567, longitude:-121.6944))
     
   
   route.append(CLLocation(latitude:47.44552, longitude:-121.69404))
     
   
   route.append(CLLocation(latitude:47.44509, longitude:-121.69301))
     
   
   route.append(CLLocation(latitude:47.44486, longitude:-121.69242))
     
   
   route.append(CLLocation(latitude:47.44467, longitude:-121.69192))
     
   
   route.append(CLLocation(latitude:47.44446, longitude:-121.69141))
     
   
   route.append(CLLocation(latitude:47.44415, longitude:-121.69067))
     
   
   route.append(CLLocation(latitude:47.44395, longitude:-121.6901))
     
   
   route.append(CLLocation(latitude:47.44381, longitude:-121.68963))
     
   
   route.append(CLLocation(latitude:47.44367, longitude:-121.68909))
     
   
   route.append(CLLocation(latitude:47.44355, longitude:-121.68854))
     
   
   route.append(CLLocation(latitude:47.4435, longitude:-121.68817))
     
   
   route.append(CLLocation(latitude:47.44346, longitude:-121.68784))
     
   
   route.append(CLLocation(latitude:47.44343, longitude:-121.68753))
     
   
   route.append(CLLocation(latitude:47.44339, longitude:-121.68701))
     
   
   route.append(CLLocation(latitude:47.44338, longitude:-121.68655))
     
   
   route.append(CLLocation(latitude:47.44338, longitude:-121.68623))
     
   
   route.append(CLLocation(latitude:47.44339, longitude:-121.6859))
     
   
   route.append(CLLocation(latitude:47.44342, longitude:-121.68537))
     
   
   route.append(CLLocation(latitude:47.44346, longitude:-121.68491))
     
   
   route.append(CLLocation(latitude:47.44349, longitude:-121.68455))
     
   
   route.append(CLLocation(latitude:47.44352, longitude:-121.68422))
     
   
   route.append(CLLocation(latitude:47.44355, longitude:-121.68386))
     
   
   route.append(CLLocation(latitude:47.44366, longitude:-121.68279))
     
   
   route.append(CLLocation(latitude:47.4438, longitude:-121.68137))
     
   
   route.append(CLLocation(latitude:47.44384, longitude:-121.68088))
     
   
   route.append(CLLocation(latitude:47.44385, longitude:-121.68053))
     
   
   route.append(CLLocation(latitude:47.44386, longitude:-121.68021))
     
   
   route.append(CLLocation(latitude:47.44386, longitude:-121.67989))
     
   
   route.append(CLLocation(latitude:47.44385, longitude:-121.67958))
     
   
   route.append(CLLocation(latitude:47.44384, longitude:-121.6794))
     
   
   route.append(CLLocation(latitude:47.44382, longitude:-121.6791))
     
   
   route.append(CLLocation(latitude:47.4438, longitude:-121.67876))
     
   
   route.append(CLLocation(latitude:47.44374, longitude:-121.67828))
     
   
   route.append(CLLocation(latitude:47.44371, longitude:-121.67805))
     
   
   route.append(CLLocation(latitude:47.44368, longitude:-121.67781))
     
   
   route.append(CLLocation(latitude:47.4436, longitude:-121.67732))
     
   
   route.append(CLLocation(latitude:47.44355, longitude:-121.67698))
     
   
   route.append(CLLocation(latitude:47.44334, longitude:-121.67558))
     
   
   route.append(CLLocation(latitude:47.44309, longitude:-121.67402))
     
   
   route.append(CLLocation(latitude:47.44299, longitude:-121.67343))
     
   
   route.append(CLLocation(latitude:47.44297, longitude:-121.67322))
     
   
   route.append(CLLocation(latitude:47.44294, longitude:-121.67304))
     
   
   route.append(CLLocation(latitude:47.44291, longitude:-121.67272))
     
   
   route.append(CLLocation(latitude:47.44288, longitude:-121.67227))
     
   
   route.append(CLLocation(latitude:47.44286, longitude:-121.67205))
     
   
   route.append(CLLocation(latitude:47.44285, longitude:-121.67165))
     
   
   route.append(CLLocation(latitude:47.44285, longitude:-121.67131))
     
   
   route.append(CLLocation(latitude:47.44286, longitude:-121.6709))
     
   
   route.append(CLLocation(latitude:47.44287, longitude:-121.67048))
     
   
   route.append(CLLocation(latitude:47.44289, longitude:-121.67015))
     
   
   route.append(CLLocation(latitude:47.44291, longitude:-121.66981))
     
   
   route.append(CLLocation(latitude:47.44294, longitude:-121.66934))
     
   
   route.append(CLLocation(latitude:47.44296, longitude:-121.66903))
     
   
   route.append(CLLocation(latitude:47.44299, longitude:-121.6687))
     
   
   route.append(CLLocation(latitude:47.44301, longitude:-121.66837))
     
   
   route.append(CLLocation(latitude:47.44304, longitude:-121.66773))
     
   
   route.append(CLLocation(latitude:47.44306, longitude:-121.66723))
     
   
   route.append(CLLocation(latitude:47.44308, longitude:-121.66674))
     
   
   route.append(CLLocation(latitude:47.44309, longitude:-121.66642))
     
   
   route.append(CLLocation(latitude:47.4431, longitude:-121.66609))
     
   
   route.append(CLLocation(latitude:47.44311, longitude:-121.66577))
     
   
   route.append(CLLocation(latitude:47.4431, longitude:-121.66544))
     
   
   route.append(CLLocation(latitude:47.4431, longitude:-121.66511))
     
   
   route.append(CLLocation(latitude:47.44309, longitude:-121.66463))
     
   
   route.append(CLLocation(latitude:47.44306, longitude:-121.66416))
     
   
   route.append(CLLocation(latitude:47.44304, longitude:-121.66383))
     
   
   route.append(CLLocation(latitude:47.443, longitude:-121.66336))
     
   
   route.append(CLLocation(latitude:47.44297, longitude:-121.66303))
     
   
   route.append(CLLocation(latitude:47.44289, longitude:-121.66242))
     
   
   route.append(CLLocation(latitude:47.44284, longitude:-121.66208))
     
   
   route.append(CLLocation(latitude:47.44279, longitude:-121.66178))
     
   
   route.append(CLLocation(latitude:47.4427, longitude:-121.66131))
     
   
   route.append(CLLocation(latitude:47.4426, longitude:-121.66084))
     
   
   route.append(CLLocation(latitude:47.44254, longitude:-121.66054))
     
   
   route.append(CLLocation(latitude:47.44246, longitude:-121.66022))
     
   
   route.append(CLLocation(latitude:47.44234, longitude:-121.65977))
     
   
   route.append(CLLocation(latitude:47.44219, longitude:-121.65919))
     
   
   route.append(CLLocation(latitude:47.44209, longitude:-121.65888))
     
   
   route.append(CLLocation(latitude:47.44195, longitude:-121.65844))
     
   
   route.append(CLLocation(latitude:47.44185, longitude:-121.65816))
     
   
   route.append(CLLocation(latitude:47.44169, longitude:-121.65773))
     
   
   route.append(CLLocation(latitude:47.44162, longitude:-121.65756))
     
   
   route.append(CLLocation(latitude:47.44152, longitude:-121.6573))
     
   
   route.append(CLLocation(latitude:47.44134, longitude:-121.65689))
     
   
   route.append(CLLocation(latitude:47.44121, longitude:-121.65662))
     
   
   route.append(CLLocation(latitude:47.44096, longitude:-121.65611))
     
   
   route.append(CLLocation(latitude:47.44026, longitude:-121.65464))
     
   
   route.append(CLLocation(latitude:47.43975, longitude:-121.65356))
     
   
   route.append(CLLocation(latitude:47.43944, longitude:-121.65291))
     
   
   route.append(CLLocation(latitude:47.43899, longitude:-121.65197))
     
   
   route.append(CLLocation(latitude:47.43867, longitude:-121.6513))
     
   
   route.append(CLLocation(latitude:47.43841, longitude:-121.65077))
     
   
   route.append(CLLocation(latitude:47.43798, longitude:-121.64986))
     
   
   route.append(CLLocation(latitude:47.4377, longitude:-121.64928))
     
   
   route.append(CLLocation(latitude:47.43741, longitude:-121.64867))
     
   
   route.append(CLLocation(latitude:47.43726, longitude:-121.64834))
     
   
   route.append(CLLocation(latitude:47.43696, longitude:-121.64771))
     
   
   route.append(CLLocation(latitude:47.43673, longitude:-121.64722))
     
   
   route.append(CLLocation(latitude:47.43608, longitude:-121.64583))
     
   
   route.append(CLLocation(latitude:47.43519, longitude:-121.64401))
     
   
   route.append(CLLocation(latitude:47.43486, longitude:-121.64334))
     
   
   route.append(CLLocation(latitude:47.43454, longitude:-121.64273))
     
   
   route.append(CLLocation(latitude:47.4342, longitude:-121.6421))
     
   
   route.append(CLLocation(latitude:47.43384, longitude:-121.64146))
     
   
   route.append(CLLocation(latitude:47.43358, longitude:-121.64101))
     
   
   route.append(CLLocation(latitude:47.43331, longitude:-121.64055))
     
   
   route.append(CLLocation(latitude:47.43308, longitude:-121.64018))
     
   
   route.append(CLLocation(latitude:47.4327, longitude:-121.63955))
     
   
   route.append(CLLocation(latitude:47.43236, longitude:-121.63901))
     
   
   route.append(CLLocation(latitude:47.43176, longitude:-121.63803))
     
   
   route.append(CLLocation(latitude:47.43131, longitude:-121.63729))
     
   
   route.append(CLLocation(latitude:47.43109, longitude:-121.63688))
     
   
   route.append(CLLocation(latitude:47.43086, longitude:-121.63643))
     
   
   route.append(CLLocation(latitude:47.43076, longitude:-121.63621))
     
   
   route.append(CLLocation(latitude:47.43056, longitude:-121.63573))
     
   
   route.append(CLLocation(latitude:47.43043, longitude:-121.63544))
     
   
   route.append(CLLocation(latitude:47.43025, longitude:-121.63493))
     
   
   route.append(CLLocation(latitude:47.43008, longitude:-121.63446))
     
   
   route.append(CLLocation(latitude:47.43007, longitude:-121.63443))
     
   
   route.append(CLLocation(latitude:47.42992, longitude:-121.63392))
     
   
   route.append(CLLocation(latitude:47.42984, longitude:-121.63366))
     
   
   route.append(CLLocation(latitude:47.42969, longitude:-121.63304))
     
   
   route.append(CLLocation(latitude:47.42956, longitude:-121.63242))
     
   
   route.append(CLLocation(latitude:47.42946, longitude:-121.63192))
     
   
   route.append(CLLocation(latitude:47.42938, longitude:-121.63133))
     
   
   route.append(CLLocation(latitude:47.42926, longitude:-121.6303))
     
   
   route.append(CLLocation(latitude:47.4291, longitude:-121.62901))
     
   
   route.append(CLLocation(latitude:47.429, longitude:-121.62802))
     
   
   route.append(CLLocation(latitude:47.42892, longitude:-121.6271))
     
   
   route.append(CLLocation(latitude:47.42871, longitude:-121.62519))
     
   
   route.append(CLLocation(latitude:47.42864, longitude:-121.62461))
     
   
   route.append(CLLocation(latitude:47.42849, longitude:-121.62317))
     
   
   route.append(CLLocation(latitude:47.42845, longitude:-121.62275))
     
   
   route.append(CLLocation(latitude:47.42844, longitude:-121.62249))
     
   
   route.append(CLLocation(latitude:47.42843, longitude:-121.62194))
     
   
   route.append(CLLocation(latitude:47.42843, longitude:-121.62149))
     
   
   route.append(CLLocation(latitude:47.42844, longitude:-121.62123))
     
   
   route.append(CLLocation(latitude:47.42848, longitude:-121.62077))
     
   
   route.append(CLLocation(latitude:47.42853, longitude:-121.62036))
     
   
   route.append(CLLocation(latitude:47.42891, longitude:-121.61722))
     
   
   route.append(CLLocation(latitude:47.42893, longitude:-121.61672))
     
   
   route.append(CLLocation(latitude:47.42895, longitude:-121.61642))
     
   
   route.append(CLLocation(latitude:47.42895, longitude:-121.61593))
     
   
   route.append(CLLocation(latitude:47.42894, longitude:-121.61559))
     
   
   route.append(CLLocation(latitude:47.42892, longitude:-121.61534))
     
   
   route.append(CLLocation(latitude:47.4289, longitude:-121.61507))
     
   
   route.append(CLLocation(latitude:47.42888, longitude:-121.61486))
     
   
   route.append(CLLocation(latitude:47.42882, longitude:-121.61441))
     
   
   route.append(CLLocation(latitude:47.42878, longitude:-121.61416))
     
   
   route.append(CLLocation(latitude:47.42869, longitude:-121.61371))
     
   
   route.append(CLLocation(latitude:47.42869, longitude:-121.61369))
     
   
   route.append(CLLocation(latitude:47.42857, longitude:-121.61322))
     
   
   route.append(CLLocation(latitude:47.42847, longitude:-121.6129))
     
   
   route.append(CLLocation(latitude:47.42834, longitude:-121.6125))
     
   
   route.append(CLLocation(latitude:47.42761, longitude:-121.61032))
     
   
   route.append(CLLocation(latitude:47.42692, longitude:-121.60822))
     
   
   route.append(CLLocation(latitude:47.42629, longitude:-121.60628))
     
   
   route.append(CLLocation(latitude:47.42577, longitude:-121.6047))
     
   
   route.append(CLLocation(latitude:47.42564, longitude:-121.60429))
     
   
   route.append(CLLocation(latitude:47.42557, longitude:-121.60399))
     
   
   route.append(CLLocation(latitude:47.4255, longitude:-121.60369))
     
   
   route.append(CLLocation(latitude:47.42542, longitude:-121.60331))
     
   
   route.append(CLLocation(latitude:47.42533, longitude:-121.60287))
     
   
   route.append(CLLocation(latitude:47.42528, longitude:-121.60251))
     
   
   route.append(CLLocation(latitude:47.42521, longitude:-121.60192))
     
   
   route.append(CLLocation(latitude:47.42514, longitude:-121.60134))
     
   
   route.append(CLLocation(latitude:47.42509, longitude:-121.60089))
     
   
   route.append(CLLocation(latitude:47.42504, longitude:-121.60041))
     
   
   route.append(CLLocation(latitude:47.42499, longitude:-121.59992))
     
   
   route.append(CLLocation(latitude:47.4249, longitude:-121.59924))
     
   
   route.append(CLLocation(latitude:47.42486, longitude:-121.59902))
     
   
   route.append(CLLocation(latitude:47.42479, longitude:-121.5987))
     
   
   route.append(CLLocation(latitude:47.42473, longitude:-121.59843))
     
   
   route.append(CLLocation(latitude:47.42466, longitude:-121.59816))
     
   
   route.append(CLLocation(latitude:47.42456, longitude:-121.59783))
     
   
   route.append(CLLocation(latitude:47.42446, longitude:-121.59753))
     
   
   route.append(CLLocation(latitude:47.42435, longitude:-121.59721))
     
   
   route.append(CLLocation(latitude:47.42424, longitude:-121.59695))
     
   
   route.append(CLLocation(latitude:47.42405, longitude:-121.59653))
     
   
   route.append(CLLocation(latitude:47.42386, longitude:-121.59617))
     
   
   route.append(CLLocation(latitude:47.42362, longitude:-121.59576))
     
   
   route.append(CLLocation(latitude:47.4235, longitude:-121.59557))
     
   
   route.append(CLLocation(latitude:47.42321, longitude:-121.59517))
     
   
   route.append(CLLocation(latitude:47.42299, longitude:-121.5949))
     
   
   route.append(CLLocation(latitude:47.42198, longitude:-121.59374))
     
   
   route.append(CLLocation(latitude:47.42166, longitude:-121.59337))
     
   
   route.append(CLLocation(latitude:47.42085, longitude:-121.59242))
     
   
   route.append(CLLocation(latitude:47.4206, longitude:-121.59207))
     
   
   route.append(CLLocation(latitude:47.42044, longitude:-121.59183))
     
   
   route.append(CLLocation(latitude:47.42027, longitude:-121.59158))
     
   
   route.append(CLLocation(latitude:47.41998, longitude:-121.5911))
     
   
   route.append(CLLocation(latitude:47.41944, longitude:-121.59013))
     
   
   route.append(CLLocation(latitude:47.41923, longitude:-121.58975))
     
   
   route.append(CLLocation(latitude:47.41878, longitude:-121.58894))
     
   
   route.append(CLLocation(latitude:47.41841, longitude:-121.5883))
     
   
   route.append(CLLocation(latitude:47.41814, longitude:-121.58789))
     
   
   route.append(CLLocation(latitude:47.41769, longitude:-121.58733))
     
   
   route.append(CLLocation(latitude:47.41758, longitude:-121.58721))
     
   
   route.append(CLLocation(latitude:47.41733, longitude:-121.58696))
     
   
   route.append(CLLocation(latitude:47.41714, longitude:-121.58678))
     
   
   route.append(CLLocation(latitude:47.41696, longitude:-121.58665))
     
   
   route.append(CLLocation(latitude:47.41657, longitude:-121.58638))
     
   
   route.append(CLLocation(latitude:47.41602, longitude:-121.58604))
     
   
   route.append(CLLocation(latitude:47.41544, longitude:-121.58568))
     
   
   route.append(CLLocation(latitude:47.41478, longitude:-121.58527))
     
   
   route.append(CLLocation(latitude:47.41432, longitude:-121.58499))
     
   
   route.append(CLLocation(latitude:47.41408, longitude:-121.58481))
     
   
   route.append(CLLocation(latitude:47.41377, longitude:-121.58455))
     
   
   route.append(CLLocation(latitude:47.4135, longitude:-121.58429))
     
   
   route.append(CLLocation(latitude:47.41312, longitude:-121.58387))
     
   
   route.append(CLLocation(latitude:47.41288, longitude:-121.58356))
     
   
   route.append(CLLocation(latitude:47.41266, longitude:-121.58323))
     
   
   route.append(CLLocation(latitude:47.41243, longitude:-121.58287))
     
   
   route.append(CLLocation(latitude:47.41221, longitude:-121.58247))
     
   
   route.append(CLLocation(latitude:47.41199, longitude:-121.58203))
     
   
   route.append(CLLocation(latitude:47.41127, longitude:-121.58046))
     
   
   route.append(CLLocation(latitude:47.41096, longitude:-121.57979))
     
   
   route.append(CLLocation(latitude:47.41048, longitude:-121.57875))
     
   
   route.append(CLLocation(latitude:47.40983, longitude:-121.57732))
     
   
   route.append(CLLocation(latitude:47.40938, longitude:-121.57634))
     
   
   route.append(CLLocation(latitude:47.40921, longitude:-121.57602))
     
   
   route.append(CLLocation(latitude:47.40907, longitude:-121.57578))
     
   
   route.append(CLLocation(latitude:47.40895, longitude:-121.57557))
     
   
   route.append(CLLocation(latitude:47.40882, longitude:-121.57538))
     
   
   route.append(CLLocation(latitude:47.40853, longitude:-121.57498))
     
   
   route.append(CLLocation(latitude:47.40833, longitude:-121.57474))
     
   
   route.append(CLLocation(latitude:47.40811, longitude:-121.57449))
     
   
   route.append(CLLocation(latitude:47.40777, longitude:-121.5741))
     
   
   route.append(CLLocation(latitude:47.40746, longitude:-121.57374))
     
   
   route.append(CLLocation(latitude:47.40725, longitude:-121.5735))
     
   
   route.append(CLLocation(latitude:47.40681, longitude:-121.57299))
     
   
   route.append(CLLocation(latitude:47.40647, longitude:-121.57255))
     
   
   route.append(CLLocation(latitude:47.40634, longitude:-121.57235))
     
   
   route.append(CLLocation(latitude:47.40623, longitude:-121.57217))
     
   
   route.append(CLLocation(latitude:47.40618, longitude:-121.57209))
     
   
   route.append(CLLocation(latitude:47.40592, longitude:-121.57162))
     
   
   route.append(CLLocation(latitude:47.4058, longitude:-121.57138))
     
   
   route.append(CLLocation(latitude:47.40567, longitude:-121.57108))
     
   
   route.append(CLLocation(latitude:47.40557, longitude:-121.57084))
     
   
   route.append(CLLocation(latitude:47.40542, longitude:-121.57046))
     
   
   route.append(CLLocation(latitude:47.40532, longitude:-121.57018))
     
   
   route.append(CLLocation(latitude:47.40522, longitude:-121.56988))
     
   
   route.append(CLLocation(latitude:47.40512, longitude:-121.5695))
     
   
   route.append(CLLocation(latitude:47.40503, longitude:-121.56909))
     
   
   route.append(CLLocation(latitude:47.40486, longitude:-121.56825))
     
   
   route.append(CLLocation(latitude:47.40477, longitude:-121.56773))
     
   
   route.append(CLLocation(latitude:47.40466, longitude:-121.56718))
     
   
   route.append(CLLocation(latitude:47.40458, longitude:-121.56674))
     
   
   route.append(CLLocation(latitude:47.40449, longitude:-121.56629))
     
   
   route.append(CLLocation(latitude:47.40439, longitude:-121.56574))
     
   
   route.append(CLLocation(latitude:47.4043, longitude:-121.56527))
     
   
   route.append(CLLocation(latitude:47.4042, longitude:-121.56472))
     
   
   route.append(CLLocation(latitude:47.40407, longitude:-121.56401))
     
   
   route.append(CLLocation(latitude:47.40395, longitude:-121.56335))
     
   
   route.append(CLLocation(latitude:47.40387, longitude:-121.56292))
     
   
   route.append(CLLocation(latitude:47.40375, longitude:-121.56231))
     
   
   route.append(CLLocation(latitude:47.40357, longitude:-121.56142))
     
   
   route.append(CLLocation(latitude:47.40345, longitude:-121.56091))
     
   
   route.append(CLLocation(latitude:47.40339, longitude:-121.56066))
     
   
   route.append(CLLocation(latitude:47.40326, longitude:-121.56023))
     
   
   route.append(CLLocation(latitude:47.40309, longitude:-121.5597))
     
   
   route.append(CLLocation(latitude:47.40296, longitude:-121.55933))
     
   
   route.append(CLLocation(latitude:47.40282, longitude:-121.55899))
     
   
   route.append(CLLocation(latitude:47.4027, longitude:-121.5587))
     
   
   route.append(CLLocation(latitude:47.4024, longitude:-121.55804))
     
   
   route.append(CLLocation(latitude:47.4021, longitude:-121.55747))
     
   
   route.append(CLLocation(latitude:47.40104, longitude:-121.55561))
     
   
   route.append(CLLocation(latitude:47.40007, longitude:-121.55391))
     
   
   route.append(CLLocation(latitude:47.39935, longitude:-121.55263))
     
   
   route.append(CLLocation(latitude:47.39879, longitude:-121.55162))
     
   
   route.append(CLLocation(latitude:47.39867, longitude:-121.55139))
     
   
   route.append(CLLocation(latitude:47.39841, longitude:-121.55082))
     
   
   route.append(CLLocation(latitude:47.39817, longitude:-121.55014))
     
   
   route.append(CLLocation(latitude:47.39805, longitude:-121.54974))
     
   
   route.append(CLLocation(latitude:47.39793, longitude:-121.54931))
     
   
   route.append(CLLocation(latitude:47.39784, longitude:-121.5489))
     
   
   route.append(CLLocation(latitude:47.39778, longitude:-121.54853))
     
   
   route.append(CLLocation(latitude:47.39771, longitude:-121.54813))
     
   
   route.append(CLLocation(latitude:47.39766, longitude:-121.54769))
     
   
   route.append(CLLocation(latitude:47.39762, longitude:-121.54713))
     
   
   route.append(CLLocation(latitude:47.39759, longitude:-121.54672))
     
   
   route.append(CLLocation(latitude:47.39751, longitude:-121.54543))
     
   
   route.append(CLLocation(latitude:47.39745, longitude:-121.54457))
     
   
   route.append(CLLocation(latitude:47.39738, longitude:-121.54384))
     
   
   route.append(CLLocation(latitude:47.39734, longitude:-121.54341))
     
   
   route.append(CLLocation(latitude:47.39729, longitude:-121.54302))
     
   
   route.append(CLLocation(latitude:47.39709, longitude:-121.54158))
     
   
   route.append(CLLocation(latitude:47.39678, longitude:-121.53942))
     
   
   route.append(CLLocation(latitude:47.39656, longitude:-121.5379))
     
   
   route.append(CLLocation(latitude:47.39641, longitude:-121.53685))
     
   
   route.append(CLLocation(latitude:47.39633, longitude:-121.53625))
     
   
   route.append(CLLocation(latitude:47.39614, longitude:-121.53492))
     
   
   route.append(CLLocation(latitude:47.39598, longitude:-121.53379))
     
   
   route.append(CLLocation(latitude:47.39586, longitude:-121.53297))
     
   
   route.append(CLLocation(latitude:47.39578, longitude:-121.53238))
     
   
   route.append(CLLocation(latitude:47.39561, longitude:-121.53115))
     
   
   route.append(CLLocation(latitude:47.39536, longitude:-121.52946))
     
   
   route.append(CLLocation(latitude:47.39518, longitude:-121.52825))
     
   
   route.append(CLLocation(latitude:47.39509, longitude:-121.52762))
     
   
   route.append(CLLocation(latitude:47.39501, longitude:-121.52677))
     
   
   route.append(CLLocation(latitude:47.39497, longitude:-121.52608))
     
   
   route.append(CLLocation(latitude:47.39499, longitude:-121.52523))
     
   
   route.append(CLLocation(latitude:47.39503, longitude:-121.52353))
     
   
   route.append(CLLocation(latitude:47.39506, longitude:-121.52194))
     
   
   route.append(CLLocation(latitude:47.39508, longitude:-121.52046))
     
   
   route.append(CLLocation(latitude:47.3951, longitude:-121.51906))
     
   
   route.append(CLLocation(latitude:47.39513, longitude:-121.51843))
     
   
   route.append(CLLocation(latitude:47.39517, longitude:-121.51783))
     
   
   route.append(CLLocation(latitude:47.39521, longitude:-121.51738))
     
   
   route.append(CLLocation(latitude:47.39524, longitude:-121.51707))
     
   
   route.append(CLLocation(latitude:47.39528, longitude:-121.51682))
     
   
   route.append(CLLocation(latitude:47.39533, longitude:-121.51643))
     
   
   route.append(CLLocation(latitude:47.39544, longitude:-121.51568))
     
   
   route.append(CLLocation(latitude:47.39567, longitude:-121.51427))
     
   
   route.append(CLLocation(latitude:47.39583, longitude:-121.51324))
     
   
   route.append(CLLocation(latitude:47.39587, longitude:-121.51302))
     
   
   route.append(CLLocation(latitude:47.39593, longitude:-121.51242))
     
   
   route.append(CLLocation(latitude:47.39596, longitude:-121.5121))
     
   
   route.append(CLLocation(latitude:47.39598, longitude:-121.51171))
     
   
   route.append(CLLocation(latitude:47.39599, longitude:-121.51126))
     
   
   route.append(CLLocation(latitude:47.396, longitude:-121.5109))
     
   
   route.append(CLLocation(latitude:47.39601, longitude:-121.51058))
     
   
   route.append(CLLocation(latitude:47.39603, longitude:-121.50946))
     
   
   route.append(CLLocation(latitude:47.39609, longitude:-121.50684))
     
   
   route.append(CLLocation(latitude:47.39609, longitude:-121.50655))
     
   
   route.append(CLLocation(latitude:47.39613, longitude:-121.50528))
     
   
   route.append(CLLocation(latitude:47.39615, longitude:-121.50476))
     
   
   route.append(CLLocation(latitude:47.39622, longitude:-121.50346))
     
   
   route.append(CLLocation(latitude:47.39628, longitude:-121.50223))
     
   
   route.append(CLLocation(latitude:47.39634, longitude:-121.50119))
     
   
   route.append(CLLocation(latitude:47.3964, longitude:-121.50001))
     
   
   route.append(CLLocation(latitude:47.39643, longitude:-121.4995))
     
   
   route.append(CLLocation(latitude:47.39657, longitude:-121.49677))
     
   
   route.append(CLLocation(latitude:47.39675, longitude:-121.49327))
     
   
   route.append(CLLocation(latitude:47.39677, longitude:-121.49296))
     
   
   route.append(CLLocation(latitude:47.3968, longitude:-121.49244))
     
   
   route.append(CLLocation(latitude:47.39683, longitude:-121.49178))
     
   
   route.append(CLLocation(latitude:47.39686, longitude:-121.49131))
     
   
   route.append(CLLocation(latitude:47.39687, longitude:-121.49085))
     
   
   route.append(CLLocation(latitude:47.39687, longitude:-121.4906))
     
   
   route.append(CLLocation(latitude:47.39688, longitude:-121.49033))
     
   
   route.append(CLLocation(latitude:47.39689, longitude:-121.48969))
     
   
   route.append(CLLocation(latitude:47.39688, longitude:-121.48905))
     
   
   route.append(CLLocation(latitude:47.39687, longitude:-121.48857))
     
   
   route.append(CLLocation(latitude:47.39686, longitude:-121.48819))
     
   
   route.append(CLLocation(latitude:47.39685, longitude:-121.4879))
     
   
   route.append(CLLocation(latitude:47.39683, longitude:-121.48743))
     
   
   route.append(CLLocation(latitude:47.39681, longitude:-121.48708))
     
   
   route.append(CLLocation(latitude:47.39679, longitude:-121.48677))
     
   
   route.append(CLLocation(latitude:47.39676, longitude:-121.4864))
     
   
   route.append(CLLocation(latitude:47.39673, longitude:-121.48608))
     
   
   route.append(CLLocation(latitude:47.39668, longitude:-121.48559))
     
   
   route.append(CLLocation(latitude:47.39662, longitude:-121.48505))
     
   
   route.append(CLLocation(latitude:47.39657, longitude:-121.48464))
     
   
   route.append(CLLocation(latitude:47.39651, longitude:-121.48418))
     
   
   route.append(CLLocation(latitude:47.39648, longitude:-121.48398))
     
   
   route.append(CLLocation(latitude:47.39643, longitude:-121.48362))
     
   
   route.append(CLLocation(latitude:47.39638, longitude:-121.48332))
     
   
   route.append(CLLocation(latitude:47.39633, longitude:-121.48299))
     
   
   route.append(CLLocation(latitude:47.39619, longitude:-121.48223))
     
   
   route.append(CLLocation(latitude:47.3961, longitude:-121.48176))
     
   
   route.append(CLLocation(latitude:47.396, longitude:-121.4813))
     
   
   route.append(CLLocation(latitude:47.39588, longitude:-121.48074))
     
   
   route.append(CLLocation(latitude:47.39581, longitude:-121.48042))
     
   
   route.append(CLLocation(latitude:47.39579, longitude:-121.48036))
     
   
   route.append(CLLocation(latitude:47.39572, longitude:-121.48009))
     
   
   route.append(CLLocation(latitude:47.39565, longitude:-121.4798))
     
   
   route.append(CLLocation(latitude:47.39549, longitude:-121.4792))
     
   
   route.append(CLLocation(latitude:47.39532, longitude:-121.47861))
     
   
   route.append(CLLocation(latitude:47.39513, longitude:-121.47798))
     
   
   route.append(CLLocation(latitude:47.39491, longitude:-121.47731))
     
   
   route.append(CLLocation(latitude:47.39457, longitude:-121.47639))
     
   
   route.append(CLLocation(latitude:47.39402, longitude:-121.47497))
     
   
   route.append(CLLocation(latitude:47.3939, longitude:-121.47465))
     
   
   route.append(CLLocation(latitude:47.39345, longitude:-121.47347))
     
   
   route.append(CLLocation(latitude:47.39331, longitude:-121.47307))
     
   
   route.append(CLLocation(latitude:47.39323, longitude:-121.47281))
     
   
   route.append(CLLocation(latitude:47.39318, longitude:-121.47263))
     
   
   route.append(CLLocation(latitude:47.39314, longitude:-121.47248))
     
   
   route.append(CLLocation(latitude:47.39311, longitude:-121.47236))
     
   
   route.append(CLLocation(latitude:47.39303, longitude:-121.47206))
     
   
   route.append(CLLocation(latitude:47.39301, longitude:-121.47192))
     
   
   route.append(CLLocation(latitude:47.39294, longitude:-121.47158))
     
   
   route.append(CLLocation(latitude:47.39292, longitude:-121.47143))
     
   
   route.append(CLLocation(latitude:47.39289, longitude:-121.47126))
     
   
   route.append(CLLocation(latitude:47.39286, longitude:-121.47103))
     
   
   route.append(CLLocation(latitude:47.39284, longitude:-121.47081))
     
   
   route.append(CLLocation(latitude:47.39283, longitude:-121.47072))
     
   
   route.append(CLLocation(latitude:47.39282, longitude:-121.47063))
     
   
   route.append(CLLocation(latitude:47.3928, longitude:-121.4704))
     
   
   route.append(CLLocation(latitude:47.39278, longitude:-121.46998))
     
   
   route.append(CLLocation(latitude:47.39277, longitude:-121.46954))
     
   
   route.append(CLLocation(latitude:47.39277, longitude:-121.46937))
     
   
   route.append(CLLocation(latitude:47.39278, longitude:-121.46918))
     
   
   route.append(CLLocation(latitude:47.39278, longitude:-121.46908))
     
   
   route.append(CLLocation(latitude:47.39279, longitude:-121.46897))
     
   
   route.append(CLLocation(latitude:47.3928, longitude:-121.46875))
     
   
   route.append(CLLocation(latitude:47.39282, longitude:-121.46856))
     
   
   route.append(CLLocation(latitude:47.39283, longitude:-121.46839))
     
   
   route.append(CLLocation(latitude:47.39286, longitude:-121.46817))
     
   
   route.append(CLLocation(latitude:47.39286, longitude:-121.4681))
     
   
   route.append(CLLocation(latitude:47.3929, longitude:-121.46786))
     
   
   route.append(CLLocation(latitude:47.39294, longitude:-121.46758))
     
   
   route.append(CLLocation(latitude:47.39297, longitude:-121.46743))
     
   
   route.append(CLLocation(latitude:47.39299, longitude:-121.46733))
     
   
   route.append(CLLocation(latitude:47.39306, longitude:-121.46702))
     
   
   route.append(CLLocation(latitude:47.39313, longitude:-121.46672))
     
   
   route.append(CLLocation(latitude:47.39319, longitude:-121.46651))
     
   
   route.append(CLLocation(latitude:47.39331, longitude:-121.4661))
     
   
   route.append(CLLocation(latitude:47.39493, longitude:-121.46079))
     
   
   route.append(CLLocation(latitude:47.39512, longitude:-121.46016))
     
   
   route.append(CLLocation(latitude:47.39525, longitude:-121.45972))
     
   
   route.append(CLLocation(latitude:47.39534, longitude:-121.45943))
     
   
   route.append(CLLocation(latitude:47.39544, longitude:-121.45913))
     
   
   route.append(CLLocation(latitude:47.39552, longitude:-121.45884))
     
   
   route.append(CLLocation(latitude:47.39564, longitude:-121.45843))
     
   
   route.append(CLLocation(latitude:47.39576, longitude:-121.45798))
     
   
   route.append(CLLocation(latitude:47.3959, longitude:-121.45737))
     
   
   route.append(CLLocation(latitude:47.39596, longitude:-121.45702))
     
   
   route.append(CLLocation(latitude:47.39601, longitude:-121.4567))
     
   
   route.append(CLLocation(latitude:47.39608, longitude:-121.45626))
     
   
   route.append(CLLocation(latitude:47.39615, longitude:-121.45578))
     
   
   route.append(CLLocation(latitude:47.39623, longitude:-121.45528))
     
   
   route.append(CLLocation(latitude:47.39635, longitude:-121.45451))
     
   
   route.append(CLLocation(latitude:47.39646, longitude:-121.45376))
     
   
   route.append(CLLocation(latitude:47.39658, longitude:-121.45297))
     
   
   route.append(CLLocation(latitude:47.39668, longitude:-121.45234))
     
   
   route.append(CLLocation(latitude:47.3968, longitude:-121.45157))
     
   
   route.append(CLLocation(latitude:47.39693, longitude:-121.45074))
     
   
   route.append(CLLocation(latitude:47.39696, longitude:-121.45051))
     
   
   route.append(CLLocation(latitude:47.39701, longitude:-121.45023))
     
   
   route.append(CLLocation(latitude:47.39705, longitude:-121.45001))
     
   
   route.append(CLLocation(latitude:47.3971, longitude:-121.44979))
     
   
   route.append(CLLocation(latitude:47.39716, longitude:-121.4495))
     
   
   route.append(CLLocation(latitude:47.39728, longitude:-121.44909))
     
   
   route.append(CLLocation(latitude:47.39738, longitude:-121.44877))
     
   
   route.append(CLLocation(latitude:47.39748, longitude:-121.44849))
     
   
   route.append(CLLocation(latitude:47.39759, longitude:-121.44821))
     
   
   route.append(CLLocation(latitude:47.39765, longitude:-121.44807))
     
   
   route.append(CLLocation(latitude:47.39773, longitude:-121.44789))
     
   
   route.append(CLLocation(latitude:47.39777, longitude:-121.4478))
     
   
   route.append(CLLocation(latitude:47.39786, longitude:-121.44762))
     
   
   route.append(CLLocation(latitude:47.39804, longitude:-121.4473))
     
   
   route.append(CLLocation(latitude:47.39822, longitude:-121.44699))
     
   
   route.append(CLLocation(latitude:47.39842, longitude:-121.44669))
     
   
   route.append(CLLocation(latitude:47.39859, longitude:-121.44646))
     
   
   route.append(CLLocation(latitude:47.39871, longitude:-121.4463))
     
   
   route.append(CLLocation(latitude:47.39881, longitude:-121.44618))
     
   
   route.append(CLLocation(latitude:47.39906, longitude:-121.4459))
     
   
   route.append(CLLocation(latitude:47.39934, longitude:-121.44563))
     
   
   route.append(CLLocation(latitude:47.40033, longitude:-121.44461))
     
   
   route.append(CLLocation(latitude:47.40068, longitude:-121.44427))
     
   
   route.append(CLLocation(latitude:47.40098, longitude:-121.44401))
     
   
   route.append(CLLocation(latitude:47.40128, longitude:-121.44378))
     
   
   route.append(CLLocation(latitude:47.40155, longitude:-121.44359))
     
   
   route.append(CLLocation(latitude:47.40177, longitude:-121.44345))
     
   
   route.append(CLLocation(latitude:47.40195, longitude:-121.44334))
     
   
   route.append(CLLocation(latitude:47.40206, longitude:-121.44328))
     
   
   route.append(CLLocation(latitude:47.40227, longitude:-121.44318))
     
   
   route.append(CLLocation(latitude:47.40268, longitude:-121.44297))
     
   
   route.append(CLLocation(latitude:47.40414, longitude:-121.44216))
     
   
   route.append(CLLocation(latitude:47.40444, longitude:-121.44202))
     
   
   route.append(CLLocation(latitude:47.40455, longitude:-121.44196))
     
   
   route.append(CLLocation(latitude:47.40496, longitude:-121.44174))
     
   
   route.append(CLLocation(latitude:47.40591, longitude:-121.44122))
     
   
   route.append(CLLocation(latitude:47.40671, longitude:-121.44081))
     
   
   route.append(CLLocation(latitude:47.40753, longitude:-121.44036))
     
   
   route.append(CLLocation(latitude:47.40827, longitude:-121.43995))
     
   
   route.append(CLLocation(latitude:47.40929, longitude:-121.43941))
     
   
   route.append(CLLocation(latitude:47.40983, longitude:-121.43912))
     
   
   route.append(CLLocation(latitude:47.40991, longitude:-121.43908))
     
   
   route.append(CLLocation(latitude:47.41008, longitude:-121.439))
     
   
   route.append(CLLocation(latitude:47.41015, longitude:-121.43898))
     
   
   route.append(CLLocation(latitude:47.41094, longitude:-121.43868))
     
   
   route.append(CLLocation(latitude:47.4123, longitude:-121.43826))
     
   
   route.append(CLLocation(latitude:47.4129, longitude:-121.43804))
     
   
   route.append(CLLocation(latitude:47.41303, longitude:-121.43798))
     
   
   route.append(CLLocation(latitude:47.41311, longitude:-121.43794))
     
   
   route.append(CLLocation(latitude:47.41321, longitude:-121.43788))
     
   
   route.append(CLLocation(latitude:47.4133, longitude:-121.43783))
     
   
   route.append(CLLocation(latitude:47.41347, longitude:-121.43771))
     
   
   route.append(CLLocation(latitude:47.41376, longitude:-121.4375))
     
   
   route.append(CLLocation(latitude:47.41425, longitude:-121.43714))
     
   
   route.append(CLLocation(latitude:47.41844, longitude:-121.43401))
     
   
   route.append(CLLocation(latitude:47.41927, longitude:-121.43342))
     
   
   route.append(CLLocation(latitude:47.41952, longitude:-121.43326))
     
   
   route.append(CLLocation(latitude:47.41975, longitude:-121.43312))
     
   
   route.append(CLLocation(latitude:47.41978, longitude:-121.4331))
     
   
   route.append(CLLocation(latitude:47.42003, longitude:-121.43295))
     
   
   route.append(CLLocation(latitude:47.42029, longitude:-121.43282))
     
   
   route.append(CLLocation(latitude:47.42099, longitude:-121.43248))
     
   
   route.append(CLLocation(latitude:47.42127, longitude:-121.43236))
     
   
   route.append(CLLocation(latitude:47.42183, longitude:-121.43213))
     
   
   route.append(CLLocation(latitude:47.42212, longitude:-121.43203))
     
   
   route.append(CLLocation(latitude:47.42242, longitude:-121.43195))
     
   
   route.append(CLLocation(latitude:47.42271, longitude:-121.43187))
     
   
   route.append(CLLocation(latitude:47.423, longitude:-121.43181))
     
   
   route.append(CLLocation(latitude:47.42328, longitude:-121.43174))
     
   
   route.append(CLLocation(latitude:47.42356, longitude:-121.43165))
     
   
   route.append(CLLocation(latitude:47.42384, longitude:-121.43155))
     
   
   route.append(CLLocation(latitude:47.42411, longitude:-121.43141))
     
   
   route.append(CLLocation(latitude:47.4243, longitude:-121.43129))
     
   
   route.append(CLLocation(latitude:47.4245, longitude:-121.43115))
     
   
   route.append(CLLocation(latitude:47.42466, longitude:-121.43102))
     
   
   route.append(CLLocation(latitude:47.42483, longitude:-121.43083))
     
   
   route.append(CLLocation(latitude:47.42501, longitude:-121.43063))
     
   
   route.append(CLLocation(latitude:47.42512, longitude:-121.43048))
     
   
   route.append(CLLocation(latitude:47.42524, longitude:-121.4303))
     
   
   route.append(CLLocation(latitude:47.42532, longitude:-121.43017))
     
   
   route.append(CLLocation(latitude:47.4254, longitude:-121.43005))
     
   
   route.append(CLLocation(latitude:47.42546, longitude:-121.42995))
     
   
   route.append(CLLocation(latitude:47.42553, longitude:-121.42982))
     
   
   route.append(CLLocation(latitude:47.4256, longitude:-121.4297))
     
   
   route.append(CLLocation(latitude:47.42572, longitude:-121.42942))
     
   
   route.append(CLLocation(latitude:47.42584, longitude:-121.42916))
     
   
   route.append(CLLocation(latitude:47.42659, longitude:-121.42733))
     
   
   route.append(CLLocation(latitude:47.42672, longitude:-121.42703))
     
   
   route.append(CLLocation(latitude:47.42689, longitude:-121.42663))
     
   
   route.append(CLLocation(latitude:47.42711, longitude:-121.42607))
     
   
   route.append(CLLocation(latitude:47.42717, longitude:-121.42592))
     
   
   route.append(CLLocation(latitude:47.42725, longitude:-121.4257))
     
   
   route.append(CLLocation(latitude:47.42737, longitude:-121.42534))
     
   
   route.append(CLLocation(latitude:47.42759, longitude:-121.42461))
     
   
   route.append(CLLocation(latitude:47.42775, longitude:-121.42407))
     
   
   route.append(CLLocation(latitude:47.42806, longitude:-121.42299))
     
   
   route.append(CLLocation(latitude:47.42823, longitude:-121.42241))
     
   
   route.append(CLLocation(latitude:47.42829, longitude:-121.42213))
     
   
   route.append(CLLocation(latitude:47.42833, longitude:-121.42197))
     
   
   route.append(CLLocation(latitude:47.42836, longitude:-121.42181))
     
   
   route.append(CLLocation(latitude:47.42839, longitude:-121.42163))
     
   
   route.append(CLLocation(latitude:47.42841, longitude:-121.42148))
     
   
   route.append(CLLocation(latitude:47.42842, longitude:-121.42138))
     
   
   route.append(CLLocation(latitude:47.42843, longitude:-121.42127))
     
   
   route.append(CLLocation(latitude:47.42844, longitude:-121.42115))
     
   
   route.append(CLLocation(latitude:47.42845, longitude:-121.421))
     
   
   route.append(CLLocation(latitude:47.42845, longitude:-121.42091))
     
   
   route.append(CLLocation(latitude:47.42845, longitude:-121.42082))
     
   
   route.append(CLLocation(latitude:47.42845, longitude:-121.42058))
     
   
   route.append(CLLocation(latitude:47.42844, longitude:-121.42036))
     
   
   route.append(CLLocation(latitude:47.42843, longitude:-121.4202))
     
   
   route.append(CLLocation(latitude:47.42842, longitude:-121.42004))
     
   
   route.append(CLLocation(latitude:47.4284, longitude:-121.41989))
     
   
   route.append(CLLocation(latitude:47.42838, longitude:-121.41975))
     
   
   route.append(CLLocation(latitude:47.42836, longitude:-121.41959))
     
   
   route.append(CLLocation(latitude:47.42833, longitude:-121.41944))
     
   
   route.append(CLLocation(latitude:47.4283, longitude:-121.41931))
     
   
   route.append(CLLocation(latitude:47.42828, longitude:-121.41923))
     
   
   route.append(CLLocation(latitude:47.42826, longitude:-121.41913))
     
   
   route.append(CLLocation(latitude:47.42822, longitude:-121.419))
     
   
   route.append(CLLocation(latitude:47.42818, longitude:-121.41888))
     
   
   route.append(CLLocation(latitude:47.42813, longitude:-121.41872))
     
   
   route.append(CLLocation(latitude:47.42802, longitude:-121.41844))
     
   
   route.append(CLLocation(latitude:47.42696, longitude:-121.41587))
     
   
   route.append(CLLocation(latitude:47.42682, longitude:-121.41554))
     
   
   route.append(CLLocation(latitude:47.42682, longitude:-121.41553))
     
   
   route.append(CLLocation(latitude:47.42668, longitude:-121.4152))
     
   
   route.append(CLLocation(latitude:47.42611, longitude:-121.41383))
     
   
   route.append(CLLocation(latitude:47.42593, longitude:-121.41341))
     
   
   route.append(CLLocation(latitude:47.42581, longitude:-121.41314))
     
   
   route.append(CLLocation(latitude:47.42567, longitude:-121.41285))
     
   
   route.append(CLLocation(latitude:47.42547, longitude:-121.41249))
     
   
   route.append(CLLocation(latitude:47.42539, longitude:-121.41235))
     
   
   route.append(CLLocation(latitude:47.42525, longitude:-121.41214))
     
   
   route.append(CLLocation(latitude:47.42516, longitude:-121.412))
     
   
   route.append(CLLocation(latitude:47.42508, longitude:-121.41189))
     
   
   route.append(CLLocation(latitude:47.42502, longitude:-121.4118))
     
   
   route.append(CLLocation(latitude:47.42493, longitude:-121.41169))
     
   
   route.append(CLLocation(latitude:47.42484, longitude:-121.41158))
     
   
   route.append(CLLocation(latitude:47.42475, longitude:-121.41146))
     
   
   route.append(CLLocation(latitude:47.42466, longitude:-121.41137))
     
   
   route.append(CLLocation(latitude:47.42448, longitude:-121.41117))
     
   
   route.append(CLLocation(latitude:47.42432, longitude:-121.41102))
     
   
   route.append(CLLocation(latitude:47.42422, longitude:-121.41093))
     
   
   route.append(CLLocation(latitude:47.42412, longitude:-121.41084))
     
   
   route.append(CLLocation(latitude:47.42394, longitude:-121.41069))
     
   
   route.append(CLLocation(latitude:47.42375, longitude:-121.41056))
     
   
   route.append(CLLocation(latitude:47.42355, longitude:-121.41043))
     
   
   route.append(CLLocation(latitude:47.42328, longitude:-121.41026))
     
   
   route.append(CLLocation(latitude:47.42311, longitude:-121.41017))
     
   
   route.append(CLLocation(latitude:47.42293, longitude:-121.41009))
     
   
   route.append(CLLocation(latitude:47.42283, longitude:-121.41005))
     
   
   route.append(CLLocation(latitude:47.42272, longitude:-121.41001))
     
   
   route.append(CLLocation(latitude:47.4225, longitude:-121.40995))
     
   
   route.append(CLLocation(latitude:47.42218, longitude:-121.40988))
     
   
   route.append(CLLocation(latitude:47.42187, longitude:-121.40984))
     
   
   route.append(CLLocation(latitude:47.42153, longitude:-121.40984))
     
   
   route.append(CLLocation(latitude:47.4212, longitude:-121.40986))
     
   
   route.append(CLLocation(latitude:47.42087, longitude:-121.40991))
     
   
   route.append(CLLocation(latitude:47.42055, longitude:-121.40999))
     
   
   route.append(CLLocation(latitude:47.42032, longitude:-121.41005))
     
   
   route.append(CLLocation(latitude:47.41934, longitude:-121.41036))
     
   
   route.append(CLLocation(latitude:47.41842, longitude:-121.41062))
     
   
   route.append(CLLocation(latitude:47.41804, longitude:-121.41073))
     
   
   route.append(CLLocation(latitude:47.41774, longitude:-121.41082))
     
   
   route.append(CLLocation(latitude:47.41706, longitude:-121.41101))
     
   
   route.append(CLLocation(latitude:47.41642, longitude:-121.4112))
     
   
   route.append(CLLocation(latitude:47.41621, longitude:-121.41126))
     
   
   route.append(CLLocation(latitude:47.41599, longitude:-121.41131))
     
   
   route.append(CLLocation(latitude:47.41578, longitude:-121.41134))
     
   
   route.append(CLLocation(latitude:47.41554, longitude:-121.41137))
     
   
   route.append(CLLocation(latitude:47.41533, longitude:-121.41138))
     
   
   route.append(CLLocation(latitude:47.41521, longitude:-121.41137))
     
   
   route.append(CLLocation(latitude:47.41504, longitude:-121.41136))
     
   
   route.append(CLLocation(latitude:47.41481, longitude:-121.41133))
     
   
   route.append(CLLocation(latitude:47.41454, longitude:-121.41129))
     
   
   route.append(CLLocation(latitude:47.41452, longitude:-121.41128))
     
   
   route.append(CLLocation(latitude:47.41411, longitude:-121.41117))
     
   
   route.append(CLLocation(latitude:47.41378, longitude:-121.41104))
     
   
   route.append(CLLocation(latitude:47.41358, longitude:-121.41096))
     
   
   route.append(CLLocation(latitude:47.41335, longitude:-121.41089))
     
   
   route.append(CLLocation(latitude:47.41303, longitude:-121.41078))
     
   
   route.append(CLLocation(latitude:47.41275, longitude:-121.41067))
     
   
   route.append(CLLocation(latitude:47.41252, longitude:-121.4106))
     
   
   route.append(CLLocation(latitude:47.41227, longitude:-121.41051))
     
   
   route.append(CLLocation(latitude:47.41199, longitude:-121.41041))
     
   
   route.append(CLLocation(latitude:47.41176, longitude:-121.41032))
     
   
   route.append(CLLocation(latitude:47.41157, longitude:-121.41026))
     
   
   route.append(CLLocation(latitude:47.41125, longitude:-121.41013))
     
   
   route.append(CLLocation(latitude:47.41104, longitude:-121.41002))
     
   
   route.append(CLLocation(latitude:47.41083, longitude:-121.40989))
     
   
   route.append(CLLocation(latitude:47.41062, longitude:-121.40974))
     
   
   route.append(CLLocation(latitude:47.41037, longitude:-121.40951))
     
   
   route.append(CLLocation(latitude:47.41018, longitude:-121.40932))
     
   
   route.append(CLLocation(latitude:47.41002, longitude:-121.40912))
     
   
   route.append(CLLocation(latitude:47.40993, longitude:-121.40902))
     
   
   route.append(CLLocation(latitude:47.40985, longitude:-121.4089))
     
   
   route.append(CLLocation(latitude:47.40846, longitude:-121.40667))
     
   
   route.append(CLLocation(latitude:47.40806, longitude:-121.40603))
     
   
   route.append(CLLocation(latitude:47.40797, longitude:-121.40589))
     
   
   route.append(CLLocation(latitude:47.40786, longitude:-121.40573))
     
   
   route.append(CLLocation(latitude:47.4077, longitude:-121.40552))
     
   
   route.append(CLLocation(latitude:47.40751, longitude:-121.40529))
     
   
   route.append(CLLocation(latitude:47.40733, longitude:-121.40511))
     
   
   route.append(CLLocation(latitude:47.40707, longitude:-121.40488))
     
   
   route.append(CLLocation(latitude:47.40686, longitude:-121.40472))
     
   
   route.append(CLLocation(latitude:47.40657, longitude:-121.40455))
     
   
   route.append(CLLocation(latitude:47.40635, longitude:-121.40445))
     
   
   route.append(CLLocation(latitude:47.40615, longitude:-121.40437))
     
   
   route.append(CLLocation(latitude:47.40593, longitude:-121.40431))
     
   
   route.append(CLLocation(latitude:47.40572, longitude:-121.40427))
     
   
   route.append(CLLocation(latitude:47.4055, longitude:-121.40424))
     
   
   route.append(CLLocation(latitude:47.40527, longitude:-121.40423))
     
   
   route.append(CLLocation(latitude:47.40499, longitude:-121.40424))
     
   
   route.append(CLLocation(latitude:47.40463, longitude:-121.40424))
     
   
   route.append(CLLocation(latitude:47.40419, longitude:-121.40426))
     
   
   route.append(CLLocation(latitude:47.40376, longitude:-121.40426))
     
   
   route.append(CLLocation(latitude:47.40345, longitude:-121.40427))
     
   
   route.append(CLLocation(latitude:47.40321, longitude:-121.40427))
     
   
   route.append(CLLocation(latitude:47.40297, longitude:-121.40426))
     
   
   route.append(CLLocation(latitude:47.40278, longitude:-121.40423))
     
   
   route.append(CLLocation(latitude:47.40259, longitude:-121.40417))
     
   
   route.append(CLLocation(latitude:47.40247, longitude:-121.40413))
     
   
   route.append(CLLocation(latitude:47.40239, longitude:-121.40411))
     
   
   route.append(CLLocation(latitude:47.40229, longitude:-121.40406))
     
   
   route.append(CLLocation(latitude:47.40222, longitude:-121.40403))
     
   
   route.append(CLLocation(latitude:47.40215, longitude:-121.40399))
     
   
   route.append(CLLocation(latitude:47.40202, longitude:-121.40392))
     
   
   route.append(CLLocation(latitude:47.40191, longitude:-121.40384))
     
   
   route.append(CLLocation(latitude:47.40178, longitude:-121.40375))
     
   
   route.append(CLLocation(latitude:47.40172, longitude:-121.40371))
     
   
   route.append(CLLocation(latitude:47.40168, longitude:-121.40367))
     
   
   route.append(CLLocation(latitude:47.40163, longitude:-121.40363))
     
   
   route.append(CLLocation(latitude:47.40154, longitude:-121.40355))
     
   
   route.append(CLLocation(latitude:47.40144, longitude:-121.40344))
     
   
   route.append(CLLocation(latitude:47.40138, longitude:-121.40338))
     
   
   route.append(CLLocation(latitude:47.40132, longitude:-121.40332))
     
   
   route.append(CLLocation(latitude:47.40124, longitude:-121.40322))
     
   
   route.append(CLLocation(latitude:47.40114, longitude:-121.40311))
     
   
   route.append(CLLocation(latitude:47.40102, longitude:-121.40293))
     
   
   route.append(CLLocation(latitude:47.40079, longitude:-121.40257))
     
   
   route.append(CLLocation(latitude:47.40029, longitude:-121.40175))
     
   
   route.append(CLLocation(latitude:47.39999, longitude:-121.40127))
     
   
   route.append(CLLocation(latitude:47.39981, longitude:-121.40097))
     
   
   route.append(CLLocation(latitude:47.39922, longitude:-121.40002))
     
   
   route.append(CLLocation(latitude:47.39904, longitude:-121.3998))
     
   
   route.append(CLLocation(latitude:47.39896, longitude:-121.3997))
     
   
   route.append(CLLocation(latitude:47.39887, longitude:-121.39961))
     
   
   route.append(CLLocation(latitude:47.39879, longitude:-121.39951))
     
   
   route.append(CLLocation(latitude:47.3987, longitude:-121.39942))
     
   
   route.append(CLLocation(latitude:47.39852, longitude:-121.39926))
     
   
   route.append(CLLocation(latitude:47.39842, longitude:-121.39917))
     
   
   route.append(CLLocation(latitude:47.39752, longitude:-121.39841))
     
   
   route.append(CLLocation(latitude:47.39716, longitude:-121.39812))
     
   
   route.append(CLLocation(latitude:47.397, longitude:-121.39798))
     
   
   route.append(CLLocation(latitude:47.39678, longitude:-121.39779))
     
   
   route.append(CLLocation(latitude:47.3966, longitude:-121.39761))
     
   
   route.append(CLLocation(latitude:47.39639, longitude:-121.39736))
     
   
   route.append(CLLocation(latitude:47.39624, longitude:-121.39718))
     
   
   route.append(CLLocation(latitude:47.39609, longitude:-121.39698))
     
   
   route.append(CLLocation(latitude:47.396, longitude:-121.39685))
     
   
   route.append(CLLocation(latitude:47.39587, longitude:-121.39665))
     
   
   route.append(CLLocation(latitude:47.39574, longitude:-121.39644))
     
   
   route.append(CLLocation(latitude:47.39558, longitude:-121.39612))
     
   
   route.append(CLLocation(latitude:47.3955, longitude:-121.39596))
     
   
   route.append(CLLocation(latitude:47.39542, longitude:-121.39578))
     
   
   route.append(CLLocation(latitude:47.39537, longitude:-121.39565))
     
   
   route.append(CLLocation(latitude:47.39531, longitude:-121.3955))
     
   
   route.append(CLLocation(latitude:47.39474, longitude:-121.39407))
     
   
   route.append(CLLocation(latitude:47.39451, longitude:-121.39349))
     
   
   route.append(CLLocation(latitude:47.394, longitude:-121.39218))
     
   
   route.append(CLLocation(latitude:47.39314, longitude:-121.38994))
     
   
   route.append(CLLocation(latitude:47.39267, longitude:-121.38856))
     
   
   route.append(CLLocation(latitude:47.3924, longitude:-121.38781))
     
   
   route.append(CLLocation(latitude:47.39218, longitude:-121.38719))
     
   
   route.append(CLLocation(latitude:47.39208, longitude:-121.38693))
     
   
   route.append(CLLocation(latitude:47.392, longitude:-121.38672))
     
   
   route.append(CLLocation(latitude:47.39193, longitude:-121.38654))
     
   
   route.append(CLLocation(latitude:47.39167, longitude:-121.38593))
     
   
   route.append(CLLocation(latitude:47.39148, longitude:-121.3855))
     
   
   route.append(CLLocation(latitude:47.39116, longitude:-121.38485))
     
   
   route.append(CLLocation(latitude:47.39091, longitude:-121.38438))
     
   
   route.append(CLLocation(latitude:47.3907, longitude:-121.38401))
     
   
   route.append(CLLocation(latitude:47.39048, longitude:-121.38363))
     
   
   route.append(CLLocation(latitude:47.39002, longitude:-121.3829))
     
   
   route.append(CLLocation(latitude:47.38976, longitude:-121.38254))
     
   
   route.append(CLLocation(latitude:47.38953, longitude:-121.38222))
     
   
   route.append(CLLocation(latitude:47.38926, longitude:-121.38186))
     
   
   route.append(CLLocation(latitude:47.38901, longitude:-121.38158))
     
   
   route.append(CLLocation(latitude:47.38876, longitude:-121.38129))
     
   
   route.append(CLLocation(latitude:47.38833, longitude:-121.38083))
     
   
   route.append(CLLocation(latitude:47.388, longitude:-121.38055))
     
   
   route.append(CLLocation(latitude:47.38779, longitude:-121.38038))
     
   
   route.append(CLLocation(latitude:47.38748, longitude:-121.38014))
     
   
   route.append(CLLocation(latitude:47.38741, longitude:-121.38009))
     
   
   route.append(CLLocation(latitude:47.38724, longitude:-121.37997))
     
   
   route.append(CLLocation(latitude:47.38691, longitude:-121.37976))
     
   
   route.append(CLLocation(latitude:47.38679, longitude:-121.37969))
     
   
   route.append(CLLocation(latitude:47.3866, longitude:-121.37959))
     
   
   route.append(CLLocation(latitude:47.38638, longitude:-121.37947))
     
   
   route.append(CLLocation(latitude:47.38569, longitude:-121.37914))
     
   
   route.append(CLLocation(latitude:47.38535, longitude:-121.37898))
     
   
   route.append(CLLocation(latitude:47.38489, longitude:-121.37875))
     
   
   route.append(CLLocation(latitude:47.38411, longitude:-121.37836))
     
   
   route.append(CLLocation(latitude:47.38401, longitude:-121.37831))
     
   
   route.append(CLLocation(latitude:47.38387, longitude:-121.37825))
     
   
   route.append(CLLocation(latitude:47.38375, longitude:-121.37819))
     
   
   route.append(CLLocation(latitude:47.38358, longitude:-121.37812))
     
   
   route.append(CLLocation(latitude:47.38337, longitude:-121.37805))
     
   
   route.append(CLLocation(latitude:47.38323, longitude:-121.378))
     
   
   route.append(CLLocation(latitude:47.38302, longitude:-121.37794))
     
   
   route.append(CLLocation(latitude:47.38284, longitude:-121.37789))
     
   
   route.append(CLLocation(latitude:47.3826, longitude:-121.37783))
     
   
   route.append(CLLocation(latitude:47.38233, longitude:-121.37778))
     
   
   route.append(CLLocation(latitude:47.38209, longitude:-121.37775))
     
   
   route.append(CLLocation(latitude:47.38187, longitude:-121.37773))
     
   
   route.append(CLLocation(latitude:47.38165, longitude:-121.37771))
     
   
   route.append(CLLocation(latitude:47.38137, longitude:-121.37769))
     
   
   route.append(CLLocation(latitude:47.3799, longitude:-121.37759))
     
   
   route.append(CLLocation(latitude:47.37875, longitude:-121.37751))
     
   
   route.append(CLLocation(latitude:47.37594, longitude:-121.37732))
     
   
   route.append(CLLocation(latitude:47.37569, longitude:-121.37729))
     
   
   route.append(CLLocation(latitude:47.37525, longitude:-121.37726))
     
   
   route.append(CLLocation(latitude:47.37477, longitude:-121.37722))
     
   
   route.append(CLLocation(latitude:47.37467, longitude:-121.37721))
     
   
   route.append(CLLocation(latitude:47.37456, longitude:-121.37719))
     
   
   route.append(CLLocation(latitude:47.37436, longitude:-121.37716))
     
   
   route.append(CLLocation(latitude:47.37416, longitude:-121.37712))
     
   
   route.append(CLLocation(latitude:47.37398, longitude:-121.37708))
     
   
   route.append(CLLocation(latitude:47.37375, longitude:-121.37703))
     
   
   route.append(CLLocation(latitude:47.37353, longitude:-121.37697))
     
   
   route.append(CLLocation(latitude:47.37338, longitude:-121.37693))
     
   
   route.append(CLLocation(latitude:47.3733, longitude:-121.3769))
     
   
   route.append(CLLocation(latitude:47.37298, longitude:-121.37679))
     
   
   route.append(CLLocation(latitude:47.37275, longitude:-121.37669))
     
   
   route.append(CLLocation(latitude:47.37257, longitude:-121.37662))
     
   
   route.append(CLLocation(latitude:47.37241, longitude:-121.37654))
     
   
   route.append(CLLocation(latitude:47.37222, longitude:-121.37645))
     
   
   route.append(CLLocation(latitude:47.37202, longitude:-121.37634))
     
   
   route.append(CLLocation(latitude:47.37183, longitude:-121.37623))
     
   
   route.append(CLLocation(latitude:47.3717, longitude:-121.37614))
     
   
   route.append(CLLocation(latitude:47.37152, longitude:-121.37603))
     
   
   route.append(CLLocation(latitude:47.37132, longitude:-121.37589))
     
   
   route.append(CLLocation(latitude:47.37115, longitude:-121.37576))
     
   
   route.append(CLLocation(latitude:47.37076, longitude:-121.37545))
     
   
   route.append(CLLocation(latitude:47.37031, longitude:-121.37504))
     
   
   route.append(CLLocation(latitude:47.3699, longitude:-121.37462))
     
   
   route.append(CLLocation(latitude:47.36966, longitude:-121.3744))
     
   
   route.append(CLLocation(latitude:47.36941, longitude:-121.37415))
     
   
   route.append(CLLocation(latitude:47.36921, longitude:-121.37396))
     
   
   route.append(CLLocation(latitude:47.36902, longitude:-121.37379))
     
   
   route.append(CLLocation(latitude:47.36883, longitude:-121.37365))
     
   
   route.append(CLLocation(latitude:47.3687, longitude:-121.37355))
     
   
   route.append(CLLocation(latitude:47.36858, longitude:-121.37347))
     
   
   route.append(CLLocation(latitude:47.36846, longitude:-121.37341))
     
   
   route.append(CLLocation(latitude:47.36827, longitude:-121.3733))
     
   
   route.append(CLLocation(latitude:47.3681, longitude:-121.37322))
     
   
   route.append(CLLocation(latitude:47.36795, longitude:-121.37316))
     
   
   route.append(CLLocation(latitude:47.36783, longitude:-121.3731))
     
   
   route.append(CLLocation(latitude:47.36771, longitude:-121.37305))
     
   
   route.append(CLLocation(latitude:47.36751, longitude:-121.37299))
     
   
   route.append(CLLocation(latitude:47.36731, longitude:-121.37292))
     
   
   route.append(CLLocation(latitude:47.36712, longitude:-121.37288))
     
   
   route.append(CLLocation(latitude:47.36693, longitude:-121.37286))
     
   
   route.append(CLLocation(latitude:47.36677, longitude:-121.37284))
     
   
   route.append(CLLocation(latitude:47.36662, longitude:-121.37283))
     
   
   route.append(CLLocation(latitude:47.36642, longitude:-121.37282))
     
   
   route.append(CLLocation(latitude:47.36615, longitude:-121.37283))
     
   
   route.append(CLLocation(latitude:47.36425, longitude:-121.373))
     
   
   route.append(CLLocation(latitude:47.3638, longitude:-121.37305))
     
   
   route.append(CLLocation(latitude:47.3635, longitude:-121.37309))
     
   
   route.append(CLLocation(latitude:47.36327, longitude:-121.37312))
     
   
   route.append(CLLocation(latitude:47.36308, longitude:-121.37313))
     
   
   route.append(CLLocation(latitude:47.36292, longitude:-121.37314))
     
   
   route.append(CLLocation(latitude:47.36271, longitude:-121.37314))
     
   
   route.append(CLLocation(latitude:47.36254, longitude:-121.37313))
     
   
   route.append(CLLocation(latitude:47.36242, longitude:-121.37312))
     
   
   route.append(CLLocation(latitude:47.36228, longitude:-121.3731))
     
   
   route.append(CLLocation(latitude:47.36216, longitude:-121.37308))
     
   
   route.append(CLLocation(latitude:47.36191, longitude:-121.37302))
     
   
   route.append(CLLocation(latitude:47.36177, longitude:-121.37297))
     
   
   route.append(CLLocation(latitude:47.36162, longitude:-121.37292))
     
   
   route.append(CLLocation(latitude:47.36148, longitude:-121.37286))
     
   
   route.append(CLLocation(latitude:47.36133, longitude:-121.37278))
     
   
   route.append(CLLocation(latitude:47.36105, longitude:-121.37261))
     
   
   route.append(CLLocation(latitude:47.36095, longitude:-121.37254))
     
   
   route.append(CLLocation(latitude:47.36074, longitude:-121.37238))
     
   
   route.append(CLLocation(latitude:47.36059, longitude:-121.37225))
     
   
   route.append(CLLocation(latitude:47.3604, longitude:-121.37206))
     
   
   route.append(CLLocation(latitude:47.36024, longitude:-121.37189))
     
   
   route.append(CLLocation(latitude:47.36012, longitude:-121.37174))
     
   
   route.append(CLLocation(latitude:47.35991, longitude:-121.37146))
     
   
   route.append(CLLocation(latitude:47.35763, longitude:-121.36812))
     
   
   route.append(CLLocation(latitude:47.35706, longitude:-121.36725))
     
   
   route.append(CLLocation(latitude:47.35665, longitude:-121.36684))
     
   
   route.append(CLLocation(latitude:47.35653, longitude:-121.36673))
     
   
   route.append(CLLocation(latitude:47.35636, longitude:-121.3666))
     
   
   route.append(CLLocation(latitude:47.35619, longitude:-121.36646))
     
   
   route.append(CLLocation(latitude:47.35596, longitude:-121.36631))
     
   
   route.append(CLLocation(latitude:47.35584, longitude:-121.36623))
     
   
   route.append(CLLocation(latitude:47.35561, longitude:-121.36609))
     
   
   route.append(CLLocation(latitude:47.35551, longitude:-121.36604))
     
   
   route.append(CLLocation(latitude:47.35541, longitude:-121.36599))
     
   
   route.append(CLLocation(latitude:47.35507, longitude:-121.36585))
     
   
   route.append(CLLocation(latitude:47.35457, longitude:-121.36564))
     
   
   route.append(CLLocation(latitude:47.35432, longitude:-121.36554))
     
   
   route.append(CLLocation(latitude:47.35394, longitude:-121.36539))
     
   
   route.append(CLLocation(latitude:47.35338, longitude:-121.36517))
     
   
   route.append(CLLocation(latitude:47.35292, longitude:-121.36498))
     
   
   route.append(CLLocation(latitude:47.3523, longitude:-121.36473))
     
   
   route.append(CLLocation(latitude:47.35163, longitude:-121.36443))
     
   
   route.append(CLLocation(latitude:47.35139, longitude:-121.36433))
     
   
   route.append(CLLocation(latitude:47.3509, longitude:-121.36409))
     
   
   route.append(CLLocation(latitude:47.35068, longitude:-121.36399))
     
   
   route.append(CLLocation(latitude:47.35048, longitude:-121.36389))
     
   
   route.append(CLLocation(latitude:47.35028, longitude:-121.36381))
     
   
   route.append(CLLocation(latitude:47.35009, longitude:-121.36374))
     
   
   route.append(CLLocation(latitude:47.34988, longitude:-121.36367))
     
   
   route.append(CLLocation(latitude:47.34974, longitude:-121.36363))
     
   
   route.append(CLLocation(latitude:47.34954, longitude:-121.36361))
     
   
   route.append(CLLocation(latitude:47.34928, longitude:-121.36359))
     
   
   route.append(CLLocation(latitude:47.34892, longitude:-121.3636))
     
   
   route.append(CLLocation(latitude:47.34859, longitude:-121.36364))
     
   
   route.append(CLLocation(latitude:47.34801, longitude:-121.36378))
     
   
   route.append(CLLocation(latitude:47.34778, longitude:-121.36384))
     
   
   route.append(CLLocation(latitude:47.34688, longitude:-121.36408))
     
   
   route.append(CLLocation(latitude:47.34637, longitude:-121.36422))
     
   
   route.append(CLLocation(latitude:47.34602, longitude:-121.36432))
     
   
   route.append(CLLocation(latitude:47.34535, longitude:-121.3645))
     
   
   route.append(CLLocation(latitude:47.3451, longitude:-121.36454))
     
   
   route.append(CLLocation(latitude:47.34486, longitude:-121.36458))
     
   
   route.append(CLLocation(latitude:47.34466, longitude:-121.36458))
     
   
   route.append(CLLocation(latitude:47.34445, longitude:-121.36457))
     
   
   route.append(CLLocation(latitude:47.34426, longitude:-121.36455))
     
   
   route.append(CLLocation(latitude:47.34411, longitude:-121.36452))
     
   
   route.append(CLLocation(latitude:47.34393, longitude:-121.36446))
     
   
   route.append(CLLocation(latitude:47.34364, longitude:-121.36441))
     
   
   route.append(CLLocation(latitude:47.3435, longitude:-121.36436))
     
   
   route.append(CLLocation(latitude:47.34331, longitude:-121.36427))
     
   
   route.append(CLLocation(latitude:47.34322, longitude:-121.36423))
     
   
   route.append(CLLocation(latitude:47.34311, longitude:-121.36417))
     
   
   route.append(CLLocation(latitude:47.3429, longitude:-121.36404))
     
   
   route.append(CLLocation(latitude:47.34272, longitude:-121.36391))
     
   
   route.append(CLLocation(latitude:47.34261, longitude:-121.36383))
     
   
   route.append(CLLocation(latitude:47.34251, longitude:-121.36374))
     
   
   route.append(CLLocation(latitude:47.34242, longitude:-121.36367))
     
   
   route.append(CLLocation(latitude:47.34232, longitude:-121.36358))
     
   
   route.append(CLLocation(latitude:47.34215, longitude:-121.3634))
     
   
   route.append(CLLocation(latitude:47.34206, longitude:-121.3633))
     
   
   route.append(CLLocation(latitude:47.34196, longitude:-121.36319))
     
   
   route.append(CLLocation(latitude:47.34188, longitude:-121.36308))
     
   
   route.append(CLLocation(latitude:47.34177, longitude:-121.36294))
     
   
   route.append(CLLocation(latitude:47.34169, longitude:-121.36283))
     
   
   route.append(CLLocation(latitude:47.34161, longitude:-121.36271))
     
   
   route.append(CLLocation(latitude:47.34154, longitude:-121.3626))
     
   
   route.append(CLLocation(latitude:47.34142, longitude:-121.36241))
     
   
   route.append(CLLocation(latitude:47.34134, longitude:-121.36227))
     
   
   route.append(CLLocation(latitude:47.34127, longitude:-121.36214))
     
   
   route.append(CLLocation(latitude:47.3412, longitude:-121.362))
     
   
   route.append(CLLocation(latitude:47.34113, longitude:-121.36185))
     
   
   route.append(CLLocation(latitude:47.34107, longitude:-121.36171))
     
   
   route.append(CLLocation(latitude:47.34101, longitude:-121.36157))
     
   
   route.append(CLLocation(latitude:47.3409, longitude:-121.36133))
     
   
   route.append(CLLocation(latitude:47.34084, longitude:-121.36118))
     
   
   route.append(CLLocation(latitude:47.34078, longitude:-121.36103))
     
   
   route.append(CLLocation(latitude:47.34074, longitude:-121.36091))
     
   
   route.append(CLLocation(latitude:47.34069, longitude:-121.36076))
     
   
   route.append(CLLocation(latitude:47.34065, longitude:-121.36062))
     
   
   route.append(CLLocation(latitude:47.3406, longitude:-121.36046))
     
   
   route.append(CLLocation(latitude:47.34057, longitude:-121.36033))
     
   
   route.append(CLLocation(latitude:47.34052, longitude:-121.36015))
     
   
   route.append(CLLocation(latitude:47.34047, longitude:-121.35993))
     
   
   route.append(CLLocation(latitude:47.34043, longitude:-121.3597))
     
   
   route.append(CLLocation(latitude:47.3404, longitude:-121.35949))
     
   
   route.append(CLLocation(latitude:47.34038, longitude:-121.35935))
     
   
   route.append(CLLocation(latitude:47.34036, longitude:-121.35923))
     
   
   route.append(CLLocation(latitude:47.34034, longitude:-121.35909))
     
   
   route.append(CLLocation(latitude:47.34032, longitude:-121.35892))
     
   
   route.append(CLLocation(latitude:47.3403, longitude:-121.35877))
     
   
   route.append(CLLocation(latitude:47.34029, longitude:-121.35864))
     
   
   route.append(CLLocation(latitude:47.34028, longitude:-121.35845))
     
   
   route.append(CLLocation(latitude:47.34027, longitude:-121.35819))
     
   
   route.append(CLLocation(latitude:47.34027, longitude:-121.35753))
     
   
   route.append(CLLocation(latitude:47.34025, longitude:-121.35627))
     
   
   route.append(CLLocation(latitude:47.34025, longitude:-121.35593))
     
   
   route.append(CLLocation(latitude:47.34024, longitude:-121.35561))
     
   
   route.append(CLLocation(latitude:47.34024, longitude:-121.35541))
     
   
   route.append(CLLocation(latitude:47.34023, longitude:-121.35534))
     
   
   route.append(CLLocation(latitude:47.34023, longitude:-121.35525))
     
   
   route.append(CLLocation(latitude:47.34022, longitude:-121.35505))
     
   
   route.append(CLLocation(latitude:47.3402, longitude:-121.35491))
     
   
   route.append(CLLocation(latitude:47.34018, longitude:-121.35474))
     
   
   route.append(CLLocation(latitude:47.34016, longitude:-121.35455))
     
   
   route.append(CLLocation(latitude:47.34013, longitude:-121.35435))
     
   
   route.append(CLLocation(latitude:47.3401, longitude:-121.3542))
     
   
   route.append(CLLocation(latitude:47.34008, longitude:-121.35407))
     
   
   route.append(CLLocation(latitude:47.34005, longitude:-121.35393))
     
   
   route.append(CLLocation(latitude:47.34, longitude:-121.35372))
     
   
   route.append(CLLocation(latitude:47.33992, longitude:-121.35342))
     
   
   route.append(CLLocation(latitude:47.33983, longitude:-121.35311))
     
   
   route.append(CLLocation(latitude:47.33976, longitude:-121.35291))
     
   
   route.append(CLLocation(latitude:47.33968, longitude:-121.35271))
     
   
   route.append(CLLocation(latitude:47.33962, longitude:-121.35255))
     
   
   route.append(CLLocation(latitude:47.33951, longitude:-121.35231))
     
   
   route.append(CLLocation(latitude:47.33944, longitude:-121.35216))
     
   
   route.append(CLLocation(latitude:47.33932, longitude:-121.35192))
     
   
   route.append(CLLocation(latitude:47.33925, longitude:-121.35178))
     
   
   route.append(CLLocation(latitude:47.33918, longitude:-121.35167))
     
   
   route.append(CLLocation(latitude:47.33909, longitude:-121.35154))
     
   
   route.append(CLLocation(latitude:47.33898, longitude:-121.35137))
     
   
   route.append(CLLocation(latitude:47.33885, longitude:-121.35119))
     
   
   route.append(CLLocation(latitude:47.33864, longitude:-121.35092))
     
   
   route.append(CLLocation(latitude:47.33854, longitude:-121.35081))
     
   
   route.append(CLLocation(latitude:47.33843, longitude:-121.35069))
     
   
   route.append(CLLocation(latitude:47.33793, longitude:-121.35021))
     
   
   route.append(CLLocation(latitude:47.33742, longitude:-121.34966))
     
   
   route.append(CLLocation(latitude:47.3372, longitude:-121.34944))
     
   
   route.append(CLLocation(latitude:47.33693, longitude:-121.34915))
     
   
   route.append(CLLocation(latitude:47.33607, longitude:-121.34821))
     
   
   route.append(CLLocation(latitude:47.33589, longitude:-121.34803))
     
   
   route.append(CLLocation(latitude:47.33556, longitude:-121.34769))
     
   
   route.append(CLLocation(latitude:47.33536, longitude:-121.3475))
     
   
   route.append(CLLocation(latitude:47.33522, longitude:-121.34737))
     
   
   route.append(CLLocation(latitude:47.33508, longitude:-121.34723))
     
   
   route.append(CLLocation(latitude:47.3349, longitude:-121.34707))
     
   
   route.append(CLLocation(latitude:47.33467, longitude:-121.34688))
     
   
   route.append(CLLocation(latitude:47.33447, longitude:-121.34673))
     
   
   route.append(CLLocation(latitude:47.3342, longitude:-121.34655))
     
   
   route.append(CLLocation(latitude:47.33399, longitude:-121.34641))
     
   
   route.append(CLLocation(latitude:47.33376, longitude:-121.34627))
     
   
   route.append(CLLocation(latitude:47.33358, longitude:-121.34617))
     
   
   route.append(CLLocation(latitude:47.33341, longitude:-121.34608))
     
   
   route.append(CLLocation(latitude:47.3331, longitude:-121.34592))
     
   
   route.append(CLLocation(latitude:47.33277, longitude:-121.34575))
     
   
   route.append(CLLocation(latitude:47.33245, longitude:-121.34558))
     
   
   route.append(CLLocation(latitude:47.33231, longitude:-121.34551))
     
   
   route.append(CLLocation(latitude:47.33221, longitude:-121.34545))
     
   
   route.append(CLLocation(latitude:47.33209, longitude:-121.34536))
     
   
   route.append(CLLocation(latitude:47.33197, longitude:-121.34528))
     
   
   route.append(CLLocation(latitude:47.33193, longitude:-121.34525))
     
   
   route.append(CLLocation(latitude:47.33177, longitude:-121.34515))
     
   
   route.append(CLLocation(latitude:47.33169, longitude:-121.34508))
     
   
   route.append(CLLocation(latitude:47.33162, longitude:-121.34502))
     
   
   route.append(CLLocation(latitude:47.33154, longitude:-121.34494))
     
   
   route.append(CLLocation(latitude:47.33145, longitude:-121.34485))
     
   
   route.append(CLLocation(latitude:47.33117, longitude:-121.34456))
     
   
   route.append(CLLocation(latitude:47.33105, longitude:-121.34441))
     
   
   route.append(CLLocation(latitude:47.33095, longitude:-121.34428))
     
   
   route.append(CLLocation(latitude:47.33086, longitude:-121.34415))
     
   
   route.append(CLLocation(latitude:47.3307, longitude:-121.34391))
     
   
   route.append(CLLocation(latitude:47.33055, longitude:-121.34366))
     
   
   route.append(CLLocation(latitude:47.33044, longitude:-121.34343))
     
   
   route.append(CLLocation(latitude:47.33034, longitude:-121.34322))
     
   
   route.append(CLLocation(latitude:47.33026, longitude:-121.34304))
     
   
   route.append(CLLocation(latitude:47.33004, longitude:-121.34253))
     
   
   route.append(CLLocation(latitude:47.32979, longitude:-121.3419))
     
   
   route.append(CLLocation(latitude:47.32948, longitude:-121.34113))
     
   
   route.append(CLLocation(latitude:47.32897, longitude:-121.33984))
     
   
   route.append(CLLocation(latitude:47.32871, longitude:-121.33918))
     
   
   route.append(CLLocation(latitude:47.32865, longitude:-121.33902))
     
   
   route.append(CLLocation(latitude:47.32854, longitude:-121.33877))
     
   
   route.append(CLLocation(latitude:47.32847, longitude:-121.33858))
     
   
   route.append(CLLocation(latitude:47.32838, longitude:-121.33835))
     
   
   route.append(CLLocation(latitude:47.32831, longitude:-121.33817))
     
   
   route.append(CLLocation(latitude:47.32825, longitude:-121.338))
     
   
   route.append(CLLocation(latitude:47.32819, longitude:-121.33784))
     
   
   route.append(CLLocation(latitude:47.32814, longitude:-121.3377))
     
   
   route.append(CLLocation(latitude:47.32808, longitude:-121.33753))
     
   
   route.append(CLLocation(latitude:47.32803, longitude:-121.33737))
     
   
   route.append(CLLocation(latitude:47.32797, longitude:-121.33716))
     
   
   route.append(CLLocation(latitude:47.3279, longitude:-121.3369))
     
   
   route.append(CLLocation(latitude:47.32784, longitude:-121.33669))
     
   
   route.append(CLLocation(latitude:47.32778, longitude:-121.33644))
     
   
   route.append(CLLocation(latitude:47.32769, longitude:-121.33609))
     
   
   route.append(CLLocation(latitude:47.32753, longitude:-121.33545))
     
   
   route.append(CLLocation(latitude:47.32737, longitude:-121.33479))
     
   
   route.append(CLLocation(latitude:47.32711, longitude:-121.33373))
     
   
   route.append(CLLocation(latitude:47.32681, longitude:-121.33255))
     
   
   route.append(CLLocation(latitude:47.32676, longitude:-121.33236))
     
   
   route.append(CLLocation(latitude:47.32669, longitude:-121.33211))
     
   
   route.append(CLLocation(latitude:47.32663, longitude:-121.3319))
     
   
   route.append(CLLocation(latitude:47.32657, longitude:-121.3317))
     
   
   route.append(CLLocation(latitude:47.3265, longitude:-121.33146))
     
   
   route.append(CLLocation(latitude:47.32643, longitude:-121.33126))
     
   
   route.append(CLLocation(latitude:47.32633, longitude:-121.33099))
     
   
   route.append(CLLocation(latitude:47.32623, longitude:-121.33072))
     
   
   route.append(CLLocation(latitude:47.32616, longitude:-121.33054))
     
   
   route.append(CLLocation(latitude:47.32607, longitude:-121.33031))
     
   
   route.append(CLLocation(latitude:47.32597, longitude:-121.3301))
     
   
   route.append(CLLocation(latitude:47.32586, longitude:-121.32984))
     
   
   route.append(CLLocation(latitude:47.32574, longitude:-121.32961))
     
   
   route.append(CLLocation(latitude:47.32564, longitude:-121.3294))
     
   
   route.append(CLLocation(latitude:47.32552, longitude:-121.32919))
     
   
   route.append(CLLocation(latitude:47.32539, longitude:-121.32895))
     
   
   route.append(CLLocation(latitude:47.32516, longitude:-121.32857))
     
   
   route.append(CLLocation(latitude:47.325, longitude:-121.32834))
     
   
   route.append(CLLocation(latitude:47.32482, longitude:-121.32808))
     
   
   route.append(CLLocation(latitude:47.32468, longitude:-121.32788))
     
   
   route.append(CLLocation(latitude:47.32431, longitude:-121.32742))
     
   
   route.append(CLLocation(latitude:47.3241, longitude:-121.32718))
     
   
   route.append(CLLocation(latitude:47.32056, longitude:-121.32305))
     
   
   route.append(CLLocation(latitude:47.31997, longitude:-121.32235))
     
   
   route.append(CLLocation(latitude:47.31912, longitude:-121.32137))
     
   
   route.append(CLLocation(latitude:47.31721, longitude:-121.31914))
     
   
   route.append(CLLocation(latitude:47.31675, longitude:-121.3186))
     
   
   route.append(CLLocation(latitude:47.31602, longitude:-121.31776))
     
   
   route.append(CLLocation(latitude:47.31497, longitude:-121.31653))
     
   
   route.append(CLLocation(latitude:47.31462, longitude:-121.31613))
     
   
   route.append(CLLocation(latitude:47.31441, longitude:-121.3159))
     
   
   route.append(CLLocation(latitude:47.31422, longitude:-121.3157))
     
   
   route.append(CLLocation(latitude:47.31405, longitude:-121.31553))
     
   
   route.append(CLLocation(latitude:47.31394, longitude:-121.31542))
     
   
   route.append(CLLocation(latitude:47.31374, longitude:-121.31525))
     
   
   route.append(CLLocation(latitude:47.31364, longitude:-121.31515))
     
   
   route.append(CLLocation(latitude:47.31348, longitude:-121.31503))
     
   
   route.append(CLLocation(latitude:47.31335, longitude:-121.31493))
     
   
   route.append(CLLocation(latitude:47.31323, longitude:-121.31484))
     
   
   route.append(CLLocation(latitude:47.31301, longitude:-121.31469))
     
   
   route.append(CLLocation(latitude:47.31281, longitude:-121.31455))
     
   
   route.append(CLLocation(latitude:47.31259, longitude:-121.31441))
     
   
   route.append(CLLocation(latitude:47.31239, longitude:-121.31428))
     
   
   route.append(CLLocation(latitude:47.31212, longitude:-121.31411))
     
   
   route.append(CLLocation(latitude:47.31149, longitude:-121.31373))
     
   
   route.append(CLLocation(latitude:47.31055, longitude:-121.31316))
     
   
   route.append(CLLocation(latitude:47.31023, longitude:-121.31296))
     
   
   route.append(CLLocation(latitude:47.31014, longitude:-121.31291))
     
   
   route.append(CLLocation(latitude:47.31003, longitude:-121.31283))
     
   
   route.append(CLLocation(latitude:47.3099, longitude:-121.31275))
     
   
   route.append(CLLocation(latitude:47.3098, longitude:-121.31268))
     
   
   route.append(CLLocation(latitude:47.30969, longitude:-121.31261))
     
   
   route.append(CLLocation(latitude:47.3096, longitude:-121.31254))
     
   
   route.append(CLLocation(latitude:47.3095, longitude:-121.31246))
     
   
   route.append(CLLocation(latitude:47.30939, longitude:-121.31237))
     
   
   route.append(CLLocation(latitude:47.30929, longitude:-121.31227))
     
   
   route.append(CLLocation(latitude:47.30921, longitude:-121.31219))
     
   
   route.append(CLLocation(latitude:47.30908, longitude:-121.31206))
     
   
   route.append(CLLocation(latitude:47.30895, longitude:-121.3119))
     
   
   route.append(CLLocation(latitude:47.30884, longitude:-121.31176))
     
   
   route.append(CLLocation(latitude:47.30873, longitude:-121.3116))
     
   
   route.append(CLLocation(latitude:47.30859, longitude:-121.3114))
     
   
   route.append(CLLocation(latitude:47.30842, longitude:-121.31115))
     
   
   route.append(CLLocation(latitude:47.30813, longitude:-121.31073))
     
   
   route.append(CLLocation(latitude:47.30785, longitude:-121.31031))
     
   
   route.append(CLLocation(latitude:47.3076, longitude:-121.30995))
     
   
   route.append(CLLocation(latitude:47.3069, longitude:-121.30894))
     
   
   route.append(CLLocation(latitude:47.3065, longitude:-121.30838))
     
   
   route.append(CLLocation(latitude:47.3062, longitude:-121.30794))
     
   
   route.append(CLLocation(latitude:47.30558, longitude:-121.30704))
     
   
   route.append(CLLocation(latitude:47.30474, longitude:-121.30582))
     
   
   route.append(CLLocation(latitude:47.30276, longitude:-121.30293))
     
   
   route.append(CLLocation(latitude:47.30235, longitude:-121.30231))
     
   
   route.append(CLLocation(latitude:47.30227, longitude:-121.30219))
     
   
   route.append(CLLocation(latitude:47.30213, longitude:-121.30198))
     
   
   route.append(CLLocation(latitude:47.30206, longitude:-121.30187))
     
   
   route.append(CLLocation(latitude:47.30198, longitude:-121.30174))
     
   
   route.append(CLLocation(latitude:47.3019, longitude:-121.30161))
     
   
   route.append(CLLocation(latitude:47.30177, longitude:-121.30136))
     
   
   route.append(CLLocation(latitude:47.30161, longitude:-121.30105))
     
   
   route.append(CLLocation(latitude:47.30148, longitude:-121.30078))
     
   
   route.append(CLLocation(latitude:47.30136, longitude:-121.30048))
     
   
   route.append(CLLocation(latitude:47.30125, longitude:-121.30019))
     
   
   route.append(CLLocation(latitude:47.30113, longitude:-121.29984))
     
   
   route.append(CLLocation(latitude:47.30108, longitude:-121.29965))
     
   
   route.append(CLLocation(latitude:47.30103, longitude:-121.29948))
     
   
   route.append(CLLocation(latitude:47.30096, longitude:-121.29924))
     
   
   route.append(CLLocation(latitude:47.30092, longitude:-121.29907))
     
   
   route.append(CLLocation(latitude:47.30085, longitude:-121.29872))
     
   
   route.append(CLLocation(latitude:47.30079, longitude:-121.29842))
     
   
   route.append(CLLocation(latitude:47.30072, longitude:-121.29808))
     
   
   route.append(CLLocation(latitude:47.30062, longitude:-121.29754))
     
   
   route.append(CLLocation(latitude:47.30055, longitude:-121.29718))
     
   
   route.append(CLLocation(latitude:47.30049, longitude:-121.29684))
     
   
   route.append(CLLocation(latitude:47.30043, longitude:-121.29652))
     
   
   route.append(CLLocation(latitude:47.30034, longitude:-121.29608))
     
   
   route.append(CLLocation(latitude:47.30027, longitude:-121.29572))
     
   
   route.append(CLLocation(latitude:47.30024, longitude:-121.29555))
     
   
   route.append(CLLocation(latitude:47.3002, longitude:-121.29536))
     
   
   route.append(CLLocation(latitude:47.30016, longitude:-121.29516))
     
   
   route.append(CLLocation(latitude:47.30008, longitude:-121.29479))
     
   
   route.append(CLLocation(latitude:47.3, longitude:-121.29446))
     
   
   route.append(CLLocation(latitude:47.29992, longitude:-121.29414))
     
   
   route.append(CLLocation(latitude:47.29986, longitude:-121.29391))
     
   
   route.append(CLLocation(latitude:47.29978, longitude:-121.29362))
     
   
   route.append(CLLocation(latitude:47.29966, longitude:-121.29325))
     
   
   route.append(CLLocation(latitude:47.29955, longitude:-121.2929))
     
   
   route.append(CLLocation(latitude:47.29944, longitude:-121.29257))
     
   
   route.append(CLLocation(latitude:47.29932, longitude:-121.29225))
     
   
   route.append(CLLocation(latitude:47.29919, longitude:-121.29193))
     
   
   route.append(CLLocation(latitude:47.29907, longitude:-121.29163))
     
   
   route.append(CLLocation(latitude:47.29895, longitude:-121.29134))
     
   
   route.append(CLLocation(latitude:47.29887, longitude:-121.29118))
     
   
   route.append(CLLocation(latitude:47.29874, longitude:-121.2909))
     
   
   route.append(CLLocation(latitude:47.29867, longitude:-121.29074))
     
   
   route.append(CLLocation(latitude:47.29859, longitude:-121.2906))
     
   
   route.append(CLLocation(latitude:47.29851, longitude:-121.29044))
     
   
   route.append(CLLocation(latitude:47.29836, longitude:-121.29015))
     
   
   route.append(CLLocation(latitude:47.29828, longitude:-121.28999))
     
   
   route.append(CLLocation(latitude:47.29809, longitude:-121.28968))
     
   
   route.append(CLLocation(latitude:47.29794, longitude:-121.28942))
     
   
   route.append(CLLocation(latitude:47.29785, longitude:-121.28927))
     
   
   route.append(CLLocation(latitude:47.29768, longitude:-121.28901))
     
   
   route.append(CLLocation(latitude:47.29751, longitude:-121.28874))
     
   
   route.append(CLLocation(latitude:47.29742, longitude:-121.28863))
     
   
   route.append(CLLocation(latitude:47.29726, longitude:-121.2884))
     
   
   route.append(CLLocation(latitude:47.2971, longitude:-121.28819))
     
   
   route.append(CLLocation(latitude:47.297, longitude:-121.28806))
     
   
   route.append(CLLocation(latitude:47.29682, longitude:-121.28784))
     
   
   route.append(CLLocation(latitude:47.29672, longitude:-121.28772))
     
   
   route.append(CLLocation(latitude:47.29653, longitude:-121.2875))
     
   
   route.append(CLLocation(latitude:47.29634, longitude:-121.28729))
     
   
   route.append(CLLocation(latitude:47.29624, longitude:-121.28719))
     
   
   route.append(CLLocation(latitude:47.29614, longitude:-121.28708))
     
   
   route.append(CLLocation(latitude:47.29603, longitude:-121.28698))
     
   
   route.append(CLLocation(latitude:47.29592, longitude:-121.28686))
     
   
   route.append(CLLocation(latitude:47.2958, longitude:-121.28676))
     
   
   route.append(CLLocation(latitude:47.29559, longitude:-121.28656))
     
   
   route.append(CLLocation(latitude:47.29548, longitude:-121.28646))
     
   
   route.append(CLLocation(latitude:47.29528, longitude:-121.2863))
     
   
   route.append(CLLocation(latitude:47.29516, longitude:-121.2862))
     
   
   route.append(CLLocation(latitude:47.29505, longitude:-121.28611))
     
   
   route.append(CLLocation(latitude:47.29495, longitude:-121.28603))
     
   
   route.append(CLLocation(latitude:47.29483, longitude:-121.28595))
     
   
   route.append(CLLocation(latitude:47.29472, longitude:-121.28587))
     
   
   route.append(CLLocation(latitude:47.29461, longitude:-121.28579))
     
   
   route.append(CLLocation(latitude:47.29456, longitude:-121.28576))
     
   
   route.append(CLLocation(latitude:47.29449, longitude:-121.28571))
     
   
   route.append(CLLocation(latitude:47.29437, longitude:-121.28564))
     
   
   route.append(CLLocation(latitude:47.29421, longitude:-121.28555))
     
   
   route.append(CLLocation(latitude:47.2941, longitude:-121.28549))
     
   
   route.append(CLLocation(latitude:47.29398, longitude:-121.28542))
     
   
   route.append(CLLocation(latitude:47.29387, longitude:-121.28535))
     
   
   route.append(CLLocation(latitude:47.29362, longitude:-121.28522))
     
   
   route.append(CLLocation(latitude:47.2934, longitude:-121.2851))
     
   
   route.append(CLLocation(latitude:47.29309, longitude:-121.28494))
     
   
   route.append(CLLocation(latitude:47.29288, longitude:-121.28483))
     
   
   route.append(CLLocation(latitude:47.29257, longitude:-121.28466))
     
   
   route.append(CLLocation(latitude:47.29226, longitude:-121.2845))
     
   
   route.append(CLLocation(latitude:47.29204, longitude:-121.28438))
     
   
   route.append(CLLocation(latitude:47.29174, longitude:-121.28423))
     
   
   route.append(CLLocation(latitude:47.29154, longitude:-121.28412))
     
   
   route.append(CLLocation(latitude:47.29122, longitude:-121.28395))
     
   
   route.append(CLLocation(latitude:47.29102, longitude:-121.28384))
     
   
   route.append(CLLocation(latitude:47.29092, longitude:-121.2838))
     
   
   route.append(CLLocation(latitude:47.29059, longitude:-121.28362))
     
   
   route.append(CLLocation(latitude:47.29039, longitude:-121.28351))
     
   
   route.append(CLLocation(latitude:47.29009, longitude:-121.28335))
     
   
   route.append(CLLocation(latitude:47.28987, longitude:-121.28324))
     
   
   route.append(CLLocation(latitude:47.28967, longitude:-121.28314))
     
   
   route.append(CLLocation(latitude:47.28946, longitude:-121.28304))
     
   
   route.append(CLLocation(latitude:47.28935, longitude:-121.283))
     
   
   route.append(CLLocation(latitude:47.28915, longitude:-121.28292))
     
   
   route.append(CLLocation(latitude:47.28904, longitude:-121.28289))
     
   
   route.append(CLLocation(latitude:47.28893, longitude:-121.28286))
     
   
   route.append(CLLocation(latitude:47.28883, longitude:-121.28283))
     
   
   route.append(CLLocation(latitude:47.28872, longitude:-121.2828))
     
   
   route.append(CLLocation(latitude:47.28861, longitude:-121.28278))
     
   
   route.append(CLLocation(latitude:47.2885, longitude:-121.28276))
     
   
   route.append(CLLocation(latitude:47.28846, longitude:-121.28275))
     
   
   route.append(CLLocation(latitude:47.28829, longitude:-121.28273))
     
   
   route.append(CLLocation(latitude:47.28807, longitude:-121.2827))
     
   
   route.append(CLLocation(latitude:47.28796, longitude:-121.28269))
     
   
   route.append(CLLocation(latitude:47.28773, longitude:-121.28268))
     
   
   route.append(CLLocation(latitude:47.28752, longitude:-121.28266))
     
   
   route.append(CLLocation(latitude:47.28729, longitude:-121.28264))
     
   
   route.append(CLLocation(latitude:47.28707, longitude:-121.28263))
     
   
   route.append(CLLocation(latitude:47.28685, longitude:-121.28261))
     
   
   route.append(CLLocation(latitude:47.28675, longitude:-121.2826))
     
   
   route.append(CLLocation(latitude:47.28663, longitude:-121.28259))
     
   
   route.append(CLLocation(latitude:47.28653, longitude:-121.28257))
     
   
   route.append(CLLocation(latitude:47.28642, longitude:-121.28255))
     
   
   route.append(CLLocation(latitude:47.2863, longitude:-121.28253))
     
   
   route.append(CLLocation(latitude:47.28619, longitude:-121.2825))
     
   
   route.append(CLLocation(latitude:47.28609, longitude:-121.28248))
     
   
   route.append(CLLocation(latitude:47.28598, longitude:-121.28245))
     
   
   route.append(CLLocation(latitude:47.28586, longitude:-121.28241))
     
   
   route.append(CLLocation(latitude:47.28576, longitude:-121.28238))
     
   
   route.append(CLLocation(latitude:47.28565, longitude:-121.28233))
     
   
   route.append(CLLocation(latitude:47.28555, longitude:-121.28229))
     
   
   route.append(CLLocation(latitude:47.28544, longitude:-121.28225))
     
   
   route.append(CLLocation(latitude:47.28534, longitude:-121.2822))
     
   
   route.append(CLLocation(latitude:47.28523, longitude:-121.28215))
     
   
   route.append(CLLocation(latitude:47.28513, longitude:-121.2821))
     
   
   route.append(CLLocation(latitude:47.28502, longitude:-121.28205))
     
   
   route.append(CLLocation(latitude:47.28492, longitude:-121.282))
     
   
   route.append(CLLocation(latitude:47.28471, longitude:-121.28189))
     
   
   route.append(CLLocation(latitude:47.28451, longitude:-121.2818))
     
   
   route.append(CLLocation(latitude:47.2844, longitude:-121.28175))
     
   
   route.append(CLLocation(latitude:47.28419, longitude:-121.28164))
     
   
   route.append(CLLocation(latitude:47.28408, longitude:-121.28159))
     
   
   route.append(CLLocation(latitude:47.28398, longitude:-121.28154))
     
   
   route.append(CLLocation(latitude:47.28387, longitude:-121.28149))
     
   
   route.append(CLLocation(latitude:47.28377, longitude:-121.28145))
     
   
   route.append(CLLocation(latitude:47.28355, longitude:-121.28136))
     
   
   route.append(CLLocation(latitude:47.28345, longitude:-121.28132))
     
   
   route.append(CLLocation(latitude:47.28334, longitude:-121.28129))
     
   
   route.append(CLLocation(latitude:47.28324, longitude:-121.28126))
     
   
   route.append(CLLocation(latitude:47.28314, longitude:-121.28123))
     
   
   route.append(CLLocation(latitude:47.28302, longitude:-121.2812))
     
   
   route.append(CLLocation(latitude:47.28291, longitude:-121.28118))
     
   
   route.append(CLLocation(latitude:47.28281, longitude:-121.28116))
     
   
   route.append(CLLocation(latitude:47.2827, longitude:-121.28114))
     
   
   route.append(CLLocation(latitude:47.28259, longitude:-121.28113))
     
   
   route.append(CLLocation(latitude:47.28248, longitude:-121.28112))
     
   
   route.append(CLLocation(latitude:47.28237, longitude:-121.28111))
     
   
   route.append(CLLocation(latitude:47.28227, longitude:-121.2811))
     
   
   route.append(CLLocation(latitude:47.28206, longitude:-121.28109))
     
   
   route.append(CLLocation(latitude:47.28194, longitude:-121.28108))
     
   
   route.append(CLLocation(latitude:47.28172, longitude:-121.28107))
     
   
   route.append(CLLocation(latitude:47.28161, longitude:-121.28106))
     
   
   route.append(CLLocation(latitude:47.2814, longitude:-121.28105))
     
   
   route.append(CLLocation(latitude:47.28129, longitude:-121.28104))
     
   
   route.append(CLLocation(latitude:47.28107, longitude:-121.28103))
     
   
   route.append(CLLocation(latitude:47.28085, longitude:-121.28101))
     
   
   route.append(CLLocation(latitude:47.28074, longitude:-121.28099))
     
   
   route.append(CLLocation(latitude:47.28064, longitude:-121.28098))
     
   
   route.append(CLLocation(latitude:47.28051, longitude:-121.28096))
     
   
   route.append(CLLocation(latitude:47.2803, longitude:-121.28091))
     
   
   route.append(CLLocation(latitude:47.28019, longitude:-121.28088))
     
   
   route.append(CLLocation(latitude:47.28009, longitude:-121.28085))
     
   
   route.append(CLLocation(latitude:47.27998, longitude:-121.28081))
     
   
   route.append(CLLocation(latitude:47.27987, longitude:-121.28077))
     
   
   route.append(CLLocation(latitude:47.27965, longitude:-121.28068))
     
   
   route.append(CLLocation(latitude:47.27945, longitude:-121.28057))
     
   
   route.append(CLLocation(latitude:47.27934, longitude:-121.28051))
     
   
   route.append(CLLocation(latitude:47.27914, longitude:-121.28037))
     
   
   route.append(CLLocation(latitude:47.27904, longitude:-121.28029))
     
   
   route.append(CLLocation(latitude:47.27896, longitude:-121.28023))
     
   
   route.append(CLLocation(latitude:47.27886, longitude:-121.28015))
     
   
   route.append(CLLocation(latitude:47.27876, longitude:-121.28006))
     
   
   route.append(CLLocation(latitude:47.27867, longitude:-121.27997))
     
   
   route.append(CLLocation(latitude:47.27858, longitude:-121.27988))
     
   
   route.append(CLLocation(latitude:47.27848, longitude:-121.27978))
     
   
   route.append(CLLocation(latitude:47.27839, longitude:-121.27967))
     
   
   route.append(CLLocation(latitude:47.27831, longitude:-121.27958))
     
   
   route.append(CLLocation(latitude:47.27823, longitude:-121.27948))
     
   
   route.append(CLLocation(latitude:47.27814, longitude:-121.27938))
     
   
   route.append(CLLocation(latitude:47.27806, longitude:-121.27927))
     
   
   route.append(CLLocation(latitude:47.27798, longitude:-121.27917))
     
   
   route.append(CLLocation(latitude:47.27789, longitude:-121.27905))
     
   
   route.append(CLLocation(latitude:47.27781, longitude:-121.27895))
     
   
   route.append(CLLocation(latitude:47.27773, longitude:-121.27883))
     
   
   route.append(CLLocation(latitude:47.27765, longitude:-121.27873))
     
   
   route.append(CLLocation(latitude:47.27757, longitude:-121.27862))
     
   
   route.append(CLLocation(latitude:47.27748, longitude:-121.27851))
     
   
   route.append(CLLocation(latitude:47.2774, longitude:-121.27841))
     
   
   route.append(CLLocation(latitude:47.27724, longitude:-121.27819))
     
   
   route.append(CLLocation(latitude:47.27707, longitude:-121.27797))
     
   
   route.append(CLLocation(latitude:47.27691, longitude:-121.27775))
     
   
   route.append(CLLocation(latitude:47.27684, longitude:-121.27766))
     
   
   route.append(CLLocation(latitude:47.27674, longitude:-121.27752))
     
   
   route.append(CLLocation(latitude:47.27666, longitude:-121.27742))
     
   
   route.append(CLLocation(latitude:47.27656, longitude:-121.27728))
     
   
   route.append(CLLocation(latitude:47.27641, longitude:-121.27708))
     
   
   route.append(CLLocation(latitude:47.2763, longitude:-121.27694))
     
   
   route.append(CLLocation(latitude:47.27615, longitude:-121.27675))
     
   
   route.append(CLLocation(latitude:47.27599, longitude:-121.27654))
     
   
   route.append(CLLocation(latitude:47.27583, longitude:-121.27633))
     
   
   route.append(CLLocation(latitude:47.27568, longitude:-121.27612))
     
   
   route.append(CLLocation(latitude:47.27544, longitude:-121.27581))
     
   
   route.append(CLLocation(latitude:47.27527, longitude:-121.27559))
     
   
   route.append(CLLocation(latitude:47.27519, longitude:-121.27548))
     
   
   route.append(CLLocation(latitude:47.27504, longitude:-121.27528))
     
   
   route.append(CLLocation(latitude:47.27495, longitude:-121.27517))
     
   
   route.append(CLLocation(latitude:47.2748, longitude:-121.27496))
     
   
   route.append(CLLocation(latitude:47.27463, longitude:-121.27474))
     
   
   route.append(CLLocation(latitude:47.27447, longitude:-121.27453))
     
   
   route.append(CLLocation(latitude:47.27431, longitude:-121.27432))
     
   
   route.append(CLLocation(latitude:47.27383, longitude:-121.27368))
     
   
   route.append(CLLocation(latitude:47.27358, longitude:-121.27337))
     
   
   route.append(CLLocation(latitude:47.27334, longitude:-121.27305))
     
   
   route.append(CLLocation(latitude:47.27318, longitude:-121.27284))
     
   
   route.append(CLLocation(latitude:47.2731, longitude:-121.27273))
     
   
   route.append(CLLocation(latitude:47.27286, longitude:-121.27242))
     
   
   route.append(CLLocation(latitude:47.27262, longitude:-121.2721))
     
   
   route.append(CLLocation(latitude:47.27237, longitude:-121.27177))
     
   
   route.append(CLLocation(latitude:47.27213, longitude:-121.27145))
     
   
   route.append(CLLocation(latitude:47.2719, longitude:-121.27114))
     
   
   route.append(CLLocation(latitude:47.27181, longitude:-121.27102))
     
   
   route.append(CLLocation(latitude:47.27174, longitude:-121.27091))
     
   
   route.append(CLLocation(latitude:47.27166, longitude:-121.2708))
     
   
   route.append(CLLocation(latitude:47.27159, longitude:-121.27069))
     
   
   route.append(CLLocation(latitude:47.27151, longitude:-121.27056))
     
   
   route.append(CLLocation(latitude:47.27144, longitude:-121.27045))
     
   
   route.append(CLLocation(latitude:47.27138, longitude:-121.27033))
     
   
   route.append(CLLocation(latitude:47.27131, longitude:-121.2702))
     
   
   route.append(CLLocation(latitude:47.27125, longitude:-121.27007))
     
   
   route.append(CLLocation(latitude:47.27118, longitude:-121.26993))
     
   
   route.append(CLLocation(latitude:47.27113, longitude:-121.2698))
     
   
   route.append(CLLocation(latitude:47.27107, longitude:-121.26966))
     
   
   route.append(CLLocation(latitude:47.27101, longitude:-121.26953))
     
   
   route.append(CLLocation(latitude:47.27096, longitude:-121.26938))
     
   
   route.append(CLLocation(latitude:47.27091, longitude:-121.26924))
     
   
   route.append(CLLocation(latitude:47.27087, longitude:-121.2691))
     
   
   route.append(CLLocation(latitude:47.27082, longitude:-121.26896))
     
   
   route.append(CLLocation(latitude:47.27078, longitude:-121.26881))
     
   
   route.append(CLLocation(latitude:47.27074, longitude:-121.26866))
     
   
   route.append(CLLocation(latitude:47.27069, longitude:-121.26846))
     
   
   route.append(CLLocation(latitude:47.27062, longitude:-121.26821))
     
   
   route.append(CLLocation(latitude:47.27059, longitude:-121.26808))
     
   
   route.append(CLLocation(latitude:47.27055, longitude:-121.26791))
     
   
   route.append(CLLocation(latitude:47.27049, longitude:-121.26761))
     
   
   route.append(CLLocation(latitude:47.27039, longitude:-121.26716))
     
   
   route.append(CLLocation(latitude:47.27033, longitude:-121.26685))
     
   
   route.append(CLLocation(latitude:47.27023, longitude:-121.26641))
     
   
   route.append(CLLocation(latitude:47.2701, longitude:-121.26577))
     
   
   route.append(CLLocation(latitude:47.26991, longitude:-121.26486))
     
   
   route.append(CLLocation(latitude:47.26974, longitude:-121.26403))
     
   
   route.append(CLLocation(latitude:47.26959, longitude:-121.2633))
     
   
   route.append(CLLocation(latitude:47.26957, longitude:-121.26321))
     
   
   route.append(CLLocation(latitude:47.26929, longitude:-121.26187))
     
   
   route.append(CLLocation(latitude:47.269, longitude:-121.26048))
     
   
   route.append(CLLocation(latitude:47.26886, longitude:-121.25981))
     
   
   route.append(CLLocation(latitude:47.26878, longitude:-121.25941))
     
   
   route.append(CLLocation(latitude:47.26871, longitude:-121.25913))
     
   
   route.append(CLLocation(latitude:47.26864, longitude:-121.25884))
     
   
   route.append(CLLocation(latitude:47.2686, longitude:-121.25867))
     
   
   route.append(CLLocation(latitude:47.26856, longitude:-121.25848))
     
   
   route.append(CLLocation(latitude:47.26849, longitude:-121.25825))
     
   
   route.append(CLLocation(latitude:47.2684, longitude:-121.25792))
     
   
   route.append(CLLocation(latitude:47.26831, longitude:-121.2576))
     
   
   route.append(CLLocation(latitude:47.26823, longitude:-121.25732))
     
   
   route.append(CLLocation(latitude:47.26816, longitude:-121.25704))
     
   
   route.append(CLLocation(latitude:47.26802, longitude:-121.25654))
     
   
   route.append(CLLocation(latitude:47.26788, longitude:-121.25603))
     
   
   route.append(CLLocation(latitude:47.26784, longitude:-121.25589))
     
   
   route.append(CLLocation(latitude:47.26776, longitude:-121.25561))
     
   
   route.append(CLLocation(latitude:47.26772, longitude:-121.25546))
     
   
   route.append(CLLocation(latitude:47.26768, longitude:-121.25529))
     
   
   route.append(CLLocation(latitude:47.26764, longitude:-121.25514))
     
   
   route.append(CLLocation(latitude:47.26761, longitude:-121.255))
     
   
   route.append(CLLocation(latitude:47.26759, longitude:-121.25485))
     
   
   route.append(CLLocation(latitude:47.26756, longitude:-121.25469))
     
   
   route.append(CLLocation(latitude:47.26753, longitude:-121.25454))
     
   
   route.append(CLLocation(latitude:47.26751, longitude:-121.25438))
     
   
   route.append(CLLocation(latitude:47.26749, longitude:-121.25423))
     
   
   route.append(CLLocation(latitude:47.26748, longitude:-121.25407))
     
   
   route.append(CLLocation(latitude:47.26747, longitude:-121.25391))
     
   
   route.append(CLLocation(latitude:47.26746, longitude:-121.25374))
     
   
   route.append(CLLocation(latitude:47.26746, longitude:-121.25358))
     
   
   route.append(CLLocation(latitude:47.26746, longitude:-121.25343))
     
   
   route.append(CLLocation(latitude:47.26746, longitude:-121.25325))
     
   
   route.append(CLLocation(latitude:47.26747, longitude:-121.2531))
     
   
   route.append(CLLocation(latitude:47.26748, longitude:-121.25294))
     
   
   route.append(CLLocation(latitude:47.26749, longitude:-121.2528))
     
   
   route.append(CLLocation(latitude:47.26751, longitude:-121.25264))
     
   
   route.append(CLLocation(latitude:47.26753, longitude:-121.25248))
     
   
   route.append(CLLocation(latitude:47.26755, longitude:-121.25232))
     
   
   route.append(CLLocation(latitude:47.26758, longitude:-121.25217))
     
   
   route.append(CLLocation(latitude:47.26761, longitude:-121.25202))
     
   
   route.append(CLLocation(latitude:47.26765, longitude:-121.25185))
     
   
   route.append(CLLocation(latitude:47.26769, longitude:-121.25168))
     
   
   route.append(CLLocation(latitude:47.26772, longitude:-121.25154))
     
   
   route.append(CLLocation(latitude:47.26776, longitude:-121.25138))
     
   
   route.append(CLLocation(latitude:47.26782, longitude:-121.25117))
     
   
   route.append(CLLocation(latitude:47.26793, longitude:-121.25079))
     
   
   route.append(CLLocation(latitude:47.26836, longitude:-121.24933))
     
   
   route.append(CLLocation(latitude:47.26839, longitude:-121.24921))
     
   
   route.append(CLLocation(latitude:47.26846, longitude:-121.24891))
     
   
   route.append(CLLocation(latitude:47.2685, longitude:-121.24876))
     
   
   route.append(CLLocation(latitude:47.26853, longitude:-121.24861))
     
   
   route.append(CLLocation(latitude:47.26856, longitude:-121.24846))
     
   
   route.append(CLLocation(latitude:47.26858, longitude:-121.2483))
     
   
   route.append(CLLocation(latitude:47.26861, longitude:-121.24815))
     
   
   route.append(CLLocation(latitude:47.26863, longitude:-121.24799))
     
   
   route.append(CLLocation(latitude:47.26866, longitude:-121.24767))
     
   
   route.append(CLLocation(latitude:47.26867, longitude:-121.24752))
     
   
   route.append(CLLocation(latitude:47.26867, longitude:-121.24736))
     
   
   route.append(CLLocation(latitude:47.26868, longitude:-121.2472))
     
   
   route.append(CLLocation(latitude:47.26868, longitude:-121.24705))
     
   
   route.append(CLLocation(latitude:47.26868, longitude:-121.24689))
     
   
   route.append(CLLocation(latitude:47.26868, longitude:-121.24673))
     
   
   route.append(CLLocation(latitude:47.26867, longitude:-121.24657))
     
   
   route.append(CLLocation(latitude:47.26865, longitude:-121.24611))
     
   
   route.append(CLLocation(latitude:47.26862, longitude:-121.24562))
     
   
   route.append(CLLocation(latitude:47.26861, longitude:-121.24531))
     
   
   route.append(CLLocation(latitude:47.26859, longitude:-121.24498))
     
   
   route.append(CLLocation(latitude:47.26855, longitude:-121.24419))
     
   
   route.append(CLLocation(latitude:47.26854, longitude:-121.24388))
     
   
   route.append(CLLocation(latitude:47.26853, longitude:-121.24356))
     
   
   route.append(CLLocation(latitude:47.26851, longitude:-121.24324))
     
   
   route.append(CLLocation(latitude:47.26849, longitude:-121.24292))
     
   
   route.append(CLLocation(latitude:47.26849, longitude:-121.24276))
     
   
   route.append(CLLocation(latitude:47.26846, longitude:-121.24228))
     
   
   route.append(CLLocation(latitude:47.26845, longitude:-121.24213))
     
   
   route.append(CLLocation(latitude:47.26843, longitude:-121.2418))
     
   
   route.append(CLLocation(latitude:47.26842, longitude:-121.24168))
     
   
   route.append(CLLocation(latitude:47.26841, longitude:-121.2415))
     
   
   route.append(CLLocation(latitude:47.2684, longitude:-121.24133))
     
   
   route.append(CLLocation(latitude:47.26836, longitude:-121.24086))
     
   
   route.append(CLLocation(latitude:47.26835, longitude:-121.2407))
     
   
   route.append(CLLocation(latitude:47.26832, longitude:-121.24039))
     
   
   route.append(CLLocation(latitude:47.26829, longitude:-121.24006))
     
   
   route.append(CLLocation(latitude:47.26826, longitude:-121.23973))
     
   
   route.append(CLLocation(latitude:47.26822, longitude:-121.23942))
     
   
   route.append(CLLocation(latitude:47.2682, longitude:-121.23926))
     
   
   route.append(CLLocation(latitude:47.26814, longitude:-121.23878))
     
   
   route.append(CLLocation(latitude:47.26812, longitude:-121.23863))
     
   
   route.append(CLLocation(latitude:47.26807, longitude:-121.23832))
     
   
   route.append(CLLocation(latitude:47.26806, longitude:-121.23824))
     
   
   route.append(CLLocation(latitude:47.26802, longitude:-121.23801))
     
   
   route.append(CLLocation(latitude:47.26799, longitude:-121.23785))
     
   
   route.append(CLLocation(latitude:47.26797, longitude:-121.23769))
     
   
   route.append(CLLocation(latitude:47.26794, longitude:-121.23754))
     
   
   route.append(CLLocation(latitude:47.26791, longitude:-121.23738))
     
   
   route.append(CLLocation(latitude:47.26788, longitude:-121.23723))
     
   
   route.append(CLLocation(latitude:47.26783, longitude:-121.23694))
     
   
   route.append(CLLocation(latitude:47.26776, longitude:-121.23662))
     
   
   route.append(CLLocation(latitude:47.26773, longitude:-121.23647))
     
   
   route.append(CLLocation(latitude:47.26766, longitude:-121.23617))
     
   
   route.append(CLLocation(latitude:47.26763, longitude:-121.23602))
     
   
   route.append(CLLocation(latitude:47.26759, longitude:-121.23586))
     
   
   route.append(CLLocation(latitude:47.26756, longitude:-121.23571))
     
   
   route.append(CLLocation(latitude:47.26749, longitude:-121.23541))
     
   
   route.append(CLLocation(latitude:47.26745, longitude:-121.23525))
     
   
   route.append(CLLocation(latitude:47.26737, longitude:-121.23496))
     
   
   route.append(CLLocation(latitude:47.26729, longitude:-121.23466))
     
   
   route.append(CLLocation(latitude:47.26721, longitude:-121.23436))
     
   
   route.append(CLLocation(latitude:47.26712, longitude:-121.23407))
     
   
   route.append(CLLocation(latitude:47.26704, longitude:-121.23377))
     
   
   route.append(CLLocation(latitude:47.26691, longitude:-121.23333))
     
   
   route.append(CLLocation(latitude:47.26682, longitude:-121.23303))
     
   
   route.append(CLLocation(latitude:47.26674, longitude:-121.23274))
     
   
   route.append(CLLocation(latitude:47.2667, longitude:-121.23259))
     
   
   route.append(CLLocation(latitude:47.26665, longitude:-121.23243))
     
   
   route.append(CLLocation(latitude:47.26661, longitude:-121.2323))
     
   
   route.append(CLLocation(latitude:47.26653, longitude:-121.232))
     
   
   route.append(CLLocation(latitude:47.26636, longitude:-121.23141))
     
   
   route.append(CLLocation(latitude:47.26623, longitude:-121.23095))
     
   
   route.append(CLLocation(latitude:47.26614, longitude:-121.23067))
     
   
   route.append(CLLocation(latitude:47.26606, longitude:-121.23037))
     
   
   route.append(CLLocation(latitude:47.26597, longitude:-121.23008))
     
   
   route.append(CLLocation(latitude:47.26593, longitude:-121.22993))
     
   
   route.append(CLLocation(latitude:47.26572, longitude:-121.22918))
     
   
   route.append(CLLocation(latitude:47.26559, longitude:-121.22874))
     
   
   route.append(CLLocation(latitude:47.2655, longitude:-121.22844))
     
   
   route.append(CLLocation(latitude:47.26542, longitude:-121.22815))
     
   
   route.append(CLLocation(latitude:47.26529, longitude:-121.2277))
     
   
   route.append(CLLocation(latitude:47.26521, longitude:-121.22741))
     
   
   route.append(CLLocation(latitude:47.26516, longitude:-121.22726))
     
   
   route.append(CLLocation(latitude:47.26512, longitude:-121.22712))
     
   
   route.append(CLLocation(latitude:47.26507, longitude:-121.22697))
     
   
   route.append(CLLocation(latitude:47.26503, longitude:-121.22683))
     
   
   route.append(CLLocation(latitude:47.26498, longitude:-121.22668))
     
   
   route.append(CLLocation(latitude:47.26494, longitude:-121.22654))
     
   
   route.append(CLLocation(latitude:47.26489, longitude:-121.22639))
     
   
   route.append(CLLocation(latitude:47.26484, longitude:-121.22624))
     
   
   route.append(CLLocation(latitude:47.26479, longitude:-121.2261))
     
   
   route.append(CLLocation(latitude:47.26474, longitude:-121.22595))
     
   
   route.append(CLLocation(latitude:47.26468, longitude:-121.2258))
     
   
   route.append(CLLocation(latitude:47.26463, longitude:-121.22567))
     
   
   route.append(CLLocation(latitude:47.26458, longitude:-121.22552))
     
   
   route.append(CLLocation(latitude:47.26452, longitude:-121.22538))
     
   
   route.append(CLLocation(latitude:47.26447, longitude:-121.22524))
     
   
   route.append(CLLocation(latitude:47.26442, longitude:-121.22511))
     
   
   route.append(CLLocation(latitude:47.26436, longitude:-121.22497))
     
   
   route.append(CLLocation(latitude:47.2643, longitude:-121.22483))
     
   
   route.append(CLLocation(latitude:47.26425, longitude:-121.22469))
     
   
   route.append(CLLocation(latitude:47.26419, longitude:-121.22456))
     
   
   route.append(CLLocation(latitude:47.26413, longitude:-121.22442))
     
   
   route.append(CLLocation(latitude:47.26407, longitude:-121.22428))
     
   
   route.append(CLLocation(latitude:47.26401, longitude:-121.22415))
     
   
   route.append(CLLocation(latitude:47.26395, longitude:-121.22402))
     
   
   route.append(CLLocation(latitude:47.26389, longitude:-121.22389))
     
   
   route.append(CLLocation(latitude:47.26383, longitude:-121.22376))
     
   
   route.append(CLLocation(latitude:47.26376, longitude:-121.22363))
     
   
   route.append(CLLocation(latitude:47.26363, longitude:-121.22337))
     
   
   route.append(CLLocation(latitude:47.26357, longitude:-121.22323))
     
   
   route.append(CLLocation(latitude:47.2635, longitude:-121.2231))
     
   
   route.append(CLLocation(latitude:47.26343, longitude:-121.22297))
     
   
   route.append(CLLocation(latitude:47.26337, longitude:-121.22285))
     
   
   route.append(CLLocation(latitude:47.2633, longitude:-121.22272))
     
   
   route.append(CLLocation(latitude:47.26323, longitude:-121.2226))
     
   
   route.append(CLLocation(latitude:47.26309, longitude:-121.22235))
     
   
   route.append(CLLocation(latitude:47.26302, longitude:-121.22223))
     
   
   route.append(CLLocation(latitude:47.26295, longitude:-121.2221))
     
   
   route.append(CLLocation(latitude:47.26281, longitude:-121.22188))
     
   
   route.append(CLLocation(latitude:47.26273, longitude:-121.22175))
     
   
   route.append(CLLocation(latitude:47.26258, longitude:-121.22152))
     
   
   route.append(CLLocation(latitude:47.26243, longitude:-121.22128))
     
   
   route.append(CLLocation(latitude:47.26228, longitude:-121.22106))
     
   
   route.append(CLLocation(latitude:47.26213, longitude:-121.22082))
     
   
   route.append(CLLocation(latitude:47.26198, longitude:-121.22058))
     
   
   route.append(CLLocation(latitude:47.26175, longitude:-121.22024))
     
   
   route.append(CLLocation(latitude:47.2616, longitude:-121.22))
     
   
   route.append(CLLocation(latitude:47.26153, longitude:-121.2199))
     
   
   route.append(CLLocation(latitude:47.26137, longitude:-121.21966))
     
   
   route.append(CLLocation(latitude:47.26122, longitude:-121.21943))
     
   
   route.append(CLLocation(latitude:47.26115, longitude:-121.21931))
     
   
   route.append(CLLocation(latitude:47.26062, longitude:-121.2185))
     
   
   route.append(CLLocation(latitude:47.26016, longitude:-121.2178))
     
   
   route.append(CLLocation(latitude:47.25986, longitude:-121.21734))
     
   
   route.append(CLLocation(latitude:47.25963, longitude:-121.21699))
     
   
   route.append(CLLocation(latitude:47.25956, longitude:-121.21688))
     
   
   route.append(CLLocation(latitude:47.25948, longitude:-121.21677))
     
   
   route.append(CLLocation(latitude:47.25941, longitude:-121.21664))
     
   
   route.append(CLLocation(latitude:47.25933, longitude:-121.21653))
     
   
   route.append(CLLocation(latitude:47.25926, longitude:-121.21641))
     
   
   route.append(CLLocation(latitude:47.25919, longitude:-121.2163))
     
   
   route.append(CLLocation(latitude:47.25912, longitude:-121.21617))
     
   
   route.append(CLLocation(latitude:47.25905, longitude:-121.21605))
     
   
   route.append(CLLocation(latitude:47.25898, longitude:-121.21593))
     
   
   route.append(CLLocation(latitude:47.25891, longitude:-121.21581))
     
   
   route.append(CLLocation(latitude:47.25884, longitude:-121.21568))
     
   
   route.append(CLLocation(latitude:47.25877, longitude:-121.21555))
     
   
   route.append(CLLocation(latitude:47.25871, longitude:-121.21543))
     
   
   route.append(CLLocation(latitude:47.25865, longitude:-121.2153))
     
   
   route.append(CLLocation(latitude:47.25858, longitude:-121.21516))
     
   
   route.append(CLLocation(latitude:47.25852, longitude:-121.21502))
     
   
   route.append(CLLocation(latitude:47.25846, longitude:-121.2149))
     
   
   route.append(CLLocation(latitude:47.2584, longitude:-121.21476))
     
   
   route.append(CLLocation(latitude:47.25834, longitude:-121.21463))
     
   
   route.append(CLLocation(latitude:47.25828, longitude:-121.21449))
     
   
   route.append(CLLocation(latitude:47.25823, longitude:-121.21436))
     
   
   route.append(CLLocation(latitude:47.25818, longitude:-121.21422))
     
   
   route.append(CLLocation(latitude:47.25812, longitude:-121.21407))
     
   
   route.append(CLLocation(latitude:47.25807, longitude:-121.21393))
     
   
   route.append(CLLocation(latitude:47.25802, longitude:-121.2138))
     
   
   route.append(CLLocation(latitude:47.25797, longitude:-121.21365))
     
   
   route.append(CLLocation(latitude:47.25793, longitude:-121.21351))
     
   
   route.append(CLLocation(latitude:47.25788, longitude:-121.21336))
     
   
   route.append(CLLocation(latitude:47.25783, longitude:-121.21321))
     
   
   route.append(CLLocation(latitude:47.25779, longitude:-121.21307))
     
   
   route.append(CLLocation(latitude:47.25774, longitude:-121.21292))
     
   
   route.append(CLLocation(latitude:47.2577, longitude:-121.21276))
     
   
   route.append(CLLocation(latitude:47.25766, longitude:-121.2126))
     
   
   route.append(CLLocation(latitude:47.25762, longitude:-121.21247))
     
   
   route.append(CLLocation(latitude:47.25758, longitude:-121.21232))
     
   
   route.append(CLLocation(latitude:47.25755, longitude:-121.21217))
     
   
   route.append(CLLocation(latitude:47.25748, longitude:-121.21186))
     
   
   route.append(CLLocation(latitude:47.25742, longitude:-121.21155))
     
   
   route.append(CLLocation(latitude:47.25739, longitude:-121.21141))
     
   
   route.append(CLLocation(latitude:47.25736, longitude:-121.21125))
     
   
   route.append(CLLocation(latitude:47.25734, longitude:-121.21109))
     
   
   route.append(CLLocation(latitude:47.25731, longitude:-121.21094))
     
   
   route.append(CLLocation(latitude:47.25729, longitude:-121.21078))
     
   
   route.append(CLLocation(latitude:47.25727, longitude:-121.21062))
     
   
   route.append(CLLocation(latitude:47.25725, longitude:-121.21047))
     
   
   route.append(CLLocation(latitude:47.25723, longitude:-121.2103))
     
   
   route.append(CLLocation(latitude:47.25721, longitude:-121.21015))
     
   
   route.append(CLLocation(latitude:47.25719, longitude:-121.20998))
     
   
   route.append(CLLocation(latitude:47.25716, longitude:-121.20966))
     
   
   route.append(CLLocation(latitude:47.25712, longitude:-121.20917))
     
   
   route.append(CLLocation(latitude:47.25706, longitude:-121.20854))
     
   
   route.append(CLLocation(latitude:47.257, longitude:-121.2079))
     
   
   route.append(CLLocation(latitude:47.25694, longitude:-121.20726))
     
   
   route.append(CLLocation(latitude:47.25687, longitude:-121.20647))
     
   
   route.append(CLLocation(latitude:47.25685, longitude:-121.20629))
     
   
   route.append(CLLocation(latitude:47.25681, longitude:-121.20583))
     
   
   route.append(CLLocation(latitude:47.25676, longitude:-121.20535))
     
   
   route.append(CLLocation(latitude:47.25672, longitude:-121.20488))
     
   
   route.append(CLLocation(latitude:47.25669, longitude:-121.20455))
     
   
   route.append(CLLocation(latitude:47.2566, longitude:-121.20361))
     
   
   route.append(CLLocation(latitude:47.25656, longitude:-121.20312))
     
   
   route.append(CLLocation(latitude:47.25655, longitude:-121.20306))
     
   
   route.append(CLLocation(latitude:47.25653, longitude:-121.2028))
     
   
   route.append(CLLocation(latitude:47.2565, longitude:-121.2025))
     
   
   route.append(CLLocation(latitude:47.25647, longitude:-121.20218))
     
   
   route.append(CLLocation(latitude:47.25642, longitude:-121.20169))
     
   
   route.append(CLLocation(latitude:47.25638, longitude:-121.20122))
     
   
   route.append(CLLocation(latitude:47.25636, longitude:-121.20106))
     
   
   route.append(CLLocation(latitude:47.25635, longitude:-121.2009))
     
   
   route.append(CLLocation(latitude:47.25633, longitude:-121.20074))
     
   
   route.append(CLLocation(latitude:47.25631, longitude:-121.20058))
     
   
   route.append(CLLocation(latitude:47.25629, longitude:-121.20043))
     
   
   route.append(CLLocation(latitude:47.25627, longitude:-121.20027))
     
   
   route.append(CLLocation(latitude:47.25624, longitude:-121.20011))
     
   
   route.append(CLLocation(latitude:47.25622, longitude:-121.19995))
     
   
   route.append(CLLocation(latitude:47.25619, longitude:-121.1998))
     
   
   route.append(CLLocation(latitude:47.25616, longitude:-121.19965))
     
   
   route.append(CLLocation(latitude:47.25613, longitude:-121.19949))
     
   
   route.append(CLLocation(latitude:47.2561, longitude:-121.19934))
     
   
   route.append(CLLocation(latitude:47.25606, longitude:-121.19918))
     
   
   route.append(CLLocation(latitude:47.25603, longitude:-121.19903))
     
   
   route.append(CLLocation(latitude:47.25595, longitude:-121.19874))
     
   
   route.append(CLLocation(latitude:47.25591, longitude:-121.19858))
     
   
   route.append(CLLocation(latitude:47.25587, longitude:-121.19844))
     
   
   route.append(CLLocation(latitude:47.25582, longitude:-121.19829))
     
   
   route.append(CLLocation(latitude:47.25578, longitude:-121.19814))
     
   
   route.append(CLLocation(latitude:47.25573, longitude:-121.198))
     
   
   route.append(CLLocation(latitude:47.25568, longitude:-121.19785))
     
   
   route.append(CLLocation(latitude:47.25564, longitude:-121.19771))
     
   
   route.append(CLLocation(latitude:47.25559, longitude:-121.19757))
     
   
   route.append(CLLocation(latitude:47.25553, longitude:-121.19742))
     
   
   route.append(CLLocation(latitude:47.25548, longitude:-121.19729))
     
   
   route.append(CLLocation(latitude:47.25543, longitude:-121.19715))
     
   
   route.append(CLLocation(latitude:47.25537, longitude:-121.19702))
     
   
   route.append(CLLocation(latitude:47.25531, longitude:-121.19689))
     
   
   route.append(CLLocation(latitude:47.25525, longitude:-121.19674))
     
   
   route.append(CLLocation(latitude:47.25519, longitude:-121.19662))
     
   
   route.append(CLLocation(latitude:47.25513, longitude:-121.19648))
     
   
   route.append(CLLocation(latitude:47.25507, longitude:-121.19636))
     
   
   route.append(CLLocation(latitude:47.255, longitude:-121.19623))
     
   
   route.append(CLLocation(latitude:47.25494, longitude:-121.1961))
     
   
   route.append(CLLocation(latitude:47.25487, longitude:-121.19597))
     
   
   route.append(CLLocation(latitude:47.2548, longitude:-121.19585))
     
   
   route.append(CLLocation(latitude:47.25474, longitude:-121.19574))
     
   
   route.append(CLLocation(latitude:47.25466, longitude:-121.19562))
     
   
   route.append(CLLocation(latitude:47.25464, longitude:-121.19558))
     
   
   route.append(CLLocation(latitude:47.25459, longitude:-121.1955))
     
   
   route.append(CLLocation(latitude:47.25451, longitude:-121.19538))
     
   
   route.append(CLLocation(latitude:47.25444, longitude:-121.19526))
     
   
   route.append(CLLocation(latitude:47.25437, longitude:-121.19515))
     
   
   route.append(CLLocation(latitude:47.25429, longitude:-121.19504))
     
   
   route.append(CLLocation(latitude:47.25421, longitude:-121.19492))
     
   
   route.append(CLLocation(latitude:47.25413, longitude:-121.19481))
     
   
   route.append(CLLocation(latitude:47.25405, longitude:-121.19471))
     
   
   route.append(CLLocation(latitude:47.25397, longitude:-121.1946))
     
   
   route.append(CLLocation(latitude:47.25389, longitude:-121.1945))
     
   
   route.append(CLLocation(latitude:47.2538, longitude:-121.1944))
     
   
   route.append(CLLocation(latitude:47.25372, longitude:-121.1943))
     
   
   route.append(CLLocation(latitude:47.25337, longitude:-121.1939))
     
   
   route.append(CLLocation(latitude:47.25321, longitude:-121.19371))
     
   
   route.append(CLLocation(latitude:47.25312, longitude:-121.19359))
     
   
   route.append(CLLocation(latitude:47.25297, longitude:-121.19342))
     
   
   route.append(CLLocation(latitude:47.25294, longitude:-121.19337))
     
   
   route.append(CLLocation(latitude:47.25203, longitude:-121.19231))
     
   
   route.append(CLLocation(latitude:47.25178, longitude:-121.19201))
     
   
   route.append(CLLocation(latitude:47.25153, longitude:-121.19171))
     
   
   route.append(CLLocation(latitude:47.25128, longitude:-121.19142))
     
   
   route.append(CLLocation(latitude:47.2511, longitude:-121.19121))
     
   
   route.append(CLLocation(latitude:47.25076, longitude:-121.19081))
     
   
   route.append(CLLocation(latitude:47.25059, longitude:-121.19061))
     
   
   route.append(CLLocation(latitude:47.25034, longitude:-121.19031))
     
   
   route.append(CLLocation(latitude:47.24992, longitude:-121.18982))
     
   
   route.append(CLLocation(latitude:47.2495, longitude:-121.18932))
     
   
   route.append(CLLocation(latitude:47.24917, longitude:-121.18892))
     
   
   route.append(CLLocation(latitude:47.24882, longitude:-121.18851))
     
   
   route.append(CLLocation(latitude:47.24857, longitude:-121.18822))
     
   
   route.append(CLLocation(latitude:47.24844, longitude:-121.18807))
     
   
   route.append(CLLocation(latitude:47.24798, longitude:-121.18753))
     
   
   route.append(CLLocation(latitude:47.24773, longitude:-121.18723))
     
   
   route.append(CLLocation(latitude:47.24748, longitude:-121.18694))
     
   
   route.append(CLLocation(latitude:47.24706, longitude:-121.18644))
     
   
   route.append(CLLocation(latitude:47.2468, longitude:-121.18614))
     
   
   route.append(CLLocation(latitude:47.24664, longitude:-121.18595))
     
   
   route.append(CLLocation(latitude:47.24648, longitude:-121.18576))
     
   
   route.append(CLLocation(latitude:47.24613, longitude:-121.18535))
     
   
   route.append(CLLocation(latitude:47.24605, longitude:-121.18525))
     
   
   route.append(CLLocation(latitude:47.24588, longitude:-121.18505))
     
   
   route.append(CLLocation(latitude:47.24579, longitude:-121.18495))
     
   
   route.append(CLLocation(latitude:47.24571, longitude:-121.18485))
     
   
   route.append(CLLocation(latitude:47.24546, longitude:-121.18455))
     
   
   route.append(CLLocation(latitude:47.24528, longitude:-121.18434))
     
   
   route.append(CLLocation(latitude:47.24361, longitude:-121.18236))
     
   
   route.append(CLLocation(latitude:47.24118, longitude:-121.1795))
     
   
   route.append(CLLocation(latitude:47.24042, longitude:-121.1786))
     
   
   route.append(CLLocation(latitude:47.23881, longitude:-121.1767))
     
   
   route.append(CLLocation(latitude:47.2375, longitude:-121.17517))
     
   
   route.append(CLLocation(latitude:47.23658, longitude:-121.1741))
     
   
   route.append(CLLocation(latitude:47.23598, longitude:-121.17333))
     
   
   route.append(CLLocation(latitude:47.23575, longitude:-121.17307))
     
   
   route.append(CLLocation(latitude:47.23473, longitude:-121.17186))
     
   
   route.append(CLLocation(latitude:47.23268, longitude:-121.16945))
     
   
   route.append(CLLocation(latitude:47.23193, longitude:-121.16857))
     
   
   route.append(CLLocation(latitude:47.23083, longitude:-121.16728))
     
   
   route.append(CLLocation(latitude:47.23007, longitude:-121.16639))
     
   
   route.append(CLLocation(latitude:47.22982, longitude:-121.16609))
     
   
   route.append(CLLocation(latitude:47.22965, longitude:-121.16588))
     
   
   route.append(CLLocation(latitude:47.22949, longitude:-121.16567))
     
   
   route.append(CLLocation(latitude:47.22933, longitude:-121.16545))
     
   
   route.append(CLLocation(latitude:47.22925, longitude:-121.16534))
     
   
   route.append(CLLocation(latitude:47.22918, longitude:-121.16524))
     
   
   route.append(CLLocation(latitude:47.2291, longitude:-121.16512))
     
   
   route.append(CLLocation(latitude:47.22902, longitude:-121.165))
     
   
   route.append(CLLocation(latitude:47.22891, longitude:-121.16482))
     
   
   route.append(CLLocation(latitude:47.22881, longitude:-121.16465))
     
   
   route.append(CLLocation(latitude:47.22861, longitude:-121.1643))
     
   
   route.append(CLLocation(latitude:47.22841, longitude:-121.16393))
     
   
   route.append(CLLocation(latitude:47.22799, longitude:-121.16315))
     
   
   route.append(CLLocation(latitude:47.22772, longitude:-121.16265))
     
   
   route.append(CLLocation(latitude:47.22752, longitude:-121.16227))
     
   
   route.append(CLLocation(latitude:47.22672, longitude:-121.16076))
     
   
   route.append(CLLocation(latitude:47.22572, longitude:-121.15889))
     
   
   route.append(CLLocation(latitude:47.22455, longitude:-121.15671))
     
   
   route.append(CLLocation(latitude:47.22366, longitude:-121.15505))
     
   
   route.append(CLLocation(latitude:47.22325, longitude:-121.15428))
     
   
   route.append(CLLocation(latitude:47.22259, longitude:-121.15305))
     
   
   route.append(CLLocation(latitude:47.22222, longitude:-121.15235))
     
   
   route.append(CLLocation(latitude:47.22146, longitude:-121.15093))
     
   
   route.append(CLLocation(latitude:47.22113, longitude:-121.1503))
     
   
   route.append(CLLocation(latitude:47.22094, longitude:-121.14994))
     
   
   route.append(CLLocation(latitude:47.22083, longitude:-121.14973))
     
   
   route.append(CLLocation(latitude:47.22074, longitude:-121.14955))
     
   
   route.append(CLLocation(latitude:47.22063, longitude:-121.1493))
     
   
   route.append(CLLocation(latitude:47.22051, longitude:-121.14902))
     
   
   route.append(CLLocation(latitude:47.22042, longitude:-121.14879))
     
   
   route.append(CLLocation(latitude:47.22035, longitude:-121.14861))
     
   
   route.append(CLLocation(latitude:47.22025, longitude:-121.14834))
     
   
   route.append(CLLocation(latitude:47.22014, longitude:-121.14804))
     
   
   route.append(CLLocation(latitude:47.22004, longitude:-121.14773))
     
   
   route.append(CLLocation(latitude:47.21996, longitude:-121.14743))
     
   
   route.append(CLLocation(latitude:47.21982, longitude:-121.14689))
     
   
   route.append(CLLocation(latitude:47.21971, longitude:-121.14643))
     
   
   route.append(CLLocation(latitude:47.21967, longitude:-121.14619))
     
   
   route.append(CLLocation(latitude:47.21962, longitude:-121.14597))
     
   
   route.append(CLLocation(latitude:47.21954, longitude:-121.1455))
     
   
   route.append(CLLocation(latitude:47.21946, longitude:-121.14503))
     
   
   route.append(CLLocation(latitude:47.2194, longitude:-121.14466))
     
   
   route.append(CLLocation(latitude:47.21926, longitude:-121.14381))
     
   
   route.append(CLLocation(latitude:47.21896, longitude:-121.14193))
     
   
   route.append(CLLocation(latitude:47.21878, longitude:-121.14085))
     
   
   route.append(CLLocation(latitude:47.21837, longitude:-121.13835))
     
   
   route.append(CLLocation(latitude:47.21814, longitude:-121.13694))
     
   
   route.append(CLLocation(latitude:47.21808, longitude:-121.13655))
     
   
   route.append(CLLocation(latitude:47.21799, longitude:-121.13598))
     
   
   route.append(CLLocation(latitude:47.21797, longitude:-121.13577))
     
   
   route.append(CLLocation(latitude:47.21793, longitude:-121.13545))
     
   
   route.append(CLLocation(latitude:47.21792, longitude:-121.13532))
     
   
   route.append(CLLocation(latitude:47.21791, longitude:-121.13517))
     
   
   route.append(CLLocation(latitude:47.2179, longitude:-121.135))
     
   
   route.append(CLLocation(latitude:47.21788, longitude:-121.13477))
     
   
   route.append(CLLocation(latitude:47.21786, longitude:-121.13438))
     
   
   route.append(CLLocation(latitude:47.21783, longitude:-121.13346))
     
   
   route.append(CLLocation(latitude:47.21781, longitude:-121.13302))
     
   
   route.append(CLLocation(latitude:47.2178, longitude:-121.13274))
     
   
   route.append(CLLocation(latitude:47.21778, longitude:-121.13258))
     
   
   route.append(CLLocation(latitude:47.21777, longitude:-121.13245))
     
   
   route.append(CLLocation(latitude:47.21776, longitude:-121.13229))
     
   
   route.append(CLLocation(latitude:47.21774, longitude:-121.13209))
     
   
   route.append(CLLocation(latitude:47.21771, longitude:-121.13184))
     
   
   route.append(CLLocation(latitude:47.21769, longitude:-121.13169))
     
   
   route.append(CLLocation(latitude:47.21767, longitude:-121.13152))
     
   
   route.append(CLLocation(latitude:47.21763, longitude:-121.13121))
     
   
   route.append(CLLocation(latitude:47.21758, longitude:-121.13091))
     
   
   route.append(CLLocation(latitude:47.21755, longitude:-121.13073))
     
   
   route.append(CLLocation(latitude:47.21749, longitude:-121.13037))
     
   
   route.append(CLLocation(latitude:47.21743, longitude:-121.13001))
     
   
   route.append(CLLocation(latitude:47.21732, longitude:-121.12936))
     
   
   route.append(CLLocation(latitude:47.21729, longitude:-121.12919))
     
   
   route.append(CLLocation(latitude:47.21725, longitude:-121.12904))
     
   
   route.append(CLLocation(latitude:47.21721, longitude:-121.12885))
     
   
   route.append(CLLocation(latitude:47.21719, longitude:-121.12876))
     
   
   route.append(CLLocation(latitude:47.21716, longitude:-121.12862))
     
   
   route.append(CLLocation(latitude:47.21709, longitude:-121.12835))
     
   
   route.append(CLLocation(latitude:47.21704, longitude:-121.12816))
     
   
   route.append(CLLocation(latitude:47.21701, longitude:-121.12804))
     
   
   route.append(CLLocation(latitude:47.21696, longitude:-121.12785))
     
   
   route.append(CLLocation(latitude:47.21675, longitude:-121.12716))
     
   
   route.append(CLLocation(latitude:47.21656, longitude:-121.12654))
     
   
   route.append(CLLocation(latitude:47.21648, longitude:-121.12626))
     
   
   route.append(CLLocation(latitude:47.21643, longitude:-121.12608))
     
   
   route.append(CLLocation(latitude:47.21638, longitude:-121.12587))
     
   
   route.append(CLLocation(latitude:47.21634, longitude:-121.12572))
     
   
   route.append(CLLocation(latitude:47.21631, longitude:-121.12558))
     
   
   route.append(CLLocation(latitude:47.21627, longitude:-121.12541))
     
   
   route.append(CLLocation(latitude:47.21624, longitude:-121.12527))
     
   
   route.append(CLLocation(latitude:47.21621, longitude:-121.12511))
     
   
   route.append(CLLocation(latitude:47.21618, longitude:-121.12493))
     
   
   route.append(CLLocation(latitude:47.21612, longitude:-121.12465))
     
   
   route.append(CLLocation(latitude:47.21605, longitude:-121.12417))
     
   
   route.append(CLLocation(latitude:47.21587, longitude:-121.12311))
     
   
   route.append(CLLocation(latitude:47.21564, longitude:-121.1217))
     
   
   route.append(CLLocation(latitude:47.2153, longitude:-121.11959))
     
   
   route.append(CLLocation(latitude:47.21529, longitude:-121.11955))
     
   
   route.append(CLLocation(latitude:47.21472, longitude:-121.11601))
     
   
   route.append(CLLocation(latitude:47.21413, longitude:-121.11245))
     
   
   route.append(CLLocation(latitude:47.21383, longitude:-121.11061))
     
   
   route.append(CLLocation(latitude:47.21375, longitude:-121.11015))
     
   
   route.append(CLLocation(latitude:47.21369, longitude:-121.10979))
     
   
   route.append(CLLocation(latitude:47.21364, longitude:-121.10944))
     
   
   route.append(CLLocation(latitude:47.21355, longitude:-121.10891))
     
   
   route.append(CLLocation(latitude:47.21346, longitude:-121.10847))
     
   
   route.append(CLLocation(latitude:47.21343, longitude:-121.1083))
     
   
   route.append(CLLocation(latitude:47.21339, longitude:-121.10813))
     
   
   route.append(CLLocation(latitude:47.21334, longitude:-121.10789))
     
   
   route.append(CLLocation(latitude:47.2133, longitude:-121.1077))
     
   
   route.append(CLLocation(latitude:47.21322, longitude:-121.10734))
     
   
   route.append(CLLocation(latitude:47.21312, longitude:-121.10694))
     
   
   route.append(CLLocation(latitude:47.21308, longitude:-121.10677))
     
   
   route.append(CLLocation(latitude:47.213, longitude:-121.10648))
     
   
   route.append(CLLocation(latitude:47.21288, longitude:-121.10607))
     
   
   route.append(CLLocation(latitude:47.21281, longitude:-121.10582))
     
   
   route.append(CLLocation(latitude:47.21271, longitude:-121.1055))
     
   
   route.append(CLLocation(latitude:47.21258, longitude:-121.10507))
     
   
   route.append(CLLocation(latitude:47.21248, longitude:-121.10478))
     
   
   route.append(CLLocation(latitude:47.21234, longitude:-121.10437))
     
   
   route.append(CLLocation(latitude:47.21213, longitude:-121.10377))
     
   
   route.append(CLLocation(latitude:47.21101, longitude:-121.10055))
     
   
   route.append(CLLocation(latitude:47.20885, longitude:-121.09431))
     
   
   route.append(CLLocation(latitude:47.20714, longitude:-121.08936))
     
   
   route.append(CLLocation(latitude:47.20665, longitude:-121.08793))
     
   
   route.append(CLLocation(latitude:47.2065, longitude:-121.08751))
     
   
   route.append(CLLocation(latitude:47.20624, longitude:-121.08677))
     
   
   route.append(CLLocation(latitude:47.20611, longitude:-121.08638))
     
   
   route.append(CLLocation(latitude:47.20594, longitude:-121.08588))
     
   
   route.append(CLLocation(latitude:47.20402, longitude:-121.08038))
     
   
   route.append(CLLocation(latitude:47.20198, longitude:-121.0745))
     
   
   route.append(CLLocation(latitude:47.20034, longitude:-121.06975))
     
   
   route.append(CLLocation(latitude:47.20004, longitude:-121.06891))
     
   
   route.append(CLLocation(latitude:47.19962, longitude:-121.06768))
     
   
   route.append(CLLocation(latitude:47.19906, longitude:-121.06608))
     
   
   route.append(CLLocation(latitude:47.19881, longitude:-121.06537))
     
   
   route.append(CLLocation(latitude:47.19852, longitude:-121.06453))
     
   
   route.append(CLLocation(latitude:47.19812, longitude:-121.06336))
     
   
   route.append(CLLocation(latitude:47.19779, longitude:-121.06244))
     
   
   route.append(CLLocation(latitude:47.19745, longitude:-121.06144))
     
   
   route.append(CLLocation(latitude:47.19631, longitude:-121.05816))
     
   
   route.append(CLLocation(latitude:47.1962, longitude:-121.05785))
     
   
   route.append(CLLocation(latitude:47.19615, longitude:-121.05768))
     
   
   route.append(CLLocation(latitude:47.1961, longitude:-121.05753))
     
   
   route.append(CLLocation(latitude:47.19604, longitude:-121.05732))
     
   
   route.append(CLLocation(latitude:47.19598, longitude:-121.05712))
     
   
   route.append(CLLocation(latitude:47.19592, longitude:-121.05687))
     
   
   route.append(CLLocation(latitude:47.19586, longitude:-121.05667))
     
   
   route.append(CLLocation(latitude:47.19571, longitude:-121.05595))
     
   
   route.append(CLLocation(latitude:47.19564, longitude:-121.05561))
     
   
   route.append(CLLocation(latitude:47.19551, longitude:-121.05496))
     
   
   route.append(CLLocation(latitude:47.19544, longitude:-121.05467))
     
   
   route.append(CLLocation(latitude:47.19541, longitude:-121.05452))
     
   
   route.append(CLLocation(latitude:47.19538, longitude:-121.0544))
     
   
   route.append(CLLocation(latitude:47.19532, longitude:-121.05415))
     
   
   route.append(CLLocation(latitude:47.19526, longitude:-121.05391))
     
   
   route.append(CLLocation(latitude:47.19522, longitude:-121.05377))
     
   
   route.append(CLLocation(latitude:47.19516, longitude:-121.05354))
     
   
   route.append(CLLocation(latitude:47.1951, longitude:-121.05336))
     
   
   route.append(CLLocation(latitude:47.19501, longitude:-121.05307))
     
   
   route.append(CLLocation(latitude:47.19482, longitude:-121.05254))
     
   
   route.append(CLLocation(latitude:47.19473, longitude:-121.05228))
     
   
   route.append(CLLocation(latitude:47.19473, longitude:-121.05227))
     
   
   route.append(CLLocation(latitude:47.19464, longitude:-121.05202))
     
   
   route.append(CLLocation(latitude:47.19453, longitude:-121.0517))
     
   
   route.append(CLLocation(latitude:47.19443, longitude:-121.05141))
     
   
   route.append(CLLocation(latitude:47.19432, longitude:-121.05112))
     
   
   route.append(CLLocation(latitude:47.19423, longitude:-121.05089))
     
   
   route.append(CLLocation(latitude:47.19417, longitude:-121.05075))
     
   
   route.append(CLLocation(latitude:47.1941, longitude:-121.0506))
     
   
   route.append(CLLocation(latitude:47.19394, longitude:-121.05026))
     
   
   route.append(CLLocation(latitude:47.19385, longitude:-121.05009))
     
   
   route.append(CLLocation(latitude:47.19367, longitude:-121.04975))
     
   
   route.append(CLLocation(latitude:47.19357, longitude:-121.04959))
     
   
   route.append(CLLocation(latitude:47.1935, longitude:-121.04949))
     
   
   route.append(CLLocation(latitude:47.19344, longitude:-121.04939))
     
   
   route.append(CLLocation(latitude:47.19333, longitude:-121.04921))
     
   
   route.append(CLLocation(latitude:47.19323, longitude:-121.04907))
     
   
   route.append(CLLocation(latitude:47.19316, longitude:-121.04897))
     
   
   route.append(CLLocation(latitude:47.19305, longitude:-121.04882))
     
   
   route.append(CLLocation(latitude:47.19297, longitude:-121.04872))
     
   
   route.append(CLLocation(latitude:47.19287, longitude:-121.0486))
     
   
   route.append(CLLocation(latitude:47.19275, longitude:-121.04846))
     
   
   route.append(CLLocation(latitude:47.19258, longitude:-121.04826))
     
   
   route.append(CLLocation(latitude:47.19243, longitude:-121.04811))
     
   
   route.append(CLLocation(latitude:47.19229, longitude:-121.04797))
     
   
   route.append(CLLocation(latitude:47.19217, longitude:-121.04786))
     
   
   route.append(CLLocation(latitude:47.19208, longitude:-121.04778))
     
   
   route.append(CLLocation(latitude:47.19195, longitude:-121.04767))
     
   
   route.append(CLLocation(latitude:47.19171, longitude:-121.04748))
     
   
   route.append(CLLocation(latitude:47.19153, longitude:-121.04735))
     
   
   route.append(CLLocation(latitude:47.19064, longitude:-121.04672))
     
   
   route.append(CLLocation(latitude:47.18795, longitude:-121.04483))
     
   
   route.append(CLLocation(latitude:47.18617, longitude:-121.04358))
     
   
   route.append(CLLocation(latitude:47.1857, longitude:-121.04324))
     
   
   route.append(CLLocation(latitude:47.18548, longitude:-121.0431))
     
   
   route.append(CLLocation(latitude:47.18493, longitude:-121.04272))
     
   
   route.append(CLLocation(latitude:47.18463, longitude:-121.04249))
     
   
   route.append(CLLocation(latitude:47.18443, longitude:-121.04234))
     
   
   route.append(CLLocation(latitude:47.18408, longitude:-121.04207))
     
   
   route.append(CLLocation(latitude:47.18397, longitude:-121.04196))
     
   
   route.append(CLLocation(latitude:47.18386, longitude:-121.04187))
     
   
   route.append(CLLocation(latitude:47.18379, longitude:-121.04179))
     
   
   route.append(CLLocation(latitude:47.1837, longitude:-121.0417))
     
   
   route.append(CLLocation(latitude:47.18361, longitude:-121.04159))
     
   
   route.append(CLLocation(latitude:47.18353, longitude:-121.0415))
     
   
   route.append(CLLocation(latitude:47.18345, longitude:-121.04141))
     
   
   route.append(CLLocation(latitude:47.18338, longitude:-121.0413))
     
   
   route.append(CLLocation(latitude:47.18329, longitude:-121.04119))
     
   
   route.append(CLLocation(latitude:47.18321, longitude:-121.04106))
     
   
   route.append(CLLocation(latitude:47.18314, longitude:-121.04096))
     
   
   route.append(CLLocation(latitude:47.18307, longitude:-121.04084))
     
   
   route.append(CLLocation(latitude:47.183, longitude:-121.04073))
     
   
   route.append(CLLocation(latitude:47.18294, longitude:-121.04061))
     
   
   route.append(CLLocation(latitude:47.18283, longitude:-121.04042))
     
   
   route.append(CLLocation(latitude:47.18274, longitude:-121.04021))
     
   
   route.append(CLLocation(latitude:47.18267, longitude:-121.04006))
     
   
   route.append(CLLocation(latitude:47.1826, longitude:-121.0399))
     
   
   route.append(CLLocation(latitude:47.18252, longitude:-121.03969))
     
   
   route.append(CLLocation(latitude:47.18247, longitude:-121.03953))
     
   
   route.append(CLLocation(latitude:47.18242, longitude:-121.03938))
     
   
   route.append(CLLocation(latitude:47.18237, longitude:-121.03924))
     
   
   route.append(CLLocation(latitude:47.18233, longitude:-121.03909))
     
   
   route.append(CLLocation(latitude:47.18229, longitude:-121.03895))
     
   
   route.append(CLLocation(latitude:47.18226, longitude:-121.03882))
     
   
   route.append(CLLocation(latitude:47.18223, longitude:-121.03868))
     
   
   route.append(CLLocation(latitude:47.1822, longitude:-121.03853))
     
   
   route.append(CLLocation(latitude:47.18217, longitude:-121.03837))
     
   
   route.append(CLLocation(latitude:47.18214, longitude:-121.0382))
     
   
   route.append(CLLocation(latitude:47.18212, longitude:-121.03801))
     
   
   route.append(CLLocation(latitude:47.1821, longitude:-121.03788))
     
   
   route.append(CLLocation(latitude:47.18209, longitude:-121.03775))
     
   
   route.append(CLLocation(latitude:47.18207, longitude:-121.03765))
     
   
   route.append(CLLocation(latitude:47.18206, longitude:-121.03754))
     
   
   route.append(CLLocation(latitude:47.18205, longitude:-121.03741))
     
   
   route.append(CLLocation(latitude:47.18204, longitude:-121.03725))
     
   
   route.append(CLLocation(latitude:47.18204, longitude:-121.03709))
     
   
   route.append(CLLocation(latitude:47.18203, longitude:-121.03692))
     
   
   route.append(CLLocation(latitude:47.18204, longitude:-121.03677))
     
   
   route.append(CLLocation(latitude:47.18204, longitude:-121.03647))
     
   
   route.append(CLLocation(latitude:47.18205, longitude:-121.03615))
     
   
   route.append(CLLocation(latitude:47.18207, longitude:-121.03583))
     
   
   route.append(CLLocation(latitude:47.18209, longitude:-121.03553))
     
   
   route.append(CLLocation(latitude:47.18211, longitude:-121.0353))
     
   
   route.append(CLLocation(latitude:47.18213, longitude:-121.03496))
     
   
   route.append(CLLocation(latitude:47.18216, longitude:-121.03461))
     
   
   route.append(CLLocation(latitude:47.18219, longitude:-121.03416))
     
   
   route.append(CLLocation(latitude:47.18226, longitude:-121.03313))
     
   
   route.append(CLLocation(latitude:47.18233, longitude:-121.03211))
     
   
   route.append(CLLocation(latitude:47.18241, longitude:-121.03096))
     
   
   route.append(CLLocation(latitude:47.1831, longitude:-121.02103))
     
   
   route.append(CLLocation(latitude:47.1832, longitude:-121.01961))
     
   
   route.append(CLLocation(latitude:47.18344, longitude:-121.01613))
     
   
   route.append(CLLocation(latitude:47.18358, longitude:-121.01411))
     
   
   route.append(CLLocation(latitude:47.18387, longitude:-121.01002))
     
   
   route.append(CLLocation(latitude:47.1839, longitude:-121.0096))
     
   
   route.append(CLLocation(latitude:47.18391, longitude:-121.00935))
     
   
   route.append(CLLocation(latitude:47.18397, longitude:-121.00861))
     
   
   route.append(CLLocation(latitude:47.18404, longitude:-121.00754))
     
   
   route.append(CLLocation(latitude:47.18416, longitude:-121.00588))
     
   
   route.append(CLLocation(latitude:47.18429, longitude:-121.00404))
     
   
   route.append(CLLocation(latitude:47.18435, longitude:-121.00317))
     
   
   route.append(CLLocation(latitude:47.18454, longitude:-121.00036))
     
   
   route.append(CLLocation(latitude:47.18456, longitude:-121.00002))
     
   
   route.append(CLLocation(latitude:47.18459, longitude:-120.9995))
     
   
   route.append(CLLocation(latitude:47.18464, longitude:-120.99889))
     
   
   route.append(CLLocation(latitude:47.18468, longitude:-120.99827))
     
   
   route.append(CLLocation(latitude:47.18473, longitude:-120.99755))
     
   
   route.append(CLLocation(latitude:47.18476, longitude:-120.99724))
     
   
   route.append(CLLocation(latitude:47.18478, longitude:-120.99698))
     
   
   route.append(CLLocation(latitude:47.18481, longitude:-120.99667))
     
   
   route.append(CLLocation(latitude:47.18483, longitude:-120.99651))
     
   
   route.append(CLLocation(latitude:47.18484, longitude:-120.99638))
     
   
   route.append(CLLocation(latitude:47.18486, longitude:-120.99617))
     
   
   route.append(CLLocation(latitude:47.1849, longitude:-120.99585))
     
   
   route.append(CLLocation(latitude:47.18494, longitude:-120.99555))
     
   
   route.append(CLLocation(latitude:47.18497, longitude:-120.99537))
     
   
   route.append(CLLocation(latitude:47.18502, longitude:-120.99496))
     
   
   route.append(CLLocation(latitude:47.18504, longitude:-120.99487))
     
   
   route.append(CLLocation(latitude:47.18507, longitude:-120.99467))
     
   
   route.append(CLLocation(latitude:47.18511, longitude:-120.99444))
     
   
   route.append(CLLocation(latitude:47.18516, longitude:-120.99417))
     
   
   route.append(CLLocation(latitude:47.18528, longitude:-120.99357))
     
   
   route.append(CLLocation(latitude:47.18538, longitude:-120.99308))
     
   
   route.append(CLLocation(latitude:47.18547, longitude:-120.99265))
     
   
   route.append(CLLocation(latitude:47.18556, longitude:-120.9923))
     
   
   route.append(CLLocation(latitude:47.18563, longitude:-120.99202))
     
   
   route.append(CLLocation(latitude:47.18582, longitude:-120.99129))
     
   
   route.append(CLLocation(latitude:47.18621, longitude:-120.98997))
     
   
   route.append(CLLocation(latitude:47.18644, longitude:-120.98922))
     
   
   route.append(CLLocation(latitude:47.1868, longitude:-120.98807))
     
   
   route.append(CLLocation(latitude:47.18769, longitude:-120.98512))
     
   
   route.append(CLLocation(latitude:47.18812, longitude:-120.98375))
     
   
   route.append(CLLocation(latitude:47.18887, longitude:-120.98132))
     
   
   route.append(CLLocation(latitude:47.18918, longitude:-120.98029))
     
   
   route.append(CLLocation(latitude:47.18936, longitude:-120.97972))
     
   
   route.append(CLLocation(latitude:47.18951, longitude:-120.97924))
     
   
   route.append(CLLocation(latitude:47.18972, longitude:-120.97853))
     
   
   route.append(CLLocation(latitude:47.19004, longitude:-120.9775))
     
   
   route.append(CLLocation(latitude:47.19053, longitude:-120.97589))
     
   
   route.append(CLLocation(latitude:47.19107, longitude:-120.97417))
     
   
   route.append(CLLocation(latitude:47.19131, longitude:-120.97336))
     
   
   route.append(CLLocation(latitude:47.19157, longitude:-120.97253))
     
   
   route.append(CLLocation(latitude:47.19169, longitude:-120.97216))
     
   
   route.append(CLLocation(latitude:47.19189, longitude:-120.97152))
     
   
   route.append(CLLocation(latitude:47.19225, longitude:-120.97035))
     
   
   route.append(CLLocation(latitude:47.19236, longitude:-120.97))
     
   
   route.append(CLLocation(latitude:47.1927, longitude:-120.96889))
     
   
   route.append(CLLocation(latitude:47.19292, longitude:-120.96816))
     
   
   route.append(CLLocation(latitude:47.19319, longitude:-120.96729))
     
   
   route.append(CLLocation(latitude:47.19383, longitude:-120.96521))
     
   
   route.append(CLLocation(latitude:47.19397, longitude:-120.96478))
     
   
   route.append(CLLocation(latitude:47.19412, longitude:-120.96428))
     
   
   route.append(CLLocation(latitude:47.19427, longitude:-120.96376))
     
   
   route.append(CLLocation(latitude:47.19432, longitude:-120.96358))
     
   
   route.append(CLLocation(latitude:47.1944, longitude:-120.96332))
     
   
   route.append(CLLocation(latitude:47.19444, longitude:-120.96315))
     
   
   route.append(CLLocation(latitude:47.19447, longitude:-120.96301))
     
   
   route.append(CLLocation(latitude:47.19451, longitude:-120.96285))
     
   
   route.append(CLLocation(latitude:47.19454, longitude:-120.96268))
     
   
   route.append(CLLocation(latitude:47.19456, longitude:-120.96255))
     
   
   route.append(CLLocation(latitude:47.19459, longitude:-120.96238))
     
   
   route.append(CLLocation(latitude:47.19462, longitude:-120.96222))
     
   
   route.append(CLLocation(latitude:47.19464, longitude:-120.96205))
     
   
   route.append(CLLocation(latitude:47.19468, longitude:-120.96175))
     
   
   route.append(CLLocation(latitude:47.19469, longitude:-120.96159))
     
   
   route.append(CLLocation(latitude:47.19471, longitude:-120.96137))
     
   
   route.append(CLLocation(latitude:47.19472, longitude:-120.96119))
     
   
   route.append(CLLocation(latitude:47.19473, longitude:-120.96109))
     
   
   route.append(CLLocation(latitude:47.19473, longitude:-120.96092))
     
   
   route.append(CLLocation(latitude:47.19474, longitude:-120.96063))
     
   
   route.append(CLLocation(latitude:47.19474, longitude:-120.96047))
     
   
   route.append(CLLocation(latitude:47.19473, longitude:-120.96032))
     
   
   route.append(CLLocation(latitude:47.19473, longitude:-120.96011))
     
   
   route.append(CLLocation(latitude:47.19472, longitude:-120.95998))
     
   
   route.append(CLLocation(latitude:47.19471, longitude:-120.95981))
     
   
   route.append(CLLocation(latitude:47.1947, longitude:-120.95965))
     
   
   route.append(CLLocation(latitude:47.19468, longitude:-120.95945))
     
   
   route.append(CLLocation(latitude:47.19465, longitude:-120.9592))
     
   
   route.append(CLLocation(latitude:47.19463, longitude:-120.95904))
     
   
   route.append(CLLocation(latitude:47.1946, longitude:-120.95882))
     
   
   route.append(CLLocation(latitude:47.19456, longitude:-120.95859))
     
   
   route.append(CLLocation(latitude:47.19453, longitude:-120.95844))
     
   
   route.append(CLLocation(latitude:47.19449, longitude:-120.95828))
     
   
   route.append(CLLocation(latitude:47.19446, longitude:-120.95813))
     
   
   route.append(CLLocation(latitude:47.19437, longitude:-120.95777))
     
   
   route.append(CLLocation(latitude:47.19434, longitude:-120.95764))
     
   
   route.append(CLLocation(latitude:47.1943, longitude:-120.9575))
     
   
   route.append(CLLocation(latitude:47.19425, longitude:-120.95734))
     
   
   route.append(CLLocation(latitude:47.19417, longitude:-120.9571))
     
   
   route.append(CLLocation(latitude:47.19391, longitude:-120.95635))
     
   
   route.append(CLLocation(latitude:47.19376, longitude:-120.95594))
     
   
   route.append(CLLocation(latitude:47.19371, longitude:-120.95579))
     
   
   route.append(CLLocation(latitude:47.19362, longitude:-120.95551))
     
   
   route.append(CLLocation(latitude:47.19353, longitude:-120.95521))
     
   
   route.append(CLLocation(latitude:47.19348, longitude:-120.95506))
     
   
   route.append(CLLocation(latitude:47.19344, longitude:-120.95489))
     
   
   route.append(CLLocation(latitude:47.1934, longitude:-120.95476))
     
   
   route.append(CLLocation(latitude:47.19336, longitude:-120.9546))
     
   
   route.append(CLLocation(latitude:47.19333, longitude:-120.95445))
     
   
   route.append(CLLocation(latitude:47.19328, longitude:-120.9542))
     
   
   route.append(CLLocation(latitude:47.19324, longitude:-120.95399))
     
   
   route.append(CLLocation(latitude:47.19322, longitude:-120.95384))
     
   
   route.append(CLLocation(latitude:47.19319, longitude:-120.95368))
     
   
   route.append(CLLocation(latitude:47.19312, longitude:-120.95313))
     
   
   route.append(CLLocation(latitude:47.19308, longitude:-120.95271))
     
   
   route.append(CLLocation(latitude:47.19301, longitude:-120.95209))
     
   
   route.append(CLLocation(latitude:47.19296, longitude:-120.95158))
     
   
   route.append(CLLocation(latitude:47.19284, longitude:-120.95048))
     
   
   route.append(CLLocation(latitude:47.19278, longitude:-120.94982))
     
   
   route.append(CLLocation(latitude:47.19271, longitude:-120.94917))
     
   
   route.append(CLLocation(latitude:47.19269, longitude:-120.94896))
     
   
   route.append(CLLocation(latitude:47.19266, longitude:-120.94875))
     
   
   route.append(CLLocation(latitude:47.19259, longitude:-120.94802))
     
   
   route.append(CLLocation(latitude:47.19248, longitude:-120.947))
     
   
   route.append(CLLocation(latitude:47.19242, longitude:-120.94638))
     
   
   route.append(CLLocation(latitude:47.19237, longitude:-120.94591))
     
   
   route.append(CLLocation(latitude:47.1923, longitude:-120.94528))
     
   
   route.append(CLLocation(latitude:47.19224, longitude:-120.94464))
     
   
   route.append(CLLocation(latitude:47.19217, longitude:-120.944))
     
   
   route.append(CLLocation(latitude:47.1921, longitude:-120.94336))
     
   
   route.append(CLLocation(latitude:47.19205, longitude:-120.94288))
     
   
   route.append(CLLocation(latitude:47.192, longitude:-120.94241))
     
   
   route.append(CLLocation(latitude:47.19196, longitude:-120.94195))
     
   
   route.append(CLLocation(latitude:47.1919, longitude:-120.94146))
     
   
   route.append(CLLocation(latitude:47.19187, longitude:-120.94114))
     
   
   route.append(CLLocation(latitude:47.19185, longitude:-120.94099))
     
   
   route.append(CLLocation(latitude:47.19184, longitude:-120.94082))
     
   
   route.append(CLLocation(latitude:47.19182, longitude:-120.94067))
     
   
   route.append(CLLocation(latitude:47.1918, longitude:-120.94052))
     
   
   route.append(CLLocation(latitude:47.19179, longitude:-120.94036))
     
   
   route.append(CLLocation(latitude:47.19176, longitude:-120.9402))
     
   
   route.append(CLLocation(latitude:47.19174, longitude:-120.94004))
     
   
   route.append(CLLocation(latitude:47.19172, longitude:-120.93988))
     
   
   route.append(CLLocation(latitude:47.1917, longitude:-120.93972))
     
   
   route.append(CLLocation(latitude:47.19168, longitude:-120.93957))
     
   
   route.append(CLLocation(latitude:47.19164, longitude:-120.93933))
     
   
   route.append(CLLocation(latitude:47.1916, longitude:-120.93905))
     
   
   route.append(CLLocation(latitude:47.19156, longitude:-120.93883))
     
   
   route.append(CLLocation(latitude:47.19153, longitude:-120.93862))
     
   
   route.append(CLLocation(latitude:47.19149, longitude:-120.93841))
     
   
   route.append(CLLocation(latitude:47.19145, longitude:-120.93822))
     
   
   route.append(CLLocation(latitude:47.19141, longitude:-120.93801))
     
   
   route.append(CLLocation(latitude:47.19135, longitude:-120.93769))
     
   
   route.append(CLLocation(latitude:47.19114, longitude:-120.93669))
     
   
   route.append(CLLocation(latitude:47.19085, longitude:-120.93532))
     
   
   route.append(CLLocation(latitude:47.19019, longitude:-120.93215))
     
   
   route.append(CLLocation(latitude:47.19001, longitude:-120.93131))
     
   
   route.append(CLLocation(latitude:47.18962, longitude:-120.92942))
     
   
   route.append(CLLocation(latitude:47.18818, longitude:-120.92258))
     
   
   route.append(CLLocation(latitude:47.18781, longitude:-120.92082))
     
   
   route.append(CLLocation(latitude:47.18768, longitude:-120.92021))
     
   
   route.append(CLLocation(latitude:47.18749, longitude:-120.9193))
     
   
   route.append(CLLocation(latitude:47.1873, longitude:-120.91837))
     
   
   route.append(CLLocation(latitude:47.18711, longitude:-120.91746))
     
   
   route.append(CLLocation(latitude:47.18695, longitude:-120.9167))
     
   
   route.append(CLLocation(latitude:47.18682, longitude:-120.91608))
     
   
   route.append(CLLocation(latitude:47.18669, longitude:-120.91546))
     
   
   route.append(CLLocation(latitude:47.18656, longitude:-120.91485))
     
   
   route.append(CLLocation(latitude:47.18643, longitude:-120.91423))
     
   
   route.append(CLLocation(latitude:47.18627, longitude:-120.91348))
     
   
   route.append(CLLocation(latitude:47.18614, longitude:-120.91286))
     
   
   route.append(CLLocation(latitude:47.18605, longitude:-120.9124))
     
   
   route.append(CLLocation(latitude:47.18592, longitude:-120.91179))
     
   
   route.append(CLLocation(latitude:47.18579, longitude:-120.91117))
     
   
   route.append(CLLocation(latitude:47.18569, longitude:-120.91071))
     
   
   route.append(CLLocation(latitude:47.1856, longitude:-120.91025))
     
   
   route.append(CLLocation(latitude:47.1855, longitude:-120.90979))
     
   
   route.append(CLLocation(latitude:47.18536, longitude:-120.90918))
     
   
   route.append(CLLocation(latitude:47.18521, longitude:-120.90857))
     
   
   route.append(CLLocation(latitude:47.18509, longitude:-120.90814))
     
   
   route.append(CLLocation(latitude:47.185, longitude:-120.90783))
     
   
   route.append(CLLocation(latitude:47.18492, longitude:-120.90754))
     
   
   route.append(CLLocation(latitude:47.18483, longitude:-120.90725))
     
   
   route.append(CLLocation(latitude:47.18474, longitude:-120.90696))
     
   
   route.append(CLLocation(latitude:47.18464, longitude:-120.90666))
     
   
   route.append(CLLocation(latitude:47.18461, longitude:-120.90656))
     
   
   route.append(CLLocation(latitude:47.18449, longitude:-120.90623))
     
   
   route.append(CLLocation(latitude:47.18439, longitude:-120.90594))
     
   
   route.append(CLLocation(latitude:47.18433, longitude:-120.9058))
     
   
   route.append(CLLocation(latitude:47.18428, longitude:-120.90565))
     
   
   route.append(CLLocation(latitude:47.18423, longitude:-120.90553))
     
   
   route.append(CLLocation(latitude:47.18418, longitude:-120.90538))
     
   
   route.append(CLLocation(latitude:47.18412, longitude:-120.90523))
     
   
   route.append(CLLocation(latitude:47.18406, longitude:-120.90508))
     
   
   route.append(CLLocation(latitude:47.18401, longitude:-120.90494))
     
   
   route.append(CLLocation(latitude:47.18395, longitude:-120.9048))
     
   
   route.append(CLLocation(latitude:47.18386, longitude:-120.90459))
     
   
   route.append(CLLocation(latitude:47.18377, longitude:-120.90438))
     
   
   route.append(CLLocation(latitude:47.18371, longitude:-120.90424))
     
   
   route.append(CLLocation(latitude:47.18366, longitude:-120.90412))
     
   
   route.append(CLLocation(latitude:47.18354, longitude:-120.90386))
     
   
   route.append(CLLocation(latitude:47.18341, longitude:-120.90357))
     
   
   route.append(CLLocation(latitude:47.18329, longitude:-120.90333))
     
   
   route.append(CLLocation(latitude:47.18304, longitude:-120.90282))
     
   
   route.append(CLLocation(latitude:47.18285, longitude:-120.90245))
     
   
   route.append(CLLocation(latitude:47.18244, longitude:-120.90164))
     
   
   route.append(CLLocation(latitude:47.18186, longitude:-120.90053))
     
   
   route.append(CLLocation(latitude:47.18153, longitude:-120.89987))
     
   
   route.append(CLLocation(latitude:47.18124, longitude:-120.8993))
     
   
   route.append(CLLocation(latitude:47.18069, longitude:-120.8982))
     
   
   route.append(CLLocation(latitude:47.18021, longitude:-120.89725))
     
   
   route.append(CLLocation(latitude:47.17997, longitude:-120.89679))
     
   
   route.append(CLLocation(latitude:47.17984, longitude:-120.89652))
     
   
   route.append(CLLocation(latitude:47.17944, longitude:-120.89573))
     
   
   route.append(CLLocation(latitude:47.17924, longitude:-120.89534))
     
   
   route.append(CLLocation(latitude:47.17912, longitude:-120.8951))
     
   
   route.append(CLLocation(latitude:47.17905, longitude:-120.89497))
     
   
   route.append(CLLocation(latitude:47.17898, longitude:-120.89485))
     
   
   route.append(CLLocation(latitude:47.17887, longitude:-120.89465))
     
   
   route.append(CLLocation(latitude:47.17878, longitude:-120.8945))
     
   
   route.append(CLLocation(latitude:47.17866, longitude:-120.89431))
     
   
   route.append(CLLocation(latitude:47.17855, longitude:-120.89416))
     
   
   route.append(CLLocation(latitude:47.17847, longitude:-120.89404))
     
   
   route.append(CLLocation(latitude:47.17839, longitude:-120.89393))
     
   
   route.append(CLLocation(latitude:47.17831, longitude:-120.89383))
     
   
   route.append(CLLocation(latitude:47.17823, longitude:-120.89372))
     
   
   route.append(CLLocation(latitude:47.17814, longitude:-120.89362))
     
   
   route.append(CLLocation(latitude:47.17806, longitude:-120.89352))
     
   
   route.append(CLLocation(latitude:47.17797, longitude:-120.89342))
     
   
   route.append(CLLocation(latitude:47.17788, longitude:-120.89333))
     
   
   route.append(CLLocation(latitude:47.1778, longitude:-120.89323))
     
   
   route.append(CLLocation(latitude:47.17762, longitude:-120.89305))
     
   
   route.append(CLLocation(latitude:47.17753, longitude:-120.89296))
     
   
   route.append(CLLocation(latitude:47.17734, longitude:-120.8928))
     
   
   route.append(CLLocation(latitude:47.17706, longitude:-120.89256))
     
   
   route.append(CLLocation(latitude:47.17667, longitude:-120.89223))
     
   
   route.append(CLLocation(latitude:47.17639, longitude:-120.89199))
     
   
   route.append(CLLocation(latitude:47.17563, longitude:-120.89137))
     
   
   route.append(CLLocation(latitude:47.17522, longitude:-120.89103))
     
   
   route.append(CLLocation(latitude:47.1748, longitude:-120.89069))
     
   
   route.append(CLLocation(latitude:47.1734, longitude:-120.88953))
     
   
   route.append(CLLocation(latitude:47.17325, longitude:-120.88939))
     
   
   route.append(CLLocation(latitude:47.17313, longitude:-120.88928))
     
   
   route.append(CLLocation(latitude:47.17287, longitude:-120.88903))
     
   
   route.append(CLLocation(latitude:47.17278, longitude:-120.88894))
     
   
   route.append(CLLocation(latitude:47.17269, longitude:-120.88885))
     
   
   route.append(CLLocation(latitude:47.1726, longitude:-120.88875))
     
   
   route.append(CLLocation(latitude:47.17252, longitude:-120.88866))
     
   
   route.append(CLLocation(latitude:47.17243, longitude:-120.88855))
     
   
   route.append(CLLocation(latitude:47.17235, longitude:-120.88845))
     
   
   route.append(CLLocation(latitude:47.17226, longitude:-120.88835))
     
   
   route.append(CLLocation(latitude:47.17218, longitude:-120.88825))
     
   
   route.append(CLLocation(latitude:47.17202, longitude:-120.88804))
     
   
   route.append(CLLocation(latitude:47.17186, longitude:-120.88782))
     
   
   route.append(CLLocation(latitude:47.17171, longitude:-120.88759))
     
   
   route.append(CLLocation(latitude:47.17163, longitude:-120.88748))
     
   
   route.append(CLLocation(latitude:47.17156, longitude:-120.88736))
     
   
   route.append(CLLocation(latitude:47.17141, longitude:-120.88712))
     
   
   route.append(CLLocation(latitude:47.1712, longitude:-120.88674))
     
   
   route.append(CLLocation(latitude:47.17112, longitude:-120.88661))
     
   
   route.append(CLLocation(latitude:47.171, longitude:-120.88639))
     
   
   route.append(CLLocation(latitude:47.16584, longitude:-120.87696))
     
   
   route.append(CLLocation(latitude:47.1657, longitude:-120.87671))
     
   
   route.append(CLLocation(latitude:47.16556, longitude:-120.87646))
     
   
   route.append(CLLocation(latitude:47.16544, longitude:-120.87623))
     
   
   route.append(CLLocation(latitude:47.1653, longitude:-120.87596))
     
   
   route.append(CLLocation(latitude:47.16518, longitude:-120.87573))
     
   
   route.append(CLLocation(latitude:47.1651, longitude:-120.87557))
     
   
   route.append(CLLocation(latitude:47.16499, longitude:-120.87534))
     
   
   route.append(CLLocation(latitude:47.16491, longitude:-120.87517))
     
   
   route.append(CLLocation(latitude:47.1648, longitude:-120.87492))
     
   
   route.append(CLLocation(latitude:47.16473, longitude:-120.87477))
     
   
   route.append(CLLocation(latitude:47.16462, longitude:-120.87454))
     
   
   route.append(CLLocation(latitude:47.16451, longitude:-120.87427))
     
   
   route.append(CLLocation(latitude:47.16438, longitude:-120.87397))
     
   
   route.append(CLLocation(latitude:47.16422, longitude:-120.87358))
     
   
   route.append(CLLocation(latitude:47.16411, longitude:-120.87327))
     
   
   route.append(CLLocation(latitude:47.16395, longitude:-120.87284))
     
   
   route.append(CLLocation(latitude:47.16385, longitude:-120.87256))
     
   
   route.append(CLLocation(latitude:47.1637, longitude:-120.87212))
     
   
   route.append(CLLocation(latitude:47.16357, longitude:-120.87171))
     
   
   route.append(CLLocation(latitude:47.16342, longitude:-120.87124))
     
   
   route.append(CLLocation(latitude:47.16277, longitude:-120.86889))
     
   
   route.append(CLLocation(latitude:47.16243, longitude:-120.8677))
     
   
   route.append(CLLocation(latitude:47.16202, longitude:-120.86623))
     
   
   route.append(CLLocation(latitude:47.16176, longitude:-120.86532))
     
   
   route.append(CLLocation(latitude:47.16164, longitude:-120.86487))
     
   
   route.append(CLLocation(latitude:47.16155, longitude:-120.86458))
     
   
   route.append(CLLocation(latitude:47.16147, longitude:-120.86428))
     
   
   route.append(CLLocation(latitude:47.1614, longitude:-120.86403))
     
   
   route.append(CLLocation(latitude:47.16135, longitude:-120.86385))
     
   
   route.append(CLLocation(latitude:47.16132, longitude:-120.8637))
     
   
   route.append(CLLocation(latitude:47.16129, longitude:-120.86354))
     
   
   route.append(CLLocation(latitude:47.16125, longitude:-120.86339))
     
   
   route.append(CLLocation(latitude:47.16123, longitude:-120.86324))
     
   
   route.append(CLLocation(latitude:47.1612, longitude:-120.86307))
     
   
   route.append(CLLocation(latitude:47.16117, longitude:-120.86291))
     
   
   route.append(CLLocation(latitude:47.16115, longitude:-120.86276))
     
   
   route.append(CLLocation(latitude:47.16112, longitude:-120.86248))
     
   
   route.append(CLLocation(latitude:47.1611, longitude:-120.86227))
     
   
   route.append(CLLocation(latitude:47.16108, longitude:-120.8621))
     
   
   route.append(CLLocation(latitude:47.16107, longitude:-120.86196))
     
   
   route.append(CLLocation(latitude:47.16106, longitude:-120.86178))
     
   
   route.append(CLLocation(latitude:47.16106, longitude:-120.86162))
     
   
   route.append(CLLocation(latitude:47.16105, longitude:-120.86146))
     
   
   route.append(CLLocation(latitude:47.16105, longitude:-120.8613))
     
   
   route.append(CLLocation(latitude:47.16105, longitude:-120.86114))
     
   
   route.append(CLLocation(latitude:47.16105, longitude:-120.86098))
     
   
   route.append(CLLocation(latitude:47.16106, longitude:-120.86082))
     
   
   route.append(CLLocation(latitude:47.16106, longitude:-120.86066))
     
   
   route.append(CLLocation(latitude:47.16108, longitude:-120.86035))
     
   
   route.append(CLLocation(latitude:47.16111, longitude:-120.86003))
     
   
   route.append(CLLocation(latitude:47.16121, longitude:-120.85891))
     
   
   route.append(CLLocation(latitude:47.16131, longitude:-120.85784))
     
   
   route.append(CLLocation(latitude:47.16139, longitude:-120.85705))
     
   
   route.append(CLLocation(latitude:47.16156, longitude:-120.85535))
     
   
   route.append(CLLocation(latitude:47.16166, longitude:-120.85426))
     
   
   route.append(CLLocation(latitude:47.16172, longitude:-120.85369))
     
   
   route.append(CLLocation(latitude:47.16174, longitude:-120.85354))
     
   
   route.append(CLLocation(latitude:47.16176, longitude:-120.85323))
     
   
   route.append(CLLocation(latitude:47.16177, longitude:-120.85308))
     
   
   route.append(CLLocation(latitude:47.16178, longitude:-120.85291))
     
   
   route.append(CLLocation(latitude:47.16179, longitude:-120.85254))
     
   
   route.append(CLLocation(latitude:47.1618, longitude:-120.85227))
     
   
   route.append(CLLocation(latitude:47.1618, longitude:-120.85198))
     
   
   route.append(CLLocation(latitude:47.1618, longitude:-120.85179))
     
   
   route.append(CLLocation(latitude:47.1618, longitude:-120.85162))
     
   
   route.append(CLLocation(latitude:47.1618, longitude:-120.85146))
     
   
   route.append(CLLocation(latitude:47.1618, longitude:-120.8513))
     
   
   route.append(CLLocation(latitude:47.16179, longitude:-120.85113))
     
   
   route.append(CLLocation(latitude:47.16178, longitude:-120.85086))
     
   
   route.append(CLLocation(latitude:47.16177, longitude:-120.85065))
     
   
   route.append(CLLocation(latitude:47.16176, longitude:-120.85049))
     
   
   route.append(CLLocation(latitude:47.16176, longitude:-120.85033))
     
   
   route.append(CLLocation(latitude:47.16173, longitude:-120.85005))
     
   
   route.append(CLLocation(latitude:47.16172, longitude:-120.84985))
     
   
   route.append(CLLocation(latitude:47.16169, longitude:-120.84957))
     
   
   route.append(CLLocation(latitude:47.16167, longitude:-120.84937))
     
   
   route.append(CLLocation(latitude:47.16164, longitude:-120.84907))
     
   
   route.append(CLLocation(latitude:47.16161, longitude:-120.84889))
     
   
   route.append(CLLocation(latitude:47.16159, longitude:-120.84874))
     
   
   route.append(CLLocation(latitude:47.16157, longitude:-120.84858))
     
   
   route.append(CLLocation(latitude:47.16155, longitude:-120.84842))
     
   
   route.append(CLLocation(latitude:47.16152, longitude:-120.84826))
     
   
   route.append(CLLocation(latitude:47.1615, longitude:-120.84811))
     
   
   route.append(CLLocation(latitude:47.16147, longitude:-120.84795))
     
   
   route.append(CLLocation(latitude:47.16144, longitude:-120.8478))
     
   
   route.append(CLLocation(latitude:47.16142, longitude:-120.84764))
     
   
   route.append(CLLocation(latitude:47.16139, longitude:-120.84749))
     
   
   route.append(CLLocation(latitude:47.16135, longitude:-120.84734))
     
   
   route.append(CLLocation(latitude:47.16132, longitude:-120.84718))
     
   
   route.append(CLLocation(latitude:47.16129, longitude:-120.84703))
     
   
   route.append(CLLocation(latitude:47.16118, longitude:-120.84657))
     
   
   route.append(CLLocation(latitude:47.16056, longitude:-120.84395))
     
   
   route.append(CLLocation(latitude:47.16031, longitude:-120.84287))
     
   
   route.append(CLLocation(latitude:47.16023, longitude:-120.84253))
     
   
   route.append(CLLocation(latitude:47.15971, longitude:-120.8403))
     
   
   route.append(CLLocation(latitude:47.1588, longitude:-120.83641))
     
   
   route.append(CLLocation(latitude:47.15814, longitude:-120.83358))
     
   
   route.append(CLLocation(latitude:47.158, longitude:-120.83296))
     
   
   route.append(CLLocation(latitude:47.15782, longitude:-120.83217))
     
   
   route.append(CLLocation(latitude:47.15765, longitude:-120.83148))
     
   
   route.append(CLLocation(latitude:47.15743, longitude:-120.83052))
     
   
   route.append(CLLocation(latitude:47.15732, longitude:-120.83005))
     
   
   route.append(CLLocation(latitude:47.15696, longitude:-120.82851))
     
   
   route.append(CLLocation(latitude:47.15689, longitude:-120.8282))
     
   
   route.append(CLLocation(latitude:47.1568, longitude:-120.82781))
     
   
   route.append(CLLocation(latitude:47.15672, longitude:-120.82751))
     
   
   route.append(CLLocation(latitude:47.15668, longitude:-120.82736))
     
   
   route.append(CLLocation(latitude:47.15664, longitude:-120.82721))
     
   
   route.append(CLLocation(latitude:47.1566, longitude:-120.82706))
     
   
   route.append(CLLocation(latitude:47.15656, longitude:-120.82692))
     
   
   route.append(CLLocation(latitude:47.15651, longitude:-120.82677))
     
   
   route.append(CLLocation(latitude:47.15647, longitude:-120.82663))
     
   
   route.append(CLLocation(latitude:47.15642, longitude:-120.82648))
     
   
   route.append(CLLocation(latitude:47.15637, longitude:-120.82634))
     
   
   route.append(CLLocation(latitude:47.15632, longitude:-120.8262))
     
   
   route.append(CLLocation(latitude:47.15627, longitude:-120.82605))
     
   
   route.append(CLLocation(latitude:47.15621, longitude:-120.82591))
     
   
   route.append(CLLocation(latitude:47.15616, longitude:-120.82578))
     
   
   route.append(CLLocation(latitude:47.1561, longitude:-120.82564))
     
   
   route.append(CLLocation(latitude:47.15604, longitude:-120.8255))
     
   
   route.append(CLLocation(latitude:47.15599, longitude:-120.82536))
     
   
   route.append(CLLocation(latitude:47.15593, longitude:-120.82523))
     
   
   route.append(CLLocation(latitude:47.15587, longitude:-120.8251))
     
   
   route.append(CLLocation(latitude:47.1558, longitude:-120.82496))
     
   
   route.append(CLLocation(latitude:47.15574, longitude:-120.82483))
     
   
   route.append(CLLocation(latitude:47.15568, longitude:-120.82471))
     
   
   route.append(CLLocation(latitude:47.15561, longitude:-120.82458))
     
   
   route.append(CLLocation(latitude:47.15554, longitude:-120.82445))
     
   
   route.append(CLLocation(latitude:47.15548, longitude:-120.82433))
     
   
   route.append(CLLocation(latitude:47.15541, longitude:-120.82421))
     
   
   route.append(CLLocation(latitude:47.15534, longitude:-120.82408))
     
   
   route.append(CLLocation(latitude:47.15519, longitude:-120.82384))
     
   
   route.append(CLLocation(latitude:47.15512, longitude:-120.82374))
     
   
   route.append(CLLocation(latitude:47.15504, longitude:-120.82361))
     
   
   route.append(CLLocation(latitude:47.15497, longitude:-120.82349))
     
   
   route.append(CLLocation(latitude:47.15489, longitude:-120.82338))
     
   
   route.append(CLLocation(latitude:47.15473, longitude:-120.82316))
     
   
   route.append(CLLocation(latitude:47.15448, longitude:-120.82284))
     
   
   route.append(CLLocation(latitude:47.15433, longitude:-120.82265))
     
   
   route.append(CLLocation(latitude:47.15416, longitude:-120.82246))
     
   
   route.append(CLLocation(latitude:47.15399, longitude:-120.82227))
     
   
   route.append(CLLocation(latitude:47.1539, longitude:-120.82217))
     
   
   route.append(CLLocation(latitude:47.15381, longitude:-120.82208))
     
   
   route.append(CLLocation(latitude:47.15353, longitude:-120.82182))
     
   
   route.append(CLLocation(latitude:47.15335, longitude:-120.82165))
     
   
   route.append(CLLocation(latitude:47.15296, longitude:-120.82133))
     
   
   route.append(CLLocation(latitude:47.15098, longitude:-120.81965))
     
   
   route.append(CLLocation(latitude:47.15021, longitude:-120.81899))
     
   
   route.append(CLLocation(latitude:47.14973, longitude:-120.81858))
     
   
   route.append(CLLocation(latitude:47.14955, longitude:-120.81842))
     
   
   route.append(CLLocation(latitude:47.14936, longitude:-120.81826))
     
   
   route.append(CLLocation(latitude:47.14917, longitude:-120.8181))
     
   
   route.append(CLLocation(latitude:47.14898, longitude:-120.81794))
     
   
   route.append(CLLocation(latitude:47.14881, longitude:-120.8178))
     
   
   route.append(CLLocation(latitude:47.14869, longitude:-120.8177))
     
   
   route.append(CLLocation(latitude:47.14853, longitude:-120.81756))
     
   
   route.append(CLLocation(latitude:47.14841, longitude:-120.81746))
     
   
   route.append(CLLocation(latitude:47.14831, longitude:-120.81738))
     
   
   route.append(CLLocation(latitude:47.14822, longitude:-120.8173))
     
   
   route.append(CLLocation(latitude:47.14813, longitude:-120.81722))
     
   
   route.append(CLLocation(latitude:47.14803, longitude:-120.81714))
     
   
   route.append(CLLocation(latitude:47.14793, longitude:-120.81706))
     
   
   route.append(CLLocation(latitude:47.14784, longitude:-120.81699))
     
   
   route.append(CLLocation(latitude:47.14775, longitude:-120.81691))
     
   
   route.append(CLLocation(latitude:47.14765, longitude:-120.81684))
     
   
   route.append(CLLocation(latitude:47.14755, longitude:-120.81677))
     
   
   route.append(CLLocation(latitude:47.14745, longitude:-120.81669))
     
   
   route.append(CLLocation(latitude:47.14735, longitude:-120.81662))
     
   
   route.append(CLLocation(latitude:47.14725, longitude:-120.81655))
     
   
   route.append(CLLocation(latitude:47.14716, longitude:-120.81648))
     
   
   route.append(CLLocation(latitude:47.14706, longitude:-120.81642))
     
   
   route.append(CLLocation(latitude:47.14696, longitude:-120.81635))
     
   
   route.append(CLLocation(latitude:47.14685, longitude:-120.81628))
     
   
   route.append(CLLocation(latitude:47.14676, longitude:-120.81621))
     
   
   route.append(CLLocation(latitude:47.14666, longitude:-120.81615))
     
   
   route.append(CLLocation(latitude:47.14656, longitude:-120.81609))
     
   
   route.append(CLLocation(latitude:47.14646, longitude:-120.81603))
     
   
   route.append(CLLocation(latitude:47.14636, longitude:-120.81596))
     
   
   route.append(CLLocation(latitude:47.14625, longitude:-120.8159))
     
   
   route.append(CLLocation(latitude:47.14607, longitude:-120.8158))
     
   
   route.append(CLLocation(latitude:47.14587, longitude:-120.81568))
     
   
   route.append(CLLocation(latitude:47.14566, longitude:-120.81557))
     
   
   route.append(CLLocation(latitude:47.14546, longitude:-120.81547))
     
   
   route.append(CLLocation(latitude:47.14516, longitude:-120.81533))
     
   
   route.append(CLLocation(latitude:47.14433, longitude:-120.81495))
     
   
   route.append(CLLocation(latitude:47.13299, longitude:-120.8099))
     
   
   route.append(CLLocation(latitude:47.13278, longitude:-120.80981))
     
   
   route.append(CLLocation(latitude:47.13268, longitude:-120.80976))
     
   
   route.append(CLLocation(latitude:47.13258, longitude:-120.80971))
     
   
   route.append(CLLocation(latitude:47.13247, longitude:-120.80966))
     
   
   route.append(CLLocation(latitude:47.13237, longitude:-120.80961))
     
   
   route.append(CLLocation(latitude:47.13226, longitude:-120.80955))
     
   
   route.append(CLLocation(latitude:47.13216, longitude:-120.8095))
     
   
   route.append(CLLocation(latitude:47.13206, longitude:-120.80944))
     
   
   route.append(CLLocation(latitude:47.13196, longitude:-120.80938))
     
   
   route.append(CLLocation(latitude:47.13176, longitude:-120.80924))
     
   
   route.append(CLLocation(latitude:47.13166, longitude:-120.80917))
     
   
   route.append(CLLocation(latitude:47.13157, longitude:-120.8091))
     
   
   route.append(CLLocation(latitude:47.1314, longitude:-120.80895))
     
   
   route.append(CLLocation(latitude:47.13128, longitude:-120.80885))
     
   
   route.append(CLLocation(latitude:47.13119, longitude:-120.80877))
     
   
   route.append(CLLocation(latitude:47.1311, longitude:-120.80868))
     
   
   route.append(CLLocation(latitude:47.13101, longitude:-120.80858))
     
   
   route.append(CLLocation(latitude:47.13085, longitude:-120.80841))
     
   
   route.append(CLLocation(latitude:47.13068, longitude:-120.80821))
     
   
   route.append(CLLocation(latitude:47.1306, longitude:-120.8081))
     
   
   route.append(CLLocation(latitude:47.13052, longitude:-120.808))
     
   
   route.append(CLLocation(latitude:47.13043, longitude:-120.80787))
     
   
   route.append(CLLocation(latitude:47.13029, longitude:-120.80766))
     
   
   route.append(CLLocation(latitude:47.13015, longitude:-120.80744))
     
   
   route.append(CLLocation(latitude:47.13005, longitude:-120.80728))
     
   
   route.append(CLLocation(latitude:47.12998, longitude:-120.80716))
     
   
   route.append(CLLocation(latitude:47.12979, longitude:-120.8068))
     
   
   route.append(CLLocation(latitude:47.12953, longitude:-120.80628))
     
   
   route.append(CLLocation(latitude:47.12933, longitude:-120.80588))
     
   
   route.append(CLLocation(latitude:47.12914, longitude:-120.80552))
     
   
   route.append(CLLocation(latitude:47.129, longitude:-120.80527))
     
   
   route.append(CLLocation(latitude:47.12886, longitude:-120.80503))
     
   
   route.append(CLLocation(latitude:47.12872, longitude:-120.8048))
     
   
   route.append(CLLocation(latitude:47.12864, longitude:-120.80468))
     
   
   route.append(CLLocation(latitude:47.12856, longitude:-120.80457))
     
   
   route.append(CLLocation(latitude:47.12848, longitude:-120.80447))
     
   
   route.append(CLLocation(latitude:47.12839, longitude:-120.80436))
     
   
   route.append(CLLocation(latitude:47.12831, longitude:-120.80426))
     
   
   route.append(CLLocation(latitude:47.12822, longitude:-120.80416))
     
   
   route.append(CLLocation(latitude:47.12813, longitude:-120.80406))
     
   
   route.append(CLLocation(latitude:47.12795, longitude:-120.80389))
     
   
   route.append(CLLocation(latitude:47.12786, longitude:-120.8038))
     
   
   route.append(CLLocation(latitude:47.12776, longitude:-120.80372))
     
   
   route.append(CLLocation(latitude:47.12767, longitude:-120.80364))
     
   
   route.append(CLLocation(latitude:47.12757, longitude:-120.80357))
     
   
   route.append(CLLocation(latitude:47.12748, longitude:-120.80349))
     
   
   route.append(CLLocation(latitude:47.12737, longitude:-120.80343))
     
   
   route.append(CLLocation(latitude:47.12724, longitude:-120.80337))
     
   
   route.append(CLLocation(latitude:47.12723, longitude:-120.80336))
     
   
   route.append(CLLocation(latitude:47.12702, longitude:-120.80325))
     
   
   route.append(CLLocation(latitude:47.12694, longitude:-120.8032))
     
   
   route.append(CLLocation(latitude:47.12683, longitude:-120.80315))
     
   
   route.append(CLLocation(latitude:47.12674, longitude:-120.80311))
     
   
   route.append(CLLocation(latitude:47.12664, longitude:-120.80306))
     
   
   route.append(CLLocation(latitude:47.1265, longitude:-120.803))
     
   
   route.append(CLLocation(latitude:47.12644, longitude:-120.80297))
     
   
   route.append(CLLocation(latitude:47.1263, longitude:-120.80291))
     
   
   route.append(CLLocation(latitude:47.1261, longitude:-120.80283))
     
   
   route.append(CLLocation(latitude:47.12596, longitude:-120.80278))
     
   
   route.append(CLLocation(latitude:47.12585, longitude:-120.80273))
     
   
   route.append(CLLocation(latitude:47.12572, longitude:-120.80268))
     
   
   route.append(CLLocation(latitude:47.12558, longitude:-120.80262))
     
   
   route.append(CLLocation(latitude:47.12547, longitude:-120.80258))
     
   
   route.append(CLLocation(latitude:47.12536, longitude:-120.80252))
     
   
   route.append(CLLocation(latitude:47.12514, longitude:-120.80243))
     
   
   route.append(CLLocation(latitude:47.12496, longitude:-120.80236))
     
   
   route.append(CLLocation(latitude:47.1248, longitude:-120.80229))
     
   
   route.append(CLLocation(latitude:47.12462, longitude:-120.80221))
     
   
   route.append(CLLocation(latitude:47.12451, longitude:-120.80216))
     
   
   route.append(CLLocation(latitude:47.12443, longitude:-120.80212))
     
   
   route.append(CLLocation(latitude:47.12423, longitude:-120.80204))
     
   
   route.append(CLLocation(latitude:47.12411, longitude:-120.80198))
     
   
   route.append(CLLocation(latitude:47.12391, longitude:-120.80189))
     
   
   route.append(CLLocation(latitude:47.12373, longitude:-120.8018))
     
   
   route.append(CLLocation(latitude:47.1233, longitude:-120.80163))
     
   
   route.append(CLLocation(latitude:47.12296, longitude:-120.80149))
     
   
   route.append(CLLocation(latitude:47.12264, longitude:-120.80135))
     
   
   route.append(CLLocation(latitude:47.12241, longitude:-120.80126))
     
   
   route.append(CLLocation(latitude:47.12211, longitude:-120.80113))
     
   
   route.append(CLLocation(latitude:47.12179, longitude:-120.801))
     
   
   route.append(CLLocation(latitude:47.12152, longitude:-120.80089))
     
   
   route.append(CLLocation(latitude:47.12116, longitude:-120.80074))
     
   
   route.append(CLLocation(latitude:47.12073, longitude:-120.80055))
     
   
   route.append(CLLocation(latitude:47.12024, longitude:-120.80035))
     
   
   route.append(CLLocation(latitude:47.11963, longitude:-120.80009))
     
   
   route.append(CLLocation(latitude:47.11939, longitude:-120.79998))
     
   
   route.append(CLLocation(latitude:47.11918, longitude:-120.79988))
     
   
   route.append(CLLocation(latitude:47.11888, longitude:-120.79973))
     
   
   route.append(CLLocation(latitude:47.1188, longitude:-120.79969))
     
   
   route.append(CLLocation(latitude:47.11873, longitude:-120.79965))
     
   
   route.append(CLLocation(latitude:47.1186, longitude:-120.79957))
     
   
   route.append(CLLocation(latitude:47.11849, longitude:-120.79949))
     
   
   route.append(CLLocation(latitude:47.11831, longitude:-120.79935))
     
   
   route.append(CLLocation(latitude:47.11816, longitude:-120.79925))
     
   
   route.append(CLLocation(latitude:47.11804, longitude:-120.79914))
     
   
   route.append(CLLocation(latitude:47.1179, longitude:-120.79901))
     
   
   route.append(CLLocation(latitude:47.11774, longitude:-120.79886))
     
   
   route.append(CLLocation(latitude:47.11754, longitude:-120.79864))
     
   
   route.append(CLLocation(latitude:47.11744, longitude:-120.79852))
     
   
   route.append(CLLocation(latitude:47.11732, longitude:-120.79838))
     
   
   route.append(CLLocation(latitude:47.11715, longitude:-120.79815))
     
   
   route.append(CLLocation(latitude:47.11704, longitude:-120.798))
     
   
   route.append(CLLocation(latitude:47.11683, longitude:-120.79767))
     
   
   route.append(CLLocation(latitude:47.11669, longitude:-120.79743))
     
   
   route.append(CLLocation(latitude:47.11658, longitude:-120.79721))
     
   
   route.append(CLLocation(latitude:47.11643, longitude:-120.7969))
     
   
   route.append(CLLocation(latitude:47.11624, longitude:-120.79649))
     
   
   route.append(CLLocation(latitude:47.11616, longitude:-120.79628))
     
   
   route.append(CLLocation(latitude:47.11609, longitude:-120.7961))
     
   
   route.append(CLLocation(latitude:47.11603, longitude:-120.79593))
     
   
   route.append(CLLocation(latitude:47.11592, longitude:-120.79558))
     
   
   route.append(CLLocation(latitude:47.11584, longitude:-120.79536))
     
   
   route.append(CLLocation(latitude:47.1158, longitude:-120.7952))
     
   
   route.append(CLLocation(latitude:47.11576, longitude:-120.7951))
     
   
   route.append(CLLocation(latitude:47.11562, longitude:-120.79463))
     
   
   route.append(CLLocation(latitude:47.1154, longitude:-120.79391))
     
   
   route.append(CLLocation(latitude:47.11513, longitude:-120.79304))
     
   
   route.append(CLLocation(latitude:47.1149, longitude:-120.7923))
     
   
   route.append(CLLocation(latitude:47.11472, longitude:-120.79173))
     
   
   route.append(CLLocation(latitude:47.11417, longitude:-120.78995))
     
   
   route.append(CLLocation(latitude:47.11312, longitude:-120.78658))
     
   
   route.append(CLLocation(latitude:47.11286, longitude:-120.78573))
     
   
   route.append(CLLocation(latitude:47.11245, longitude:-120.78439))
     
   
   route.append(CLLocation(latitude:47.11215, longitude:-120.78339))
     
   
   route.append(CLLocation(latitude:47.11186, longitude:-120.78247))
     
   
   route.append(CLLocation(latitude:47.1112, longitude:-120.78035))
     
   
   route.append(CLLocation(latitude:47.11074, longitude:-120.77887))
     
   
   route.append(CLLocation(latitude:47.11046, longitude:-120.77794))
     
   
   route.append(CLLocation(latitude:47.1101, longitude:-120.77681))
     
   
   route.append(CLLocation(latitude:47.10979, longitude:-120.77579))
     
   
   route.append(CLLocation(latitude:47.10934, longitude:-120.77432))
     
   
   route.append(CLLocation(latitude:47.1089, longitude:-120.7729))
     
   
   route.append(CLLocation(latitude:47.10862, longitude:-120.77201))
     
   
   route.append(CLLocation(latitude:47.10831, longitude:-120.77098))
     
   
   route.append(CLLocation(latitude:47.10794, longitude:-120.7698))
     
   
   route.append(CLLocation(latitude:47.10778, longitude:-120.76936))
     
   
   route.append(CLLocation(latitude:47.10763, longitude:-120.76896))
     
   
   route.append(CLLocation(latitude:47.1074, longitude:-120.76843))
     
   
   route.append(CLLocation(latitude:47.10719, longitude:-120.76799))
     
   
   route.append(CLLocation(latitude:47.10708, longitude:-120.76777))
     
   
   route.append(CLLocation(latitude:47.10696, longitude:-120.76755))
     
   
   route.append(CLLocation(latitude:47.10688, longitude:-120.7674))
     
   
   route.append(CLLocation(latitude:47.10678, longitude:-120.76723))
     
   
   route.append(CLLocation(latitude:47.10659, longitude:-120.76692))
     
   
   route.append(CLLocation(latitude:47.10645, longitude:-120.7667))
     
   
   route.append(CLLocation(latitude:47.1062, longitude:-120.76635))
     
   
   route.append(CLLocation(latitude:47.10596, longitude:-120.76603))
     
   
   route.append(CLLocation(latitude:47.10584, longitude:-120.76589))
     
   
   route.append(CLLocation(latitude:47.10569, longitude:-120.76571))
     
   
   route.append(CLLocation(latitude:47.10548, longitude:-120.76548))
     
   
   route.append(CLLocation(latitude:47.10539, longitude:-120.76538))
     
   
   route.append(CLLocation(latitude:47.10518, longitude:-120.76517))
     
   
   route.append(CLLocation(latitude:47.10505, longitude:-120.76504))
     
   
   route.append(CLLocation(latitude:47.10491, longitude:-120.76492))
     
   
   route.append(CLLocation(latitude:47.10467, longitude:-120.76472))
     
   
   route.append(CLLocation(latitude:47.1045, longitude:-120.76458))
     
   
   route.append(CLLocation(latitude:47.10437, longitude:-120.76448))
     
   
   route.append(CLLocation(latitude:47.10417, longitude:-120.76434))
     
   
   route.append(CLLocation(latitude:47.10403, longitude:-120.76424))
     
   
   route.append(CLLocation(latitude:47.10381, longitude:-120.76411))
     
   
   route.append(CLLocation(latitude:47.10363, longitude:-120.764))
     
   
   route.append(CLLocation(latitude:47.10347, longitude:-120.76392))
     
   
   route.append(CLLocation(latitude:47.10312, longitude:-120.76375))
     
   
   route.append(CLLocation(latitude:47.10291, longitude:-120.76365))
     
   
   route.append(CLLocation(latitude:47.1027, longitude:-120.76355))
     
   
   route.append(CLLocation(latitude:47.10229, longitude:-120.76337))
     
   
   route.append(CLLocation(latitude:47.10216, longitude:-120.76331))
     
   
   route.append(CLLocation(latitude:47.10176, longitude:-120.76313))
     
   
   route.append(CLLocation(latitude:47.10135, longitude:-120.76295))
     
   
   route.append(CLLocation(latitude:47.10088, longitude:-120.76274))
     
   
   route.append(CLLocation(latitude:47.10042, longitude:-120.76254))
     
   
   route.append(CLLocation(latitude:47.09998, longitude:-120.76234))
     
   
   route.append(CLLocation(latitude:47.0997, longitude:-120.76222))
     
   
   route.append(CLLocation(latitude:47.09946, longitude:-120.76211))
     
   
   route.append(CLLocation(latitude:47.09905, longitude:-120.76193))
     
   
   route.append(CLLocation(latitude:47.09852, longitude:-120.76169))
     
   
   route.append(CLLocation(latitude:47.09831, longitude:-120.76159))
     
   
   route.append(CLLocation(latitude:47.09791, longitude:-120.7614))
     
   
   route.append(CLLocation(latitude:47.09778, longitude:-120.76134))
     
   
   route.append(CLLocation(latitude:47.09753, longitude:-120.76121))
     
   
   route.append(CLLocation(latitude:47.09723, longitude:-120.76102))
     
   
   route.append(CLLocation(latitude:47.09712, longitude:-120.76094))
     
   
   route.append(CLLocation(latitude:47.09705, longitude:-120.76089))
     
   
   route.append(CLLocation(latitude:47.09695, longitude:-120.7608))
     
   
   route.append(CLLocation(latitude:47.09686, longitude:-120.76072))
     
   
   route.append(CLLocation(latitude:47.09665, longitude:-120.76052))
     
   
   route.append(CLLocation(latitude:47.09634, longitude:-120.76023))
     
   
   route.append(CLLocation(latitude:47.09613, longitude:-120.76))
     
   
   route.append(CLLocation(latitude:47.09581, longitude:-120.75961))
     
   
   route.append(CLLocation(latitude:47.09563, longitude:-120.75937))
     
   
   route.append(CLLocation(latitude:47.09538, longitude:-120.759))
     
   
   route.append(CLLocation(latitude:47.09511, longitude:-120.75857))
     
   
   route.append(CLLocation(latitude:47.09496, longitude:-120.75833))
     
   
   route.append(CLLocation(latitude:47.09481, longitude:-120.75809))
     
   
   route.append(CLLocation(latitude:47.09453, longitude:-120.75764))
     
   
   route.append(CLLocation(latitude:47.09431, longitude:-120.75729))
     
   
   route.append(CLLocation(latitude:47.09408, longitude:-120.75692))
     
   
   route.append(CLLocation(latitude:47.09395, longitude:-120.75672))
     
   
   route.append(CLLocation(latitude:47.09379, longitude:-120.75646))
     
   
   route.append(CLLocation(latitude:47.09364, longitude:-120.75622))
     
   
   route.append(CLLocation(latitude:47.09344, longitude:-120.75589))
     
   
   route.append(CLLocation(latitude:47.09327, longitude:-120.75562))
     
   
   route.append(CLLocation(latitude:47.09308, longitude:-120.75526))
     
   
   route.append(CLLocation(latitude:47.09302, longitude:-120.75512))
     
   
   route.append(CLLocation(latitude:47.09289, longitude:-120.75487))
     
   
   route.append(CLLocation(latitude:47.09278, longitude:-120.75461))
     
   
   route.append(CLLocation(latitude:47.09272, longitude:-120.75446))
     
   
   route.append(CLLocation(latitude:47.09266, longitude:-120.7543))
     
   
   route.append(CLLocation(latitude:47.09261, longitude:-120.75416))
     
   
   route.append(CLLocation(latitude:47.09253, longitude:-120.7539))
     
   
   route.append(CLLocation(latitude:47.09246, longitude:-120.75369))
     
   
   route.append(CLLocation(latitude:47.09238, longitude:-120.7534))
     
   
   route.append(CLLocation(latitude:47.09232, longitude:-120.75317))
     
   
   route.append(CLLocation(latitude:47.09228, longitude:-120.75297))
     
   
   route.append(CLLocation(latitude:47.09223, longitude:-120.75271))
     
   
   route.append(CLLocation(latitude:47.09219, longitude:-120.75252))
     
   
   route.append(CLLocation(latitude:47.09215, longitude:-120.75225))
     
   
   route.append(CLLocation(latitude:47.09212, longitude:-120.75206))
     
   
   route.append(CLLocation(latitude:47.09207, longitude:-120.75162))
     
   
   route.append(CLLocation(latitude:47.09203, longitude:-120.75131))
     
   
   route.append(CLLocation(latitude:47.09201, longitude:-120.75109))
     
   
   route.append(CLLocation(latitude:47.09196, longitude:-120.75069))
     
   
   route.append(CLLocation(latitude:47.09193, longitude:-120.75036))
     
   
   route.append(CLLocation(latitude:47.0919, longitude:-120.75006))
     
   
   route.append(CLLocation(latitude:47.09188, longitude:-120.74989))
     
   
   route.append(CLLocation(latitude:47.09183, longitude:-120.74951))
     
   
   route.append(CLLocation(latitude:47.09181, longitude:-120.74937))
     
   
   route.append(CLLocation(latitude:47.09178, longitude:-120.74916))
     
   
   route.append(CLLocation(latitude:47.09173, longitude:-120.74892))
     
   
   route.append(CLLocation(latitude:47.0917, longitude:-120.74878))
     
   
   route.append(CLLocation(latitude:47.09164, longitude:-120.74848))
     
   
   route.append(CLLocation(latitude:47.09154, longitude:-120.74805))
     
   
   route.append(CLLocation(latitude:47.09149, longitude:-120.74786))
     
   
   route.append(CLLocation(latitude:47.0914, longitude:-120.74758))
     
   
   route.append(CLLocation(latitude:47.09135, longitude:-120.74741))
     
   
   route.append(CLLocation(latitude:47.09132, longitude:-120.74731))
     
   
   route.append(CLLocation(latitude:47.09122, longitude:-120.74703))
     
   
   route.append(CLLocation(latitude:47.09111, longitude:-120.74672))
     
   
   route.append(CLLocation(latitude:47.09101, longitude:-120.7465))
     
   
   route.append(CLLocation(latitude:47.09095, longitude:-120.74635))
     
   
   route.append(CLLocation(latitude:47.09088, longitude:-120.74619))
     
   
   route.append(CLLocation(latitude:47.09076, longitude:-120.74594))
     
   
   route.append(CLLocation(latitude:47.0907, longitude:-120.74581))
     
   
   route.append(CLLocation(latitude:47.09057, longitude:-120.74556))
     
   
   route.append(CLLocation(latitude:47.09043, longitude:-120.74532))
     
   
   route.append(CLLocation(latitude:47.09034, longitude:-120.74516))
     
   
   route.append(CLLocation(latitude:47.09027, longitude:-120.74506))
     
   
   route.append(CLLocation(latitude:47.09021, longitude:-120.74497))
     
   
   route.append(CLLocation(latitude:47.09012, longitude:-120.74484))
     
   
   route.append(CLLocation(latitude:47.08995, longitude:-120.74459))
     
   
   route.append(CLLocation(latitude:47.0899, longitude:-120.74451))
     
   
   route.append(CLLocation(latitude:47.08981, longitude:-120.74438))
     
   
   route.append(CLLocation(latitude:47.08972, longitude:-120.74427))
     
   
   route.append(CLLocation(latitude:47.08965, longitude:-120.74417))
     
   
   route.append(CLLocation(latitude:47.08954, longitude:-120.74404))
     
   
   route.append(CLLocation(latitude:47.08947, longitude:-120.74396))
     
   
   route.append(CLLocation(latitude:47.08939, longitude:-120.74387))
     
   
   route.append(CLLocation(latitude:47.08927, longitude:-120.74374))
     
   
   route.append(CLLocation(latitude:47.0892, longitude:-120.74366))
     
   
   route.append(CLLocation(latitude:47.08909, longitude:-120.74355))
     
   
   route.append(CLLocation(latitude:47.08891, longitude:-120.74338))
     
   
   route.append(CLLocation(latitude:47.08878, longitude:-120.74327))
     
   
   route.append(CLLocation(latitude:47.08857, longitude:-120.74309))
     
   
   route.append(CLLocation(latitude:47.08842, longitude:-120.74298))
     
   
   route.append(CLLocation(latitude:47.0882, longitude:-120.74282))
     
   
   route.append(CLLocation(latitude:47.0881, longitude:-120.74276))
     
   
   route.append(CLLocation(latitude:47.08802, longitude:-120.7427))
     
   
   route.append(CLLocation(latitude:47.08783, longitude:-120.74259))
     
   
   route.append(CLLocation(latitude:47.08757, longitude:-120.74245))
     
   
   route.append(CLLocation(latitude:47.0875, longitude:-120.74241))
     
   
   route.append(CLLocation(latitude:47.08738, longitude:-120.74236))
     
   
   route.append(CLLocation(latitude:47.08726, longitude:-120.7423))
     
   
   route.append(CLLocation(latitude:47.08686, longitude:-120.74212))
     
   
   route.append(CLLocation(latitude:47.08647, longitude:-120.74193))
     
   
   route.append(CLLocation(latitude:47.08611, longitude:-120.74175))
     
   
   route.append(CLLocation(latitude:47.08592, longitude:-120.74165))
     
   
   route.append(CLLocation(latitude:47.08549, longitude:-120.7414))
     
   
   route.append(CLLocation(latitude:47.08543, longitude:-120.74136))
     
   
   route.append(CLLocation(latitude:47.08532, longitude:-120.74128))
     
   
   route.append(CLLocation(latitude:47.08513, longitude:-120.74114))
     
   
   route.append(CLLocation(latitude:47.085, longitude:-120.74104))
     
   
   route.append(CLLocation(latitude:47.0849, longitude:-120.74096))
     
   
   route.append(CLLocation(latitude:47.08482, longitude:-120.74088))
     
   
   route.append(CLLocation(latitude:47.0847, longitude:-120.74078))
     
   
   route.append(CLLocation(latitude:47.08464, longitude:-120.74072))
     
   
   route.append(CLLocation(latitude:47.08457, longitude:-120.74064))
     
   
   route.append(CLLocation(latitude:47.08446, longitude:-120.74053))
     
   
   route.append(CLLocation(latitude:47.08439, longitude:-120.74045))
     
   
   route.append(CLLocation(latitude:47.08429, longitude:-120.74033))
     
   
   route.append(CLLocation(latitude:47.08419, longitude:-120.74022))
     
   
   route.append(CLLocation(latitude:47.08404, longitude:-120.74002))
     
   
   route.append(CLLocation(latitude:47.08388, longitude:-120.73979))
     
   
   route.append(CLLocation(latitude:47.08381, longitude:-120.73969))
     
   
   route.append(CLLocation(latitude:47.08374, longitude:-120.73958))
     
   
   route.append(CLLocation(latitude:47.08359, longitude:-120.73934))
     
   
   route.append(CLLocation(latitude:47.08353, longitude:-120.73923))
     
   
   route.append(CLLocation(latitude:47.08338, longitude:-120.73896))
     
   
   route.append(CLLocation(latitude:47.08331, longitude:-120.73881))
     
   
   route.append(CLLocation(latitude:47.08319, longitude:-120.73856))
     
   
   route.append(CLLocation(latitude:47.08313, longitude:-120.73842))
     
   
   route.append(CLLocation(latitude:47.08307, longitude:-120.73828))
     
   
   route.append(CLLocation(latitude:47.08297, longitude:-120.73802))
     
   
   route.append(CLLocation(latitude:47.08283, longitude:-120.73764))
     
   
   route.append(CLLocation(latitude:47.08265, longitude:-120.73718))
     
   
   route.append(CLLocation(latitude:47.08244, longitude:-120.73661))
     
   
   route.append(CLLocation(latitude:47.08224, longitude:-120.73606))
     
   
   route.append(CLLocation(latitude:47.08207, longitude:-120.73563))
     
   
   route.append(CLLocation(latitude:47.08192, longitude:-120.7352))
     
   
   route.append(CLLocation(latitude:47.08176, longitude:-120.73478))
     
   
   route.append(CLLocation(latitude:47.0816, longitude:-120.73435))
     
   
   route.append(CLLocation(latitude:47.0815, longitude:-120.7341))
     
   
   route.append(CLLocation(latitude:47.08133, longitude:-120.73365))
     
   
   route.append(CLLocation(latitude:47.08114, longitude:-120.73311))
     
   
   route.append(CLLocation(latitude:47.08103, longitude:-120.73278))
     
   
   route.append(CLLocation(latitude:47.08086, longitude:-120.73223))
     
   
   route.append(CLLocation(latitude:47.08073, longitude:-120.7318))
     
   
   route.append(CLLocation(latitude:47.08066, longitude:-120.73154))
     
   
   route.append(CLLocation(latitude:47.08049, longitude:-120.7309))
     
   
   route.append(CLLocation(latitude:47.08026, longitude:-120.72996))
     
   
   route.append(CLLocation(latitude:47.08006, longitude:-120.72906))
     
   
   route.append(CLLocation(latitude:47.07973, longitude:-120.7277))
     
   
   route.append(CLLocation(latitude:47.07958, longitude:-120.72705))
     
   
   route.append(CLLocation(latitude:47.0795, longitude:-120.72669))
     
   
   route.append(CLLocation(latitude:47.07931, longitude:-120.72589))
     
   
   route.append(CLLocation(latitude:47.07916, longitude:-120.72526))
     
   
   route.append(CLLocation(latitude:47.07903, longitude:-120.72476))
     
   
   route.append(CLLocation(latitude:47.07897, longitude:-120.72457))
     
   
   route.append(CLLocation(latitude:47.0789, longitude:-120.72434))
     
   
   route.append(CLLocation(latitude:47.07881, longitude:-120.72409))
     
   
   route.append(CLLocation(latitude:47.07873, longitude:-120.72387))
     
   
   route.append(CLLocation(latitude:47.07865, longitude:-120.72366))
     
   
   route.append(CLLocation(latitude:47.07856, longitude:-120.72346))
     
   
   route.append(CLLocation(latitude:47.07848, longitude:-120.72329))
     
   
   route.append(CLLocation(latitude:47.07831, longitude:-120.72296))
     
   
   route.append(CLLocation(latitude:47.07818, longitude:-120.72272))
     
   
   route.append(CLLocation(latitude:47.07801, longitude:-120.72243))
     
   
   route.append(CLLocation(latitude:47.07785, longitude:-120.72217))
     
   
   route.append(CLLocation(latitude:47.07757, longitude:-120.72172))
     
   
   route.append(CLLocation(latitude:47.07722, longitude:-120.72116))
     
   
   route.append(CLLocation(latitude:47.07691, longitude:-120.72067))
     
   
   route.append(CLLocation(latitude:47.0766, longitude:-120.72018))
     
   
   route.append(CLLocation(latitude:47.07635, longitude:-120.71977))
     
   
   route.append(CLLocation(latitude:47.07587, longitude:-120.719))
     
   
   route.append(CLLocation(latitude:47.07557, longitude:-120.71849))
     
   
   route.append(CLLocation(latitude:47.07526, longitude:-120.71795))
     
   
   route.append(CLLocation(latitude:47.07501, longitude:-120.71747))
     
   
   route.append(CLLocation(latitude:47.07468, longitude:-120.71679))
     
   
   route.append(CLLocation(latitude:47.07422, longitude:-120.71582))
     
   
   route.append(CLLocation(latitude:47.07371, longitude:-120.71475))
     
   
   route.append(CLLocation(latitude:47.07324, longitude:-120.71377))
     
   
   route.append(CLLocation(latitude:47.07288, longitude:-120.71302))
     
   
   route.append(CLLocation(latitude:47.07235, longitude:-120.7119))
     
   
   route.append(CLLocation(latitude:47.07206, longitude:-120.7113))
     
   
   route.append(CLLocation(latitude:47.07189, longitude:-120.71094))
     
   
   route.append(CLLocation(latitude:47.07151, longitude:-120.71014))
     
   
   route.append(CLLocation(latitude:47.07102, longitude:-120.70911))
     
   
   route.append(CLLocation(latitude:47.07076, longitude:-120.70858))
     
   
   route.append(CLLocation(latitude:47.07019, longitude:-120.70736))
     
   
   route.append(CLLocation(latitude:47.06981, longitude:-120.70659))
     
   
   route.append(CLLocation(latitude:47.0694, longitude:-120.70573))
     
   
   route.append(CLLocation(latitude:47.06864, longitude:-120.70413))
     
   
   route.append(CLLocation(latitude:47.06693, longitude:-120.70055))
     
   
   route.append(CLLocation(latitude:47.06551, longitude:-120.6976))
     
   
   route.append(CLLocation(latitude:47.06524, longitude:-120.69704))
     
   
   route.append(CLLocation(latitude:47.06474, longitude:-120.69599))
     
   
   route.append(CLLocation(latitude:47.0643, longitude:-120.69508))
     
   
   route.append(CLLocation(latitude:47.06388, longitude:-120.69419))
     
   
   route.append(CLLocation(latitude:47.06355, longitude:-120.69349))
     
   
   route.append(CLLocation(latitude:47.06338, longitude:-120.69314))
     
   
   route.append(CLLocation(latitude:47.06318, longitude:-120.69271))
     
   
   route.append(CLLocation(latitude:47.0629, longitude:-120.69204))
     
   
   route.append(CLLocation(latitude:47.06262, longitude:-120.69133))
     
   
   route.append(CLLocation(latitude:47.06241, longitude:-120.69075))
     
   
   route.append(CLLocation(latitude:47.06213, longitude:-120.68995))
     
   
   route.append(CLLocation(latitude:47.06077, longitude:-120.68589))
     
   
   route.append(CLLocation(latitude:47.05944, longitude:-120.68196))
     
   
   route.append(CLLocation(latitude:47.05838, longitude:-120.67883))
     
   
   route.append(CLLocation(latitude:47.05756, longitude:-120.6764))
     
   
   route.append(CLLocation(latitude:47.05728, longitude:-120.67558))
     
   
   route.append(CLLocation(latitude:47.05578, longitude:-120.67112))
     
   
   route.append(CLLocation(latitude:47.05534, longitude:-120.66983))
     
   
   route.append(CLLocation(latitude:47.05522, longitude:-120.66949))
     
   
   route.append(CLLocation(latitude:47.05443, longitude:-120.66713))
     
   
   route.append(CLLocation(latitude:47.05412, longitude:-120.66623))
     
   
   route.append(CLLocation(latitude:47.05405, longitude:-120.66602))
     
   
   route.append(CLLocation(latitude:47.05378, longitude:-120.66521))
     
   
   route.append(CLLocation(latitude:47.05331, longitude:-120.66383))
     
   
   route.append(CLLocation(latitude:47.05263, longitude:-120.66181))
     
   
   route.append(CLLocation(latitude:47.05246, longitude:-120.6613))
     
   
   route.append(CLLocation(latitude:47.05204, longitude:-120.66006))
     
   
   route.append(CLLocation(latitude:47.05127, longitude:-120.65777))
     
   
   route.append(CLLocation(latitude:47.0508, longitude:-120.65638))
     
   
   route.append(CLLocation(latitude:47.05059, longitude:-120.65579))
     
   
   route.append(CLLocation(latitude:47.05018, longitude:-120.65468))
     
   
   route.append(CLLocation(latitude:47.04931, longitude:-120.65249))
     
   
   route.append(CLLocation(latitude:47.04755, longitude:-120.64812))
     
   
   route.append(CLLocation(latitude:47.04664, longitude:-120.64585))
     
   
   route.append(CLLocation(latitude:47.04402, longitude:-120.6393))
     
   
   route.append(CLLocation(latitude:47.04356, longitude:-120.63816))
     
   
   route.append(CLLocation(latitude:47.04313, longitude:-120.63708))
     
   
   route.append(CLLocation(latitude:47.04287, longitude:-120.63643))
     
   
   route.append(CLLocation(latitude:47.04248, longitude:-120.63546))
     
   
   route.append(CLLocation(latitude:47.04215, longitude:-120.63464))
     
   
   route.append(CLLocation(latitude:47.04183, longitude:-120.63383))
     
   
   route.append(CLLocation(latitude:47.0416, longitude:-120.63326))
     
   
   route.append(CLLocation(latitude:47.04127, longitude:-120.63244))
     
   
   route.append(CLLocation(latitude:47.04099, longitude:-120.63174))
     
   
   route.append(CLLocation(latitude:47.04088, longitude:-120.63146))
     
   
   route.append(CLLocation(latitude:47.0407, longitude:-120.63106))
     
   
   route.append(CLLocation(latitude:47.04052, longitude:-120.63067))
     
   
   route.append(CLLocation(latitude:47.04039, longitude:-120.63042))
     
   
   route.append(CLLocation(latitude:47.04025, longitude:-120.63016))
     
   
   route.append(CLLocation(latitude:47.04004, longitude:-120.62981))
     
   
   route.append(CLLocation(latitude:47.0399, longitude:-120.62958))
     
   
   route.append(CLLocation(latitude:47.03959, longitude:-120.62911))
     
   
   route.append(CLLocation(latitude:47.03943, longitude:-120.62889))
     
   
   route.append(CLLocation(latitude:47.03917, longitude:-120.62857))
     
   
   route.append(CLLocation(latitude:47.03892, longitude:-120.62828))
     
   
   route.append(CLLocation(latitude:47.0388, longitude:-120.62814))
     
   
   route.append(CLLocation(latitude:47.03868, longitude:-120.62802))
     
   
   route.append(CLLocation(latitude:47.03838, longitude:-120.62772))
     
   
   route.append(CLLocation(latitude:47.03812, longitude:-120.62749))
     
   
   route.append(CLLocation(latitude:47.03788, longitude:-120.62729))
     
   
   route.append(CLLocation(latitude:47.03766, longitude:-120.62713))
     
   
   route.append(CLLocation(latitude:47.03745, longitude:-120.62698))
     
   
   route.append(CLLocation(latitude:47.03722, longitude:-120.62683))
     
   
   route.append(CLLocation(latitude:47.03694, longitude:-120.62667))
     
   
   route.append(CLLocation(latitude:47.03653, longitude:-120.62645))
     
   
   route.append(CLLocation(latitude:47.0358, longitude:-120.62608))
     
   
   route.append(CLLocation(latitude:47.03538, longitude:-120.62586))
     
   
   route.append(CLLocation(latitude:47.03497, longitude:-120.62563))
     
   
   route.append(CLLocation(latitude:47.03465, longitude:-120.62544))
     
   
   route.append(CLLocation(latitude:47.03423, longitude:-120.62517))
     
   
   route.append(CLLocation(latitude:47.03396, longitude:-120.62498))
     
   
   route.append(CLLocation(latitude:47.03358, longitude:-120.6247))
     
   
   route.append(CLLocation(latitude:47.03339, longitude:-120.62456))
     
   
   route.append(CLLocation(latitude:47.03308, longitude:-120.62431))
     
   
   route.append(CLLocation(latitude:47.03271, longitude:-120.624))
     
   
   route.append(CLLocation(latitude:47.03234, longitude:-120.62367))
     
   
   route.append(CLLocation(latitude:47.03187, longitude:-120.62321))
     
   
   route.append(CLLocation(latitude:47.0317, longitude:-120.62304))
     
   
   route.append(CLLocation(latitude:47.03134, longitude:-120.62266))
     
   
   route.append(CLLocation(latitude:47.031, longitude:-120.62227))
     
   
   route.append(CLLocation(latitude:47.02803, longitude:-120.61886))
     
   
   route.append(CLLocation(latitude:47.02055, longitude:-120.61026))
     
   
   route.append(CLLocation(latitude:47.0197, longitude:-120.60929))
     
   
   route.append(CLLocation(latitude:47.0188, longitude:-120.60826))
     
   
   route.append(CLLocation(latitude:47.01487, longitude:-120.60374))
     
   
   route.append(CLLocation(latitude:47.01413, longitude:-120.6029))
     
   
   route.append(CLLocation(latitude:47.01362, longitude:-120.60227))
     
   
   route.append(CLLocation(latitude:47.0132, longitude:-120.60174))
     
   
   route.append(CLLocation(latitude:47.01281, longitude:-120.60121))
     
   
   route.append(CLLocation(latitude:47.01255, longitude:-120.60088))
     
   
   route.append(CLLocation(latitude:47.01208, longitude:-120.60021))
     
   
   route.append(CLLocation(latitude:47.01146, longitude:-120.59934))
     
   
   route.append(CLLocation(latitude:47.01121, longitude:-120.59897))
     
   
   route.append(CLLocation(latitude:47.0112066, longitude:-120.5989725))
     
   
   route.append(CLLocation(latitude:47.0111, longitude:-120.59892))
     
   
   route.append(CLLocation(latitude:47.01028, longitude:-120.59787))
     
   
   route.append(CLLocation(latitude:47.01011, longitude:-120.59767))
     
   
   route.append(CLLocation(latitude:47.00995, longitude:-120.59751))
     
   
   route.append(CLLocation(latitude:47.00985, longitude:-120.5974))
     
   
   route.append(CLLocation(latitude:47.00971, longitude:-120.59729))
     
   
   route.append(CLLocation(latitude:47.00956, longitude:-120.5972))
     
   
   route.append(CLLocation(latitude:47.00944, longitude:-120.59714))
     
   
   route.append(CLLocation(latitude:47.00925, longitude:-120.59707))
     
   
   route.append(CLLocation(latitude:47.00901, longitude:-120.597))
     
   
   route.append(CLLocation(latitude:47.00875, longitude:-120.59694))
     
   
   route.append(CLLocation(latitude:47.00857, longitude:-120.59689))
     
   
   route.append(CLLocation(latitude:47.00841, longitude:-120.59685))
     
   
   route.append(CLLocation(latitude:47.00825, longitude:-120.59681))
     
   
   route.append(CLLocation(latitude:47.0081, longitude:-120.59674))
     
   
   route.append(CLLocation(latitude:47.00793, longitude:-120.59664))
     
   
   route.append(CLLocation(latitude:47.00778, longitude:-120.59653))
     
   
   route.append(CLLocation(latitude:47.00764, longitude:-120.59641))
     
   
   route.append(CLLocation(latitude:47.00755, longitude:-120.59631))
     
   
   route.append(CLLocation(latitude:47.00747, longitude:-120.59622))
     
   
   route.append(CLLocation(latitude:47.00741, longitude:-120.59614))
     
   
   route.append(CLLocation(latitude:47.00709, longitude:-120.59569))
     
   
   route.append(CLLocation(latitude:47.00707, longitude:-120.59554))
     
   
   route.append(CLLocation(latitude:47.0070682, longitude:-120.5955441))
     
   
   route.append(CLLocation(latitude:47.00686, longitude:-120.59526))
     
   
   route.append(CLLocation(latitude:47.00641, longitude:-120.59463))
     
   
   route.append(CLLocation(latitude:47.00619, longitude:-120.59435))
     
   
   route.append(CLLocation(latitude:47.00609, longitude:-120.59419))
     
   
   route.append(CLLocation(latitude:47.00602, longitude:-120.59408))
     
   
   route.append(CLLocation(latitude:47.00589, longitude:-120.59386))
     
   
   route.append(CLLocation(latitude:47.00579, longitude:-120.59355))
     
   
   route.append(CLLocation(latitude:47.00572, longitude:-120.59335))
     
   
   route.append(CLLocation(latitude:47.00566, longitude:-120.59308))
     
   
   route.append(CLLocation(latitude:47.00562, longitude:-120.59284))
     
   
   route.append(CLLocation(latitude:47.0056, longitude:-120.59263))
     
   
   route.append(CLLocation(latitude:47.00559, longitude:-120.59241))
     
   
   route.append(CLLocation(latitude:47.00559, longitude:-120.59223))
     
   
   route.append(CLLocation(latitude:47.0056, longitude:-120.592))
     
   
   route.append(CLLocation(latitude:47.00562, longitude:-120.5918))
     
   
   route.append(CLLocation(latitude:47.00564, longitude:-120.59164))
     
   
   route.append(CLLocation(latitude:47.00591, longitude:-120.59005))
     
   
   route.append(CLLocation(latitude:47.00598, longitude:-120.5896))
     
   
   route.append(CLLocation(latitude:47.00617, longitude:-120.58846))
     
   
   route.append(CLLocation(latitude:47.00633, longitude:-120.58748))
     
   
   route.append(CLLocation(latitude:47.00645, longitude:-120.58674))
     
   
   route.append(CLLocation(latitude:47.0064496, longitude:-120.5867448))
     
   
   route.append(CLLocation(latitude:47.00643, longitude:-120.58653))
     
   
   route.append(CLLocation(latitude:47.00642, longitude:-120.58645))
     
   
   route.append(CLLocation(latitude:47.0064, longitude:-120.58638))
     
   
   route.append(CLLocation(latitude:47.00638, longitude:-120.58633))
     
   
   route.append(CLLocation(latitude:47.00636, longitude:-120.5863))
     
   
   route.append(CLLocation(latitude:47.00622, longitude:-120.58617))
     
   
   route.append(CLLocation(latitude:47.00608, longitude:-120.58617))
     
   
   route.append(CLLocation(latitude:47.00514, longitude:-120.5862))
     
   
   route.append(CLLocation(latitude:47.00501, longitude:-120.5862))
     
   
   route.append(CLLocation(latitude:47.00492, longitude:-120.58619))
     
   
   route.append(CLLocation(latitude:47.00482, longitude:-120.58616))
     
   
   route.append(CLLocation(latitude:47.00472, longitude:-120.58612))
     
   
   route.append(CLLocation(latitude:47.00463, longitude:-120.58608))
     
   
   route.append(CLLocation(latitude:47.00456, longitude:-120.58604))
     
   
   route.append(CLLocation(latitude:47.00447, longitude:-120.58599))
     
   
   route.append(CLLocation(latitude:47.00439, longitude:-120.58592))
     
   
   route.append(CLLocation(latitude:47.00433, longitude:-120.58588))
     
   
   route.append(CLLocation(latitude:47.00427, longitude:-120.58581))
     
   
   route.append(CLLocation(latitude:47.00414, longitude:-120.58566))
     
   
   route.append(CLLocation(latitude:47.00408, longitude:-120.58556))
     
   
   route.append(CLLocation(latitude:47.00401, longitude:-120.58546))
     
   
   route.append(CLLocation(latitude:47.00395, longitude:-120.58533))
     
   
   route.append(CLLocation(latitude:47.00391, longitude:-120.58523))
     
   
   route.append(CLLocation(latitude:47.00388, longitude:-120.58515))
     
   
   route.append(CLLocation(latitude:47.00385, longitude:-120.58507))
     
   
   route.append(CLLocation(latitude:47.00383, longitude:-120.58501))
     
   
   route.append(CLLocation(latitude:47.00381, longitude:-120.58493))
     
   
   route.append(CLLocation(latitude:47.00379, longitude:-120.58487))
     
   
   route.append(CLLocation(latitude:47.00377, longitude:-120.58479))
     
   
   route.append(CLLocation(latitude:47.00374, longitude:-120.58469))
     
   
   route.append(CLLocation(latitude:47.00363, longitude:-120.58425))
     
   
   route.append(CLLocation(latitude:47.00309, longitude:-120.58212))
     
   
   route.append(CLLocation(latitude:47.00291, longitude:-120.58145))
     
   
   route.append(CLLocation(latitude:47.00284, longitude:-120.5812))
     
   
   route.append(CLLocation(latitude:47.00278, longitude:-120.58098))
     
   
   route.append(CLLocation(latitude:47.00268, longitude:-120.58068))
     
   
   route.append(CLLocation(latitude:47.00247, longitude:-120.58017))
     
   
   route.append(CLLocation(latitude:47.00104, longitude:-120.57682))
     
   
   route.append(CLLocation(latitude:47.00077, longitude:-120.57618))
     
   
   route.append(CLLocation(latitude:47.00001, longitude:-120.57437))
     
   
   route.append(CLLocation(latitude:46.99984, longitude:-120.57397))
     
   
   route.append(CLLocation(latitude:46.99975, longitude:-120.57371))
     
   
   route.append(CLLocation(latitude:46.99964, longitude:-120.57336))
     
   
   route.append(CLLocation(latitude:46.99958, longitude:-120.57306))
     
   
   route.append(CLLocation(latitude:46.99954, longitude:-120.57277))
     
   
   route.append(CLLocation(latitude:46.99951, longitude:-120.57255))
     
   
   route.append(CLLocation(latitude:46.99949, longitude:-120.57228))
     
   
   route.append(CLLocation(latitude:46.99948, longitude:-120.57198))
     
   
   route.append(CLLocation(latitude:46.99948, longitude:-120.57076))
     
   
   route.append(CLLocation(latitude:46.99945, longitude:-120.56613))
     
   
   route.append(CLLocation(latitude:46.99945, longitude:-120.56589))
     
   
   route.append(CLLocation(latitude:46.99945, longitude:-120.56485))
     
   
   route.append(CLLocation(latitude:46.99944, longitude:-120.5636))
     
   
   route.append(CLLocation(latitude:46.99943, longitude:-120.5632))
     
   
   route.append(CLLocation(latitude:46.99943, longitude:-120.56316))
     
   
   route.append(CLLocation(latitude:46.99943, longitude:-120.56272))
     
   
   route.append(CLLocation(latitude:46.9994256, longitude:-120.5627244))
     
   
   route.append(CLLocation(latitude:46.99938, longitude:-120.56252))
     
   
   route.append(CLLocation(latitude:46.99936, longitude:-120.56239))
     
   
   route.append(CLLocation(latitude:46.99932, longitude:-120.56224))
     
   
   route.append(CLLocation(latitude:46.99926, longitude:-120.56207))
     
   
   route.append(CLLocation(latitude:46.99918, longitude:-120.5619))
     
   
   route.append(CLLocation(latitude:46.9991, longitude:-120.56173))
     
   
   route.append(CLLocation(latitude:46.99892, longitude:-120.56149))
     
   
   route.append(CLLocation(latitude:46.99854, longitude:-120.56096))
     
   
   route.append(CLLocation(latitude:46.99828, longitude:-120.56058))
     
   
   route.append(CLLocation(latitude:46.99751, longitude:-120.55946))
     
   
   route.append(CLLocation(latitude:46.9973, longitude:-120.55918))
     
   
   route.append(CLLocation(latitude:46.99721, longitude:-120.55906))
     
   
   route.append(CLLocation(latitude:46.99714, longitude:-120.55897))
     
   
   route.append(CLLocation(latitude:46.99702, longitude:-120.55886))
     
   
   route.append(CLLocation(latitude:46.997, longitude:-120.55884))
     
   
   route.append(CLLocation(latitude:46.99679, longitude:-120.55865))
     
   
   route.append(CLLocation(latitude:46.99677, longitude:-120.55863))
     
   
   route.append(CLLocation(latitude:46.9966, longitude:-120.55851))
     
   
   route.append(CLLocation(latitude:46.99649, longitude:-120.55844))
     
   
   route.append(CLLocation(latitude:46.99629, longitude:-120.55832))
     
   
   route.append(CLLocation(latitude:46.9962875, longitude:-120.5583215))
     
   
   route.append(CLLocation(latitude:46.99629, longitude:-120.55817))
     
   
   route.append(CLLocation(latitude:46.99629, longitude:-120.558))
     
   
   route.append(CLLocation(latitude:46.99628, longitude:-120.55776))
     
   
   route.append(CLLocation(latitude:46.99627, longitude:-120.55757))
     
   
   route.append(CLLocation(latitude:46.99624, longitude:-120.55739))
     
   
   route.append(CLLocation(latitude:46.99622, longitude:-120.55725))
     
   
   route.append(CLLocation(latitude:46.99621, longitude:-120.55711))
     
   
   route.append(CLLocation(latitude:46.99621, longitude:-120.55697))
     
   
   route.append(CLLocation(latitude:46.99621, longitude:-120.55685))
     
   
   route.append(CLLocation(latitude:46.99622, longitude:-120.55669))
     
   
   route.append(CLLocation(latitude:46.99624, longitude:-120.55658))
     
   
   route.append(CLLocation(latitude:46.99627, longitude:-120.55644))
     
   
   route.append(CLLocation(latitude:46.99629, longitude:-120.55632))
     
   
   route.append(CLLocation(latitude:46.99632, longitude:-120.55619))
     
   
   route.append(CLLocation(latitude:46.99633, longitude:-120.55601))
     
   
   route.append(CLLocation(latitude:46.99635, longitude:-120.55531))
     
   
   route.append(CLLocation(latitude:46.99637, longitude:-120.55475))
     
   
   route.append(CLLocation(latitude:46.99638, longitude:-120.55408))
     
   
   route.append(CLLocation(latitude:46.99642, longitude:-120.55275))
     
   
   route.append(CLLocation(latitude:46.99644, longitude:-120.55142))
     
   
   route.append(CLLocation(latitude:46.99647, longitude:-120.55049))
     
   
   route.append(CLLocation(latitude:46.99648, longitude:-120.55005))
     
   
   route.append(CLLocation(latitude:46.99649, longitude:-120.54959))
     
   
   route.append(CLLocation(latitude:46.9965, longitude:-120.54917))
     
   
   route.append(CLLocation(latitude:46.99651, longitude:-120.54868))
     
   
   route.append(CLLocation(latitude:46.99653, longitude:-120.54814))
     
   
   route.append(CLLocation(latitude:46.99653, longitude:-120.54785))
     
   
   route.append(CLLocation(latitude:46.9965313, longitude:-120.547848))
    
    return route
    }

}
