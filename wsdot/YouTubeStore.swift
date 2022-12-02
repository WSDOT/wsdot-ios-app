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

class YouTubeStore: Decodable {

    typealias FetchVideosCompletion = (_ data: [YouTubeItem]?, _ error: Error?) -> ()
    
    static func getVideos(_ completion: @escaping FetchVideosCompletion) {
        
        AF.request("https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=10&playlistId=UUmWr7UYgRp4v_HvRfEgquXg&key=" + ApiKeys.getGoogleAPIKey()).validate().responseDecodable(of: YouTubeStore.self) { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    let videoItems = parsePostsJSON(json)
                    completion(videoItems, nil)
                }
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    fileprivate static func parsePostsJSON(_ json: JSON) ->[YouTubeItem]{
        
        var videoItems = [YouTubeItem]()
        
        for (_,postJson):(String, JSON) in json["items"] {
            
            let post = YouTubeItem()
            
            post.title = postJson["snippet"]["title"].stringValue
            post.link = "https://www.youtube.com/watch?v=" + postJson["snippet"]["resourceId"]["videoId"].stringValue
            post.thumbnailLink = postJson["snippet"]["thumbnails"]["default"]["url"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["snippet"]["publishedAt"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss'Z'", isUTC: true)
     
            videoItems.append(post)
        }
        return videoItems
    }
}


