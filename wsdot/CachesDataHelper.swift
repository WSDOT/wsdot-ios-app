//
//  CachesDataHelper.swift
//  WSDOT
//
//  Created by Logan Sims on 7/14/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import SQLite

class CachesDataHelper: DataHelperProtocol {
    static let TABLE_NAME = Tables.CACHES_TABLE
    
    static let table = Table(TABLE_NAME)
    static let tableName = Expression<String>("table")
    static let updated = Expression<Int64>("updated")
    
    typealias T = CachesDataModel
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            let _ = try DB.run( table.create(ifNotExists: true) {t in
                t.column(tableName, primaryKey: true)
                t.column(updated)
                })
            print("caches table ready.")
        } catch _ {
            print("Error creating table")
        }
        
    }
    
    static func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.tableName != nil) {
            
            let insert = table.insert(
                tableName <- item.tableName!,
                updated <- item.updated!)
            
            do {
                if try DB.run(insert) > 0{
                    print("inserted new value into " + item.tableName!)
                    return 0
                } else {
                    throw DataAccessError.Insert_Error
                }
            } catch {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
        
    }
    
    static func update(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.tableName != nil) {
            
            print(item.tableName!)
            print(item.updated!)
            
            let update = table.update(
                tableName <- item.tableName!,
                updated <- item.updated!)
            
            do {
                if try DB.run(update) > 0 {
                    print("updated " + item.tableName!)
                    return 0
                } else {
                    throw DataAccessError.Insert_Error
                }
            } catch {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
        
    }
    
    static func delete (item: T) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.tableName {
            let query = table.filter(tableName == id)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
    }
    
    static func find(id: String) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(tableName == id)
        
        let items = try DB.prepare(query)
        for item in items {
            return CachesDataModel(tableName: item[tableName],
                                   updated: item[updated])
        }
        
        print("returning nil")
        return nil
        
    }
    
    static func findAll() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(CachesDataModel(tableName: item[tableName],
                updated: item[updated]))
        }
        
        return retArray
        
    }
}
