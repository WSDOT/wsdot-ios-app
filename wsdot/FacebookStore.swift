//
//  FacebookStore.swift
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