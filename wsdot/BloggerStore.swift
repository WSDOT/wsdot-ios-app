//
//  BloggerStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/29/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BloggerStore {

    typealias FetchBlogPostsCompletion = (data: [BlogItem]?, error: NSError?) -> ()
    
    static func getBlogPosts(completion: FetchBlogPostsCompletion) {
        
        Alamofire.request(.GET, "http://wsdotblog.blogspot.com/feeds/posts/default?alt=json&max-results=10").validate().responseJSON { response in
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
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parsePostsJSON(json: JSON) ->[BlogItem]{
        
        var posts = [BlogItem]()
        
        for (_,postJson):(String, JSON) in json["feed"]["entry"] {
            
            let post = BlogItem()
            
            post.title = postJson["title"]["$t"].stringValue
            post.content = postJson["content"]["$t"].stringValue
                .stringByReplacingOccurrencesOfString("<i>(.*)</i><br /><br />", withString: "", options: .RegularExpressionSearch, range: nil)
                .stringByReplacingOccurrencesOfString("<em>(.*)</em><br /><br />", withString: "", options: .RegularExpressionSearch, range: nil)
                .stringByReplacingOccurrencesOfString("<table(.*?)>.*?</table>", withString: "", options: .RegularExpressionSearch, range: nil)
                .stringByReplacingOccurrencesOfString("&nbsp;", withString:" ")
                .stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
 
            post.link = postJson["link"][4]["href"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["published"]["$t"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss.sssZ")
            post.imageUrl = postJson["media$thumbnail"]["url"].stringValue
            
            posts.append(post)
        }
        return posts
    }
}

