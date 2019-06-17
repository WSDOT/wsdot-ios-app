//
//  BloggerStore.swift
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

class BloggerStore {

    typealias FetchBlogPostsCompletion = (_ data: [BlogItem]?, _ error: Error?) -> ()
    
    static func getBlogPosts(_ completion: @escaping FetchBlogPostsCompletion) {
        
        Alamofire.request("https://wsdotblog.blogspot.com/feeds/posts/default?alt=json&max-results=10").validate().responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
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
    
    fileprivate static func parsePostsJSON(_ json: JSON) ->[BlogItem]{
        
        var posts = [BlogItem]()
        
        for (_,postJson):(String, JSON) in json["feed"]["entry"] {
            
            let post = BlogItem()
            
            post.title = postJson["title"]["$t"].stringValue
            post.content = postJson["content"]["$t"].stringValue
                .replacingOccurrences(of: "<i>(.*)</i><br /><br />", with: "", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "<em>(.*)</em><br /><br />", with: "", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "<table(.*?)>.*?</table>", with: "", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "&nbsp;", with:" ")
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
 
            post.link = postJson["link"][4]["href"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["published"]["$t"].stringValue, formatStr: "yyyy-MM-dd'T'HH:mm:ss.SSSz", isUTC: true)
            post.imageUrl = postJson["media$thumbnail"]["url"].stringValue
            
            posts.append(post)
        }
        return posts
    }
}

