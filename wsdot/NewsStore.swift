//
//  NewsStore.swift
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

class NewsStore: Decodable {

    typealias FetchNewsCompletion = (_ data: [NewsItem]?, _ error: Error?) -> ()
    
    static func getNews(_ completion: @escaping FetchNewsCompletion) {
        
        AF.request("https://data.wsdot.wa.gov/mobile/News.js").validate().responseDecodable(of: NewsStore.self) { response in
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
    
    fileprivate static func parsePostsJSON(_ json: JSON) ->[NewsItem]{
        
        var newsItems = [NewsItem]()
        
        for (_,postJson):(String, JSON) in json["news"]["items"] {
            
            let post = NewsItem()
            
            post.title = postJson["title"].stringValue
            post.link = postJson["link"].stringValue
            post.published = TimeUtils.postPubDateToNSDate(postJson["pubdate"].stringValue, formatStr: "E, d MMM yyyy HH:mm:ss Z", isUTC: true)
            
            newsItems.append(post)
        }
        return newsItems
    }
}

