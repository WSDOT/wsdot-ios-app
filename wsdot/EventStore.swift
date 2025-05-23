//
//  EventStore.swift
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

import Alamofire
import SwiftyJSON
import Foundation

class EventStore: Decodable {

    typealias EventCompletion = (_ error: Error?) -> ()
    
    private static let startDateKey = "event_start_date"
    private static let endDateKey = "event_end_date"
    private static let titleKey = "event_title"
    private static let detailsKey = "event_details"
    private static let bannerTextKey = "event_banner_text"
    private static let themeIdKey = "event_theme_id"
   
    static var pushSession: Session?
    static var eventSession: Session?

    // Checks server for version of notifcation topics.
    // If the topics list has been updated, saves the new tipview message
    // to display on next start up. 
    static func fetchPushNotificationsStatus() {
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        pushSession = Session(configuration: configuration)

        pushSession!.request("https://data.wsdot.wa.gov/mobile/NotificationTopicsVersion.json").validate().responseDecodable(of: EventStore.self) { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    
                    let prevVersion = UserDefaults.standard.integer(forKey: UserDefaultsKeys.pushNotificationTopicVersion)
                    
                    if prevVersion != json["version"].intValue {
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasSeenNotificationsTipView)
                        UserDefaults.standard.set(json["version"].intValue, forKey: UserDefaultsKeys.pushNotificationTopicVersion)
                        UserDefaults.standard.set(json["description"].stringValue, forKey: UserDefaultsKeys.pushNotificationsTopicDescription)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }


    static func fetchAndSaveEventItem(validJSONCheck: Bool, completion: @escaping EventCompletion) {
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        eventSession = Session(configuration: configuration)

        eventSession!.request("https://data.wsdot.wa.gov/mobile/EventStatus.json").validate().responseDecodable(of: EventStore.self) { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    saveEventJSON(json)
                    completion(nil)
                    
                }
            case .failure(let error):
                print(error)
                completion(error)
                if(validJSONCheck) {
                    if ((error.isResponseSerializationError) == true || (error.responseCode == 404))
                    {
                        saveEventJSON(JSON(rawValue: error) ?? "")
                    }
                    }
                }
            }
        }


    static func eventActive() -> Bool {
    
        let preferences = UserDefaults.standard
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDateString = preferences.string(forKey: startDateKey) else {
            return false
        }
        
        guard let startDate = dateFormatter.date(from: startDateString) else {
            return false
        }
        
        guard let endDateString = preferences.string(forKey: endDateKey) else {
            return false
        }
    
        guard let endDate = dateFormatter.date(from: endDateString) else {
            return false
        }

        return (startDate ... endDate).contains(Date())

    }
    
    static func getActiveEventThemeId() -> Int {
    
        if (!eventActive()){
            return 0
        }
    
        let preferences = UserDefaults.standard
        return preferences.integer(forKey: themeIdKey)
    }
    
    static func getActiveEvent() -> EventItem? {
    
        if (!eventActive()){
            return nil
        }
    
        let preferences = UserDefaults.standard

        var title: String
        var details: String
        var bannerText: String
        var themeId: Int

        if preferences.object(forKey: titleKey) != nil {
            title = preferences.string(forKey: titleKey)!
        } else {
            return nil
        }

        if preferences.object(forKey: detailsKey) != nil {
            details = preferences.string(forKey: detailsKey)!
        } else {
            return nil
        }
        
        if preferences.object(forKey: bannerTextKey) != nil {
            bannerText = preferences.string(forKey: bannerTextKey)!
        } else {
            return nil
        }
    
        if preferences.object(forKey: themeIdKey) != nil {
            themeId = preferences.integer(forKey: themeIdKey)
        } else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDateString = preferences.string(forKey: startDateKey) else {
            return nil
        }
        
        guard let startDate = dateFormatter.date(from: startDateString) else {
            return nil
        }
        
        guard let endDateString = preferences.string(forKey: endDateKey) else {
            return nil
        }
    
        guard let endDate = dateFormatter.date(from: endDateString) else {
            return nil
        }
    
        return EventItem(title, details, bannerText, themeId, startDate, endDate)
    }
    
    fileprivate static func saveEventJSON(_ json: JSON) {
    
        let preferences = UserDefaults.standard
        preferences.set(json["title"].stringValue, forKey: titleKey)
        preferences.set(json["details"].stringValue, forKey: detailsKey)
        preferences.set(json["bannerText"].stringValue, forKey: bannerTextKey)
        preferences.set(json["themeId"].intValue, forKey: themeIdKey)
        preferences.set(json["startDate"].stringValue, forKey: startDateKey)
        preferences.set(json["endDate"].stringValue, forKey: endDateKey)
        
    }
}
