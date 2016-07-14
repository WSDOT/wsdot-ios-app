//
//  SQLiteDataStore.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.

import Foundation
import SQLite

/*
   Creates SQLite database.
*/
class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    let WSDOTDB: Connection?
   
    private init() {
       
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
        ).first!
       
        do {
            WSDOTDB = try Connection("\(path)/wsdotDB.sqlite3")
        } catch _ {
            WSDOTDB = nil
        }
    }
   
    func createTables() throws{
   
        do {
            print("creating Caches table...")
            try CachesDataHelper.createTable()
            seedCaches()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        
        do {
            print("creating Ferries Schedules table...")
            try FerriesScheduleDataHelper.createTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
    
    
    private func seedCaches(){
        print("seeding caches table")
        CachesStore.insertNewTime(Tables.FERRIES_TABLE, updated: 0)
    }
    
}
