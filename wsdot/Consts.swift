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
    
    static let updateTime = 900000
    
    // formates a /Date(1468516282113-0700)/ date into a Int64
    static func parseJSONDate(date: String) -> Int64{
        let parseDateString = date[date.startIndex.advancedBy(6)..<date.startIndex.advancedBy(19)]
        if let date = Int64(parseDateString) {
            return date
        } else {
            return 0
        }
    }
    
    // Returns a string timestamp since a given time in miliseconds.
    static func timeSinceDate(date: Int64) -> String{
        
        let timeSince = self.currentTime - date
        let timeSinceInSeconds = timeSince / 1000
        
        if (timeSinceInSeconds < 60){
            return String(timeSinceInSeconds) + " seconds ago"
        } else if (timeSinceInSeconds < 3600){
            return String(timeSinceInSeconds / 60) + " minutes ago"
        } else if (timeSinceInSeconds < 86400){
            return String(timeSinceInSeconds / (60 * 60)) + " hours ago"
        } else {
            return String(timeSinceInSeconds / (60 * 60 * 24)) + " days ago"
        }
    }
}
