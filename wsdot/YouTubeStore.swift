//
//  YouTubeStore.swift
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

class YouTubeStore {

    typealias FetchVideosCompletion = (_ data: [YouTubeItem]?, _ error: NSError?) -> ()
    
    static func getVideos(_ completion: @escaping FetchVideosCompletion) {
        
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
    
    fileprivate static func parsePostsJSON(_ json: JSON) ->[YouTubeItem]{
        
        var videoItems = [YouTubeItem]()
        
        for (_,postJson):(String, JSON) in json["items"] {
            
            let post = YouTubeItem()
            
            post.title = postJson["snippet"]["title"].stringValue
            post.link = "http://www.youtube.com/watch?v=" + postJson["snippet"]["resourceId"]["videoId"].stringValue
            post.thumbnailLink = postJson["snippet"]["thumbnails"]["default"]["url"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["snippet"]["publishedAt"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", isUTC: true)
            
            videoItems.append(post)
        }
        return videoItems
    }
}


