//
//  FerriesScheduleDataHelper.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import SQLite

class FerriesScheduleDataHelper: DataHelperProtocol {
    static let TABLE_NAME = Tables.FERRIES_TABLE
    
    static let table = Table(TABLE_NAME)
    static let routeId = Expression<Int64>("routeid")
    static let routeDescription = Expression<String>("routedescritption")
    static let selected = Expression<Bool>("selected")
    static let crossingTime = Expression<String?>("crossingtime")
    static let cacheDate = Expression<Int64>("cacheDate")
    static let routeAlerts = Expression<String>("routealert")
    static let scheduleDates  = Expression<String>("scheduledate")
    
    typealias T = RouteScheduleDataModel
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            let _ = try DB.run( table.create(ifNotExists: true) {t in
                t.column(routeId, primaryKey: true)
                t.column(routeDescription)
                t.column(selected)
                t.column(crossingTime)
                t.column(cacheDate)
                t.column(routeAlerts)
                t.column(scheduleDates)
                })
        } catch _ {
            print("Error creating ferries table")
        }
    }
    
    static func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.routeDescription != nil && item.scheduleDates != nil
            && item.cacheDate != nil && item.routeAlerts != nil && item.selected != nil && item.routeId != nil) {
            
            let insert = table.insert(
                routeId <- item.routeId!,
                routeDescription <- item.routeDescription!,
                selected <- item.selected!,
                crossingTime <- item.crossingTime,
                cacheDate <- item.cacheDate!,
                routeAlerts <- item.routeAlerts!,
                scheduleDates <- item.scheduleDates!)
            
            do {
                let rowId = try DB.run(insert)
                guard rowId > 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            } catch _ {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
        
    }
    
    static func updateFavorite(id: Int64, isFavorite: Bool) throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let filterTable = table.filter(routeId == id)
        
        let update = filterTable.update(
            selected <- isFavorite)
        
        do {
            let result = try DB.run(update)
            print(result)
            return result
        } catch {
            throw DataAccessError.Update_Error
        }
        
    }
    
    static func delete (item: T) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.routeId {
            let query = table.filter(routeId == id)
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
    
    static func find(id: Int64) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(routeId == id)
        
        let items = try DB.prepare(query)
        for item in  items {
            return RouteScheduleDataModel(routeId: item[routeId],
                                          routeDescription: item[routeDescription],
                                          selected: item[selected],
                                          crossingTime: item[crossingTime],
                                          cacheDate: item[cacheDate],
                                          routeAlerts: item[routeAlerts],
                                          scheduleDates: item[scheduleDates])
        }
        return nil
    }
    
    static func findAll() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table.order(routeDescription))
        
        for item in items {
            retArray.append(RouteScheduleDataModel(routeId: item[routeId],
                routeDescription: item[routeDescription],
                selected: item[selected],
                crossingTime: item[crossingTime],
                cacheDate: item[cacheDate],
                routeAlerts: item[routeAlerts],
                scheduleDates: item[scheduleDates]))
        }
        return retArray
    }
    
    static func deleteAll() throws {
        guard let DB = SQLiteDataStore.sharedInstance.WSDOTDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let delete = table.delete()
        try DB.run(delete)
    }
}
