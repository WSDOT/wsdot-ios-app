//
//  TimeUtils.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

import Foundation
import SwiftyJSON

class TimeUtils {
    
    enum TimeUtilsError: ErrorType {
        case InvalidTimeString
    }
    
    static let updateTime: Int = 900
    static let cameraUpdateTime: Int = 604800
    static let vesselUpdateTime: NSTimeInterval = 30
    static let alertsUpdateTime: NSTimeInterval = 60
    
    static var currentTime: Int64{
        get {
            return Int64(floor(NSDate().timeIntervalSince1970 * 1000))
        }
    }
    
    // formates a /Date(1468516282113-0700)/ date into NSDate
    static func parseJSONDateToNSDate(date: String) -> NSDate{
        let parseDateString = date[date.startIndex.advancedBy(6)..<date.startIndex.advancedBy(16)]
        if let date = Double(parseDateString) {
            return NSDate(timeIntervalSince1970: date)
        } else {
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    
    // formates a /Date(1468516282113-0700)/ date into a Int64
    static func parseJSONDate(date: String) -> Int64{
        let parseDateString = date[date.startIndex.advancedBy(6)..<date.startIndex.advancedBy(16)]
        if let date = Int64(parseDateString) {
            return date
        } else {
            return 0
        }
    }
    
    static func getTimeOfDay(date: NSDate) -> String{
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(date)
        
        //Return Short Time String
        return timeString
        
    }
    
    
    // Returns an array of the days of the week starting with the current day
    static func nextSevenDaysStrings(date: NSDate) -> [String]{
        let weekdays = NSDateFormatter().weekdaySymbols
        let dayOfWeekInt = getDayOfWeek(date)
        return Array(weekdays[dayOfWeekInt-1..<weekdays.count]) + weekdays[0..<dayOfWeekInt-1]
    }
    
    private static func getDayOfWeek(date: NSDate)->Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: date)
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    // Returns an NSDate object form a date string with the given format "yyyy-MM-dd hh:mm a"
    static func formatTimeStamp(timestamp: String) throws -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        
        guard let time = dateFormatter.dateFromString(timestamp) else {
            throw TimeUtilsError.InvalidTimeString
        }
        
        return time
    }
    
    
    
    static func getDateFromJSONArray(time: [JSON]) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-M-d H:mm"
        let year = time[0].stringValue
        let month = time[1].stringValue
        let day = time[2].stringValue
        let hour = time[3].stringValue
        let min = time[4].stringValue
        let dateString =  year + "-" + month + "-" + day + " " + hour + ":" + min
        return dateFormatter.dateFromString(dateString)!
    }
    
    // Converts blogger pub date format into an NSDate object (ex. 2016-08-26T09:24:00.000-07:00)
    static func postPubDateToNSDate(time: String, formatStr: String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = formatStr
        return dateFormatter.dateFromString(time)!
    }
    
    // returns a date string with the format MMMM DD, YYYY H:MM a
    static func fullTimeStamp(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY H:MM a"
        return dateFormatter.stringFromDate(date)
    }
    
    // returns a date string with the format MMMM DD, YYYY H:MM a
    static func formatTime(date: NSDate, format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(date)
    }
    
    // Returns a string timestamp since a given time in miliseconds.
    // Source: https://gist.github.com/jacks205/4a77fb1703632eb9ae79
    static func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
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
