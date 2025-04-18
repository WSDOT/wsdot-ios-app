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

class CamerasStore: Decodable {
    
    typealias UpdateCamerasCompletion = (_ error: Error?) -> ()
    
    static func getAllCameras() -> [CameraItem]{
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self).filter("delete == false")
        return Array(cameraItems)
    }
    
    static func getFavoriteCameras() -> [CameraItem]{
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self).filter("selected == true").filter("delete == false")
        return Array(cameraItems)
    }
    
    static func getCamerasByRoadName(_ roadName : String) -> [CameraItem]{
        let realm = try! Realm()
        let cameraItems = realm.objects(CameraItem.self).filter("roadName == \"\(roadName)\"").filter("delete == false")
        return Array(cameraItems)
    }
    
    static func getCamerasByID(_ ids: [Int]) -> [CameraItem]{
        let realm = try! Realm()
        
        var predicats = [NSPredicate]()
        
        for id in ids {
            predicats.append(NSPredicate(format: "cameraId = \(id)"))
        }
        
        let query = NSCompoundPredicate(type: .or, subpredicates: predicats)
        let cameraItems = realm.objects(CameraItem.self).filter(query).filter("delete == false")
        
        return Array(cameraItems)
    }
    
    static func updateFavorite(_ camera: CameraItem, newValue: Bool){
        let realm = try! Realm()
        do {
            try realm.write{
                camera.selected = newValue
            }
        }catch{
            print("CamerasStore.updateFavorite: Realm write error")
        }
    }
    
    static func updateCameras(_ force: Bool, completion: @escaping UpdateCamerasCompletion) {
        var delta = CachesStore.cameraUpdateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.cameras), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
            delta = deltaValue
        }
         
        if ((delta > CachesStore.cameraUpdateTime) || force){
            
            AF.request("https://data.wsdot.wa.gov/mobile/Cameras.json").validate().responseDecodable(of: CamerasStore.self) { response in
                switch response.result {
                case .success:
                    if let value = response.data {
                        DispatchQueue.global().async{
                            let json = JSON(value)
                            self.saveCameras(json)
                            CachesStore.updateTime(CachedData.cameras, updated: Date())
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(error)
                }
            }
        }else{
            completion(nil)
        }
    }
    
    
    fileprivate static func saveCameras(_ json: JSON){
        
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
            camera.direction = cameraJson["direction"].stringValue
            camera.milepost = cameraJson["milepost"].doubleValue
            
            for oldCameras in oldFavoriteCameras {
                if (oldCameras.cameraId == camera.cameraId){
                    camera.selected = true
                }
            }
            
            newCameras.append(camera)
            
        }
        
        let oldCameras = realm.objects(CameraItem.self)
        
        MyRouteStore.shouldUpdateMyRouteCameras(newCameras: Array(newCameras), oldCameras: Array(oldCameras))
        
        do {
            try realm.write{
                for oldCamera in oldCameras {
                    oldCamera.delete = true
                }
                realm.add(newCameras, update: .all)
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
