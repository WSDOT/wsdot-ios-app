//
//  SQLiteDataStore.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.

import Foundation
import SQLite

class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    let WSDOTDB: Connection?
   
    private init() {
       
        var path = "wsdotDB.sqlite"
       
        if let dirs: [NSString] =          NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.AllDomainsMask, true) as [NSString] {
               
             let dir = dirs[0]
             path = dir.stringByAppendingPathComponent("wsdotDB.sqlite");
        }
       
        do {
            WSDOTDB = try Connection(path)
        } catch _ {
            WSDOTDB = nil
        }
    }
   
    func createTables() throws{
        do {
            print("creating DB for Ferries Schedules...")
            try FerriesScheduleDataHelper.createTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
}
