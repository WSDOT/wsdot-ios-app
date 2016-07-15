//
//  Consts.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
import UIKit

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
    // Source: https://gist.github.com/jacks205/4a77fb1703632eb9ae79
    static func timeSinceDate(date:Int64, numericDates:Bool) -> String {
        let date = NSDate(timeIntervalSince1970: Double(date/1000))
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 2) {
            return "\(components.year) years ago"
        } else if (components.year >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month) months ago"
        } else if (components.month >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear) weeks ago"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day >= 2) {
            return "\(components.day) days ago"
        } else if (components.day >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour) hours ago"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute) minutes ago"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }
    }
    
}

class AlertMessages {
    
    static func getConnectionAlert() ->  UIAlertController{
        let alert = UIAlertController(title: "Connection Error", message: "Please check your connection", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }

}
