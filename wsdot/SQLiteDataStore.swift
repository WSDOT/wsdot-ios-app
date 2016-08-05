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
            print("creating Cameras table...")
            try CamerasDataHelper.createTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    
    }
    
}
