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

    typealias FetchPostsCompletion = (_ data: [FacebookItem]?, _ error: Error?) -> ()
    
    static func getPosts(_ completion: @escaping FetchPostsCompletion) {
        
        AF.request("https://www.wsdot.wa.gov/news/socialroom/posts/facebook").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    let posts = parsePostsJSON(json)
                    completion(posts, nil)
                }
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func parsePostsJSON(_ json: JSON) ->[FacebookItem]{
        
        var posts = [FacebookItem]()
        
        for (_,postJson):(String, JSON) in json {
            
            let post = FacebookItem()
            post.id = postJson["id"].stringValue
            
            post.message = postJson["message"].stringValue
                .replacingOccurrences(of: "(https?:\\/\\/[-a-zA-Z0-9._~:\\/?#@!$&\'()*+,;=%]+)", with: "<a href=\"$1\">$1</a>", options: .regularExpression, range: nil)
            
            post.createdAt = TimeUtils.postPubDateToNSDate(postJson["created_time"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ssZ", isUTC: true)
            
            posts.append(post)
        }
        return posts
    }
}
