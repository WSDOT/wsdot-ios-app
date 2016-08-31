//
//  NewsStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NewsStore {

    typealias FetchNewsCompletion = (data: [NewsItem]?, error: NSError?) -> ()
    
    static func getNews(completion: FetchNewsCompletion) {
        
        Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/News.js").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let posts = parsePostsJSON(json)
                    completion(data: posts, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    private static func parsePostsJSON(json: JSON) ->[NewsItem]{
        
        var newsItems = [NewsItem]()
        
        for (_,postJson):(String, JSON) in json["news"]["items"] {
            
            let post = NewsItem()
            
            post.title = postJson["title"].stringValue
            post.link = postJson["link"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["pubdate"].stringValue, formatStr: "E, d MMM yyyy HH:mm:ss Z")
            
            newsItems.append(post)
        }
        return newsItems
    }
}

