//
//  NotificationsStore.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

import RealmSwift
import Alamofire
import SwiftyJSON
import Foundation

class NotificationsStore {

    typealias UpdateTopicsCompletion = (_ error: Error?) -> ()

    static func updateSubscription(_ topic: NotificationTopicItem, newValue: Bool){

        do {
            let realm = try Realm()
            try realm.write{
            
                // TODO: FCM update sub
            
                topic.subscribed = newValue
            }
        } catch {
            print("NotificationsStore.updateSubscription: Realm write error")
        }
    }

    static func getTopics() -> [NotificationTopicItem] {
            let realm = try! Realm()
            let topicItems = realm.objects(NotificationTopicItem.self)
            return Array(topicItems)
    }

    static func findSubscribedTopics() -> [NotificationTopicItem] {
        let realm = try! Realm()
        let subscribedTopicItems = realm.objects(NotificationTopicItem.self).filter("subscribed == true")
        return Array(subscribedTopicItems)
    }

    static func updateTopics(_ force: Bool, completion: @escaping UpdateTopicsCompletion) {
    
        var delta = TimeUtils.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.notifications), to: Date(), options: []).second
        
        if let deltaValue = deltaUpdated {
             delta = deltaValue
        }
        
        if ((delta > TimeUtils.updateTime) || force){
            
            Alamofire.request("http://data.wsdot.wa.gov/mobile/NotificationTopics.js").validate().responseJSON { response in
            
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        DispatchQueue.global().async {
                            let json = JSON(value)
                            let topicItems =  NotificationsStore.parseTopicsJSON(json)
                            
                            saveTopics(topicItems)
                            CachesStore.updateTime(CachedData.notifications, updated: Date())
                            
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(error)
                }
            }
        }else {
            completion(nil)
        }
    }

    // TODO: Make this smarter
    fileprivate static func saveTopics(_ topics: [NotificationTopicItem]){
        
        let realm = try! Realm()
        
        let oldSubscribedTopics = self.findSubscribedTopics()
        let newTopcis = List<NotificationTopicItem>()
        
        for topic in topics {
            for oldTopic in oldSubscribedTopics {
                if (oldTopic.topic == topic.topic) {
                    topic.subscribed = true
                }
            }
            newTopcis.append(topic)
        }
        let oldTopics = realm.objects(NotificationTopicItem.self)
        do {
            try realm.write{
                for topic in oldTopics {
                    topic.delete = true
                }
                realm.add(newTopcis, update: true)
            }
        } catch {
            print("NotificationsStore.saveTopics: Realm write error")
        }
    }

    static func flushOldData() {
        do {
            let realm = try Realm()
            let routeItems = realm.objects(NotificationTopicItem.self).filter("delete == true")
            try! realm.write{
                realm.delete(routeItems)
            }
        } catch {
            print("NotificationsStore.flushOldData: Realm write error")
        }
    }

    fileprivate static func parseTopicsJSON(_ json: JSON) ->[NotificationTopicItem]{
        
        var topicItems = [NotificationTopicItem]()
        
        for (_,subJson):(String, JSON) in json["topics"] {
            
            let topic = NotificationTopicItem()
            
            topic.topic = subJson["topic"].stringValue
            topic.title = subJson["title"].stringValue
            topic.category = subJson["category"].stringValue
            
            topicItems.append(topic)
        }
        return topicItems
    }
 }
