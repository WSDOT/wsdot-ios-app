//
//  FlickrStore.swift
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

class FlickrStore {
    
    typealias FetchFlickrPostsCompletion = (_ data: [FlickrItem]?, _ error: NSError?) -> ()
    
    static func getPosts(_ completion: @escaping FetchFlickrPostsCompletion) {
        
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
    
    fileprivate static func parsePostsJSON(_ json: JSON) ->[FlickrItem]{
        
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
