//
//  CamerasStore.swift
//  WSDOT
//
//  Created by Logan Sims on 7/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

// public getCamerasbyRoadName(roadName: String)
// public getCameras()

// private updateCameras - Checks chache date, pulls form API or DB - takes completion closure
// private saveCameras

class CamerasStore {
    
    typealias FetchCamerasCompletion = (data: [CameraItem], error: DataAccessError?) -> ()
    typealias UpdateCamerasCompletion = (error: NSError?) -> ()
    
    // Mark: -
    // Mark: Internal Functions
    
    /*
     runs give completion with camera data. roadName can be nil, in which case
     returns all camera data
     */
    static func getCameras(roadName: String?, completion: FetchCamerasCompletion){
        self.updateCameras(false, completion: { error in
            if ((error == nil)){
                if let road = roadName {
                    getCamerasByRoadName(road, completion: completion)
                }else{
                    getAllCameras(completion)
                }
            }
        })
        
    }
    
    // Mark: -
    // Mark: Private Functions
    
    private static func updateCameras(force: Bool, completion: UpdateCamerasCompletion) {
        
        if (((TimeUtils.currentTime - CachesStore.getUpdatedTime(Tables.CAMERAS_TABLE)) > TimeUtils.updateTime) || force){
            
        deleteAll()
            
            Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/Cameras.js").validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let cameras = self.parseCamerasJSON(json)
                        self.saveCameras(cameras)
                        //CachesStore.updateTime(Tables.CAMERAS_TABLE, updated: TimeUtils.currentTime)
                        completion(error: nil)
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
    
    // Saves newly pulled data from the API into the database.
    private static func saveCameras(cameras: [CameraItem]){
        
        var dataModelCameras = [CameraDataModel]()
        
        for camera in cameras {
            dataModelCameras.append(
            CameraDataModel(
                cameraId: camera.cameraId,
                url: camera.url,
                title: camera.title,
                roadName: camera.roadName,
                latitude: camera.latitude,
                longitude: camera.longitude,
                video: camera.video ? 1 : 0))
        }
        
        
        do {
            try CamerasDataHelper.bulkInsert(dataModelCameras)
        } catch DataAccessError.Bulk_Insert_Error {
            print("saveCameras: Bulk insert Error")
        } catch DataAccessError.Datastore_Connection_Error {
            print("saveCameras: Connection error")
        } catch DataAccessError.Nil_In_Data{
            print("saveCameras: nil in data error")
        } catch _ {
            print("saveCameras: unknown error occured.")
        }
    }


    private static func getAllCameras(completion: FetchCamerasCompletion) -> [CameraItem]{
        var cameras = [CameraItem]()
        do{
            if let result = try CamerasDataHelper.findAll(){
                
                for camera in result {
                    let cameraItem = CameraItem(
                        id: camera.cameraId,
                        url: camera.url,
                        title: camera.title,
                        road: camera.roadName,
                        lat: camera.latitude,
                        long: camera.longitude,
                        video: camera.video == 1)
                    
                    cameras.append(cameraItem)
                }
                print("9")
                completion(data: cameras, error: nil)
            }
        } catch DataAccessError.Datastore_Connection_Error {
            print("findAllSchedules: Connection error")
            completion(data: [], error: DataAccessError.Datastore_Connection_Error)
        } catch _ {
            print("findAllSchedules: unknown error")
            completion(data: [], error: DataAccessError.Unknown_Error)
        }
        return cameras
    }
    
    private static func getCamerasByRoadName(roadName : String, completion: FetchCamerasCompletion) -> [CameraItem]{
        var cameras = [CameraItem]()
        do{
            if let result = try CamerasDataHelper.findByRoadName(roadName){
                
                for camera in result {
                    let cameraItem = CameraItem(
                        id: camera.cameraId,
                        url: camera.url,
                        title: camera.title,
                        road: camera.roadName,
                        lat: camera.latitude,
                        long: camera.longitude,
                        video: camera.video == 1)
                    
                    cameras.append(cameraItem)
                }
                
                completion(data: cameras, error: nil)
            }
        } catch DataAccessError.Datastore_Connection_Error {
            print("findAllSchedules: Connection error")
            completion(data: [], error: DataAccessError.Datastore_Connection_Error)
        } catch _ {
            print("findAllSchedules: unknown error")
            print("findAllSchedules: unknown error")
            completion(data: [], error: DataAccessError.Unknown_Error)
        }
        return cameras
    }
    
    private static func deleteAll(){
        do{
            try CamerasDataHelper.deleteAll()
        } catch DataAccessError.Datastore_Connection_Error {
            print("CamerasDataHelper.deleteAll: Connection error")
        } catch _ {
            print("CamerasDataHelper.deleteAll: unknown error")
        }
    }
    
    private static func parseCamerasJSON(json: JSON) ->[CameraItem]{
        var cameras = [CameraItem]()
        for (_,cameraJson):(String, JSON) in json["cameras"]["items"] {
            
            let camera = CameraItem(
                id: cameraJson["id"].int64Value,
                url: cameraJson["url"].stringValue,
                title: cameraJson["title"].stringValue,
                road: cameraJson["roadName"].stringValue,
                lat: cameraJson["lat"].doubleValue,
                long: cameraJson["lon"].doubleValue,
                video: cameraJson["video"].boolValue)
            
            cameras.append(camera)
        }
        return cameras
    }
}
