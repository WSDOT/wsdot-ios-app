//
//  FacebookStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/30/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FacebookStore {

    typealias FetchPostsCompletion = (data: [FacebookItem]?, error: NSError?) -> ()
    
    static func getPosts(completion: FetchPostsCompletion) {
        
        Alamofire.request(.GET, "http://www.wsdot.wa.gov/news/socialroom/posts/facebook").validate().responseJSON { response in
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
    
    private static func parsePostsJSON(json: JSON) ->[FacebookItem]{
        
        var posts = [FacebookItem]()
        
        for (_,postJson):(String, JSON) in json {
            
            let post = FacebookItem()
            post.id = postJson["id"].stringValue
            
            post.message = postJson["message"].stringValue
                .stringByReplacingOccurrencesOfString("(https?:\\/\\/[-a-zA-Z0-9._~:\\/?#@!$&\'()*+,;=%]+)", withString: "<a href=\"$1\">$1</a>", options: .RegularExpressionSearch, range: nil)
            
            post.createdAt = TimeUtils.postPubDateToNSDate(postJson["created_time"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ssZ")
            
            posts.append(post)
        }
        return posts
    }
}