//
//  Consts.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation

enum DataAccessError: ErrorType {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Update_Error
    case Nil_In_Data
}

class Tables {
    static let FERRIES_TABLE = "ferries_schedules"
    static let CACHES_TABLE = "caches"

}

class TimeUtils {
    static var currentTime: Int64{
        get {
            return Int64(floor(NSDate().timeIntervalSince1970 * 1000))
        }
    }
    
    static let updateTime = 300000
    
}
