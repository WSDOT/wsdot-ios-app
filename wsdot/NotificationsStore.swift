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
import Firebase

class NotificationsStore {

    typealias UpdateTopicsCompletion = (_ error: Error?) -> ()

    static func updateSubscription(_ topic: NotificationTopicItem, newValue: Bool){

        do {
            let realm = try Realm()
            
            try realm.write{
                topic.subscribed = newValue
            }

            if (newValue){
                Messaging.messaging().subscribe(toTopic: topic.topic)
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topic.topic)
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
    
    // returns a dict of categories and there corresponding topicItems
    static func getTopicsMap() ->  [String : [NotificationTopicItem]] {
        let realm = try! Realm()
        let topicItems = realm.objects(NotificationTopicItem.self)
        return sortTopicsByCategory(topics:Array(topicItems))
    }

    static func findSubscribedTopics() -> [NotificationTopicItem] {
        let realm = try! Realm()
        let subscribedTopicItems = realm.objects(NotificationTopicItem.self).filter("subscribed == true")
        return Array(subscribedTopicItems)
    }

    /*
     * Fetches a list of push notification FCM topics that users can subscribe to.
     */
    static func updateTopics(_ force: Bool, completion: @escaping UpdateTopicsCompletion) {
    
        var delta = CachesStore.updateTime
        let deltaUpdated = (Calendar.current as NSCalendar).components(.second, from: CachesStore.getUpdatedTime(CachedData.notifications), to: Date(), options: []).second
       
        if let deltaValue = deltaUpdated {
             delta = deltaValue
        }
        
        if ((delta > CachesStore.updateTime) || force || true){
     
            AF.request("https://data.wsdot.wa.gov/mobile/NotificationTopics.js").validate().responseJSON { response in
            
                switch response.result {
                case .success:
                    if let value = response.data {
                        DispatchQueue.global().async {
                        
                            let json = JSON(value)
                            let topicItems =  NotificationsStore.parseTopicsJSON(json)
                   
                            // if nothing is returned, don't overwrite current data.
                            if topicItems != [] {
                                saveTopics(topicItems)
                                CachesStore.updateTime(CachedData.notifications, updated: Date())
                            }
                            
                            completion(nil)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completion(error)
                }
            }
        } else {
            completion(nil)
        }
    }

    fileprivate static func sortTopicsByCategory(topics: [NotificationTopicItem]) -> [String : [NotificationTopicItem]]{
    
        var topicCategoriesMap = [String: [NotificationTopicItem]]()
        
        let sortedTopics = topics.sorted(by: {$0.category < $1.category }).sorted(by: {$0.title < $1.title })
        
        for topic in sortedTopics {
            if topicCategoriesMap[topic.category] != nil {
                topicCategoriesMap[topic.category]!.append(topic)
            } else {
                topicCategoriesMap[topic.category] = [topic]
            }
        }
        
        return topicCategoriesMap
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
                realm.add(newTopcis, update: .all)
            }
        } catch {
            print("NotificationsStore.saveTopics: Realm write error")
        }
    }

    static func flushOldData() {
    
        do {
            let realm = try Realm()
            let topicItems = realm.objects(NotificationTopicItem.self).filter("delete == true")
            
            try! realm.write {
                realm.delete(topicItems)
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
