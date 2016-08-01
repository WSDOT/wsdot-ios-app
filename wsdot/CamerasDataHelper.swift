//
//  CamerasDataHelper.swift
//  WSDOT
//
//  Created by Logan Sims on 7/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import SQLite

class CamerasDataHelper: DataHelperProtocol {
    static let TABLE_NAME = Tables.CAMERAS_TABLE
    
    static let table = Table(TABLE_NAME)
    
    static let cameraId = Expression<Int64>("cameraId")
    static let url = Expression<String>("url")
    static let title = Expression<String>("title")
    static let roadName = Expression<String>("roadName")
    static let latitude = Expression<Double>("latitude")
    static let longitude = Expression<Double>("longitude")
    static let video = Expression<Int64>("video")
    
    typealias T = CameraDataModel
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            let _ = try DB.run( table.create(ifNotExists: true) {t in
                t.column(cameraId, primaryKey: true)
                t.column(url)
                t.column(title)
                t.column(roadName)
                t.column(latitude)
                t.column(longitude)
                t.column(video)
                })
        } catch _ {
            print("Error creating cameras table")
        }
        
    }
    
    static func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let insert = table.insert(
            cameraId <- item.cameraId,
            url <- item.url,
            title <- item.title,
            roadName <- item.roadName,
            latitude <- item.latitude,
            longitude <- item.longitude,
            video <- item.video
        )
        
        do {
            if try DB.run(insert) > 0{
                return 0
            } else {
                throw DataAccessError.Insert_Error
            }
        } catch {
            throw DataAccessError.Insert_Error
        }
    }
    
    static func bulkInsert(items: [T]) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        
        let data = " ("
            + cameraId.template + ", "
            + url.template + ", "
            + title.template + ", "
            + roadName.template + ", "
            + latitude.template + ", "
            + longitude.template + ", "
            + video.template + ") "
        let values = "VALUES (?,?,?,?,?,?,?)"
        
        let bulkTrans = try DB.prepare("INSERT INTO " + TABLE_NAME + data + values)
        
        do {
            try DB.transaction(.Deferred) { () -> Void in
                for item in items{
                    
                    try bulkTrans.run(
                        item.cameraId,
                        item.url,
                        item.title,
                        item.roadName,
                        item.latitude,
                        item.longitude,
                        item.video)
                    
                }
            }
        }catch {
            throw DataAccessError.Bulk_Insert_Error
        }
        return 0
    }
    
    static func delete (item: T) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(cameraId == item.cameraId)
        do {
            let tmp = try DB.run(query.delete())
            guard tmp == 1 else {
                throw DataAccessError.Delete_Error
            }
        } catch _ {
            throw DataAccessError.Delete_Error
        }
    }
    
    static func deleteAll() throws {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let delete = table.delete()
        try DB.run(delete)
    }
    
    static func find(id: Int64) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(cameraId == id)
        
        let items = try DB.prepare(query)
        for item in items {
            return CameraDataModel(cameraId: item[cameraId],
                                   url: item[url],
                                   title: item[title],
                                   roadName: item[roadName],
                                   latitude: item[latitude],
                                   longitude: item[longitude],
                                   video: item[video])
        }
        return nil
        
    }
    
    static func findByRoadName(road: String) throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(roadName == road)
        
        let items = try DB.prepare(query)
        
        var result = [T]()
        
        for item in items {
            let ferryCamera = CameraDataModel(cameraId: item[cameraId],
                                   url: item[url],
                                   title: item[title],
                                   roadName: item[roadName],
                                   latitude: item[latitude],
                                   longitude: item[longitude],
                                   video: item[video])
            
            result.append(ferryCamera)
        }
        
        return result
        
    }
    
    static func findAll() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(CameraDataModel(cameraId: item[cameraId],
                                   url: item[url],
                                   title: item[title],
                                   roadName: item[roadName],
                                   latitude: item[latitude],
                                   longitude: item[longitude],
                                   video: item[video]))
        }
        return retArray
    }
}
