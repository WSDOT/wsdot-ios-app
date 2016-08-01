//
//  CachesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 7/14/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation

class CachesStore {
    
    static func getUpdatedTime(table: String) -> Int64 {
        do {
            let cachesData = try CachesDataHelper.find(table)
            return (cachesData?.updated)!
        } catch _ {
            // Failed to get
        }
        
        return 0;
    }
    
    static func insertNewTime(table: String, updated: Int64){
        
        do {
            try CachesDataHelper.insert(CachesDataModel(
                tableName: table,
                updated: updated
                ))
        } catch DataAccessError.Insert_Error {
            print("CachesStore.insertNewTime: failed to insert into caches")
        } catch DataAccessError.Datastore_Connection_Error {
            print("CachesStore.insertNewTime: Connection error")
        } catch DataAccessError.Nil_In_Data{
            print("CachesStore.insertNewTime: Nil in data error")
        } catch _ {
            print("CachesStore.insertNewTime: unknown error occured.")
        }
    }
    
    static func updateTime(table: String, updated: Int64){
        
        do {
            try CachesDataHelper.update(CachesDataModel(
                tableName: table,
                updated: updated
                ))
        } catch DataAccessError.Update_Error {
            print("CachesStore.updateTime: failed to update caches")
        } catch DataAccessError.Datastore_Connection_Error {
            print("CachesStore.updateTime: Connection error")
        } catch DataAccessError.Nil_In_Data{
            print("CachesStore.updateTime: Nil in data error")
        } catch {
            print("CachesStore.updateTime: unknown error occured.")
            print("Error info: \(error)")
        }
    }
}
