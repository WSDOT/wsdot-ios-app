//
//  YouTubeStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON

class YouTubeStore {

    typealias FetchVideosCompletion = (data: [YouTubeItem]?, error: NSError?) -> ()
    
    static func getVideos(completion: FetchVideosCompletion) {
        
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=10&playlistId=UUmWr7UYgRp4v_HvRfEgquXg&key=" + ApiKeys.google_key).validate().responseJSON { response in
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
    
    private static func parsePostsJSON(json: JSON) ->[YouTubeItem]{
        
        var newsItems = [YouTubeItem]()
        
        for (_,postJson):(String, JSON) in json["items"] {
            
            let post = YouTubeItem()
            
            post.title = postJson["snippet"]["title"].stringValue
            post.link = "http://www.youtube.com/watch?v=" + postJson["id"].stringValue
            post.thumbnailLink = postJson["snippet"]["thumbnails"]["default"]["url"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["snippet"]["publishedAt"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            
            newsItems.append(post)
        }
        return newsItems
    }
}


