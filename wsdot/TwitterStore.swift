//
//  TwitterStore.swift
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
            post.published = TimeUtils.postPubDateToNSDate(postJson["created_at"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", isUTC: true)
            
            tweets.append(post)
        }
        return tweets
    }
}



