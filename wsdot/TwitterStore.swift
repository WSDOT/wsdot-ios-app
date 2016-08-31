//
//  TwitterStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TwitterStore {

    typealias FetchTweetsCompletion = (data: [TwitterItem]?, error: NSError?) -> ()
    
    static func getTweets(screenName: String?, completion: FetchTweetsCompletion) {
        
        var url = "http://www.wsdot.wa.gov/news/socialroom/posts/twitter/"
        
        if let screenNameValue = screenName {
            url = url + screenNameValue
        }
        
        Alamofire.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let videoItems = parsePostsJSON(json)
                    completion(data: videoItems, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    private static func parsePostsJSON(json: JSON) ->[TwitterItem]{
        
        var tweets = [TwitterItem]()
        
        for (_,postJson):(String, JSON) in json {
            
            let post = TwitterItem()
            
            post.id = postJson["id"].stringValue
            post.name = postJson["user"]["name"].stringValue
            post.screenName = postJson["user"]["screen_name"].stringValue
            
            post.text = postJson["text"].stringValue.stringByReplacingOccurrencesOfString("(https?:\\/\\/[-a-zA-Z0-9._~:\\/?#@!$&\'()*+,;=%]+)", withString: "<a href=\"$1\">$1</a>", options: .RegularExpressionSearch, range: nil).stringByReplacingOccurrencesOfString("&amp;", withString:"&")
            
            post.link = "https://twitter.com/" + post.screenName + "/status/" + post.id
            post.mediaUrl = postJson["entities"]["media"][0]["media_url"].string
            post.published = TimeUtils.postPubDateToNSDate(postJson["created_at"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            
            tweets.append(post)
        }
        return tweets
    }
}



