//
//  MountainPassRealmStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import RealmSwift
import Alamofire
import SwiftyJSON
import Foundation

class MountainPassStore {

   typealias UpdatePassesCompletion = (error: NSError?) -> ()
    
    static func updateFavorite(pass: MountainPassItem, newValue: Bool){
        
        do {
            let realm = try Realm()
            try realm.write{
                pass.selected = newValue
            }
        } catch {
            print("MountainPassStore.updateFavorite: Realm write error")
        }
    }
    
    static func getPasses() -> [MountainPassItem]{
            let realm = try! Realm()
            let passItems = realm.objects(MountainPassItem.self)
            return Array(passItems)

    }
    
    static func findFavoritePasses() -> [MountainPassItem]{
        let realm = try! Realm()
        let favoritePassItems = realm.objects(MountainPassItem.self).filter("selected == true")
        return Array(favoritePassItems)
    }
    
    static func updatePasses(force: Bool, completion: UpdatePassesCompletion) {
        
        let deltaUpdated = NSCalendar.currentCalendar().components(.Second, fromDate: CachesStore.getUpdatedTime(CachedData.MountainPasses), toDate: NSDate(), options: []).second
        
        if ((deltaUpdated > TimeUtils.updateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/MountainPassConditions.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                            let json = JSON(value)
                            let passItems =  MountainPassStore.parsePassesJSON(json)
                            savePasses(passItems)
                            CachesStore.updateTime(CachedData.MountainPasses, updated: NSDate())
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

    
    // TODO: Make this smarter
    private static func savePasses(passes: [MountainPassItem]){
        
        let realm = try! Realm()
        
        let oldFavoritePasses = self.findFavoritePasses()
        let newPasses = List<MountainPassItem>()
        
        for pass in passes {
            for oldPass in oldFavoritePasses {
                if (oldPass.id == pass.id){
                    pass.selected = true
                }
            }
            newPasses.append(pass)
        }
        
        let oldPasses = realm.objects(MountainPassItem.self)
        
        do {
            try realm.write{
                for pass in oldPasses{
                    pass.delete = true
                }
                realm.add(newPasses, update: true)
            }
        }catch {
            print("MountainPassStore.savePasses: Realm write error")
        }
    }
    
    static func flushOldData(){
        do {
            let realm = try Realm()
            let routeItems = realm.objects(MountainPassItem.self).filter("delete == true")
            try! realm.write{
                realm.delete(routeItems)
            }
        }catch {
            print("MountainPassStore.flushOldData: Realm write error")
        }
    }
    
    private static func parsePassesJSON(json: JSON) ->[MountainPassItem]{
        var passItems = [MountainPassItem]()
        
        for (_,subJson):(String, JSON) in json["GetMountainPassConditionsResult"]["PassCondition"] {
            
            let pass = MountainPassItem()
            
            pass.id = subJson["MountainPassId"].intValue
            pass.name = subJson["MountainPassName"].stringValue
            pass.dateUpdated = TimeUtils.getDateFromJSONArray(subJson["DateUpdated"].arrayValue)
            pass.elevationInFeet = subJson["ElevationInFeet"].intValue
            pass.weatherCondition = subJson["WeatherCondition"].stringValue
            pass.travelAdvisoryActive = subJson["TravelAdvisoryActive"].boolValue
            pass.latitude = subJson["Latitude"].doubleValue
            pass.longitude = subJson["Longitude"].doubleValue
            pass.roadCondition = subJson["RoadCondition"].stringValue
            pass.restrictionOneText = subJson["RestrictionOne"]["RestrictionText"].stringValue
            pass.restrictionOneTravelDirection = subJson["RestrictionOne"]["TravelDirection"].stringValue
            pass.restrictionTwoText = subJson["RestrictionTwo"]["RestrictionText"].stringValue
            pass.restrictionTwoTravelDirection = subJson["RestrictionTwo"]["TravelDirection"].stringValue
        
            for camera in parseCameraJSON(subJson["Cameras"]){
                pass.cameras.append(camera)
            }

            for forcast in parseForcastJSON(subJson["Forcast"]){
                pass.forcast.append(forcast)
            }
            
            passItems.append(pass)
        }
        
        return passItems
    }
    
    private static func parseCameraJSON(json: JSON) -> List<CameraItem> {
        let cameras = List<CameraItem>()
        for(_,cameraJSON):(String, JSON) in json {
            let camera = CameraItem()
            camera.cameraId = cameraJSON["id"].intValue
            camera.latitude = cameraJSON["lat"].doubleValue
            camera.longitude = cameraJSON["lon"].doubleValue
            camera.url = cameraJSON["url"].stringValue
            camera.title = cameraJSON["title"].stringValue
            cameras.append(camera)
        }
        return cameras
    }
    
    private static func parseForcastJSON(json: JSON) -> List<ForcastItem> {
        let forcastItems = List<ForcastItem>()
        for(_,forcastJSON):(String, JSON) in json {
            let forcast = ForcastItem()
            forcast.day = forcastJSON["Day"].stringValue
            forcast.forcastText = forcastJSON["ForcastText"].stringValue
            forcastItems.append(forcast)
        }
        return forcastItems
    }
 }
