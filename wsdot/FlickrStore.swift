//
//  FlickrStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/30/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

class FlickrStore {
    
    typealias FetchFlickrPostsCompletion = (data: [FlickrItem]?, error: NSError?) -> ()
    
    static func getPosts(completion: FetchFlickrPostsCompletion) {
        
        Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/FlickrPhotos.js").validate().responseString  { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    // Flickr JSON uses invalid josn characters fo standard RFC 4627, remove them here.
                    let json = JSON.parse(value.stringByReplacingOccurrencesOfString("\\'", withString: "'", options: NSStringCompareOptions.LiteralSearch, range: nil))
     
                    let posts = parsePostsJSON(json)
                    completion(data: posts, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    private static func parsePostsJSON(json: JSON) ->[FlickrItem]{
        
        var posts = [FlickrItem]()
        
        for (_,postJson):(String, JSON) in json["items"] {
            
            let post = FlickrItem()
            post.title = postJson["title"].stringValue
            post.link = postJson["link"].stringValue
            post.mediaLink = postJson["media"]["m"].stringValue
            
            posts.append(post)
        }
        return posts
    }
}