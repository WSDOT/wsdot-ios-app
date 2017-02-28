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
    
    enum TimeUtilsError: Error {
        case invalidTimeString
    }
    
    static let updateTime: Int = 900
    static let cameraUpdateTime: Int = 604800
    
    static let vesselUpdateTime: TimeInterval = 30
    static let spacesUpdateTime: TimeInterval = 60
    
    static let alertsUpdateTime: TimeInterval = 60
    static let alertsCacheTime: Int = 60
    
    static var currentTime: Int64{
        get {
            return Int64(floor(Date().timeIntervalSince1970 * 1000))
        }
    }
    
    // formates a /Date(1468516282113-0700)/ date into NSDate
    static func parseJSONDateToNSDate(_ date: String) -> Date{
        let parseDateString = date[date.characters.index(date.startIndex, offsetBy: 6)..<date.characters.index(date.startIndex, offsetBy: 16)]
        if let date = Double(parseDateString) {
            return Date(timeIntervalSince1970: date)
        } else {
            return Date(timeIntervalSince1970: 0)
        }
    }
    

    // formates a /Date(1468516282113-0700)/ date into a Int64
    static func parseJSONDate(_ date: String) -> Int64{
        let parseDateString = date[date.characters.index(date.startIndex, offsetBy: 6)..<date.characters.index(date.startIndex, offsetBy: 16)]
        if let date = Int64(parseDateString) {
            return date
        } else {
            return 0
        }
    }

    static func getTimeOfDay(_ date: Date) -> String{
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        let timeString = formatter.string(from: date)
        //Return Short Time String
        return timeString
    }
    
    // Returns an array of the days of the week starting with the current day
    static func nextSevenDaysStrings(_ date: Date) -> [String]{
        let weekdays = DateFormatter().weekdaySymbols
        let dayOfWeekInt = getDayOfWeek(date)
        return Array(weekdays![dayOfWeekInt-1..<weekdays!.count]) + weekdays![0..<dayOfWeekInt-1]
    }
    
    fileprivate static func getDayOfWeek(_ date: Date)->Int {
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar).components(.weekday, from: date)
        let weekDay = myComponents.weekday
        return weekDay!
    }
    
    // Returns an NSDate object form a date string with the given format "yyyy-MM-dd hh:mm a"
    static func formatTimeStamp(_ timestamp: String) throws -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "PDT")
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        guard let time = dateFormatter.date(from: timestamp) else {
            throw TimeUtilsError.invalidTimeString
        }
        return time
    }
    
    static func getDateFromJSONArray(_ time: [JSON]) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-M-d H:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "PDT")
        let year = time[0].stringValue
        let month = time[1].stringValue
        let day = time[2].stringValue
        let hour = time[3].stringValue
        let min = time[4].stringValue
        let dateString =  year + "-" + month + "-" + day + " " + hour + ":" + min
        
        if let date = dateFormatter.date(from: dateString){
            return date
        } else {
            return Date.init(timeIntervalSince1970: 0)
        }
    }
    // Converts blogger pub date format into an NSDate object (ex. 2016-08-26T09:24:00.000-07:00)
    static func postPubDateToNSDate(_ time: String, formatStr: String, isUTC: Bool) -> Date{
        let dateFormatter = DateFormatter()
        if (isUTC){
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        dateFormatter.dateFormat = formatStr
        return dateFormatter.date(from: time)!
    }

    // returns a date string with the format MMMM DD, YYYY H:mm a
    static func formatTime(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "PDT")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // Calculates the number of mins mentions in a string. Assumes string format XX HR XX MIN, XX MIN, XX HR
    static func getMinsFromString(_ string: String) -> Double {
        let stringArr = string.characters.split{$0 == " "}.map(String.init)
        var index = 0
        var mins = 0.0
        
        for string in stringArr {
            if (string.rangeOfCharacter(from: CharacterSet.decimalDigits, options: NSString.CompareOptions(), range: nil) != nil) {
                if Double(string) != nil {
                    if stringArr[index + 1] == "HR" {
                        mins += Double(string)! * 60
                    } else {
                        mins += Double(string)!
                    }
                }
            }
            index += 1
        }
        return mins
    }
    
    // Returns a string timestamp since a given time in miliseconds.
    // Source: https://gist.github.com/chashmeetsingh/736b4898d0988888a2e6695455cb8edc
    static  func timeAgoSinceDate(date:Date, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now as Date
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)

        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }

    }
}
