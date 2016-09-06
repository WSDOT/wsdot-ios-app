//  CamerasStore.swift
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
import Alamofire
import SwiftyJSON
import RealmSwift

class CamerasStore {
    
    typealias UpdateCamerasCompletion = (error: NSError?) -> ()
    
    static func getAllCameras() -> [CameraItem]{
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self)
        return Array(cameraItems)
    }
    
    static func getFavoriteCameras() -> [CameraItem]{
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self).filter("selected == true")
        return Array(cameraItems)
    }
    
    static func getCamerasByRoadName(roadName : String) -> [CameraItem]{
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self).filter("roadName == \"\(roadName)\"")
        return Array(cameraItems)
    }
    
    static func getCamerasByID(ids: [Int]) -> [CameraItem]{
        let realm = try! Realm()
        
        var predicats = [NSPredicate]()
        
        for id in ids {
            predicats.append(NSPredicate(format: "cameraId = \(id)"))
        }
        
        let query = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predicats)
        let cameraItems = realm.objects(CameraItem.self).filter(query)
        
        return Array(cameraItems)
    }
    
    static func updateFavorite(camera: CameraItem, newValue: Bool){
        let realm = try! Realm()
        do {
            try realm.write{
                camera.selected = newValue
            }
        }catch{
            print("CamerasStore.updateFavorite: Realm write error")
        }
    }
    
    static func updateCameras(force: Bool, completion: UpdateCamerasCompletion) {
        
        let deltaUpdated = NSCalendar.currentCalendar().components(.Second, fromDate: CachesStore.getUpdatedTime(CachedData.Cameras), toDate: NSDate(), options: []).second
        
        if ((deltaUpdated > TimeUtils.cameraUpdateTime) || force){
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/Cameras.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                            let json = JSON(value)
                            self.saveCameras(json)
                            CachesStore.updateTime(CachedData.Cameras, updated: NSDate())
                            completion(error: nil)
                        }
                    }
                case .Failure(let error):
                    print(error)
                    completion(error: error)
                }
            }
        }else{
            completion(error: nil)
        }
    }
    
    
    private static func saveCameras(json: JSON){
        
        let realm = try! Realm()
        
        let oldFavoriteCameras = realm.objects(CameraItem.self).filter("selected == true")
        let newCameras = List<CameraItem>()
        
        for (_,cameraJson):(String, JSON) in json["cameras"]["items"] {
            let camera = CameraItem()
            camera.cameraId = cameraJson["id"].intValue
            camera.url = cameraJson["url"].stringValue
            camera.title = cameraJson["title"].stringValue
            camera.roadName = cameraJson["roadName"].stringValue
            camera.latitude = cameraJson["lat"].doubleValue
            camera.longitude = cameraJson["lon"].doubleValue
            camera.video = cameraJson["video"].boolValue
            
            for oldCameras in oldFavoriteCameras {
                if (oldCameras.cameraId == camera.cameraId){
                    camera.selected = true
                }
            }
            
            newCameras.append(camera)
            
        }
        
        let oldCameras = realm.objects(CameraItem.self)
        
        do {
            try realm.write{
                for oldCamera in oldCameras {
                    oldCamera.delete = true
                }
                realm.add(newCameras, update: true)
            }
        }catch{
            print("CamerasStore.saveCameras: Realm write error")
        }
    }
    
    static func flushOldData() {
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self).filter("delete == true")
        do {
            try realm.write{
                realm.delete(cameraItems)
            }
        }catch{
            print("CamerasStore.flushOldData: Realm write error")
        }
    }
    
}
