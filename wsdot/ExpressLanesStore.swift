//
//  ExpressLanesStore.swift
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
import SwiftyJSON
import Alamofire

class ExpressLanesStore: Decodable {

    typealias FetchExpressLanesCompletion = (_ data: [ExpressLaneItem]?, _ error: Error?) -> ()
    
    static func getExpressLanes(_ completion: @escaping FetchExpressLanesCompletion) {
        
        AF.request("https://data.wsdot.wa.gov/mobile/ExpressLanes.json").validate().responseDecodable(of: ExpressLanesStore.self) { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    let expressLanes = parseExpressLanesJSON(json)
                    completion(expressLanes, nil)
                }
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    fileprivate static func parseExpressLanesJSON(_ json: JSON) ->[ExpressLaneItem]{
        
        var expressLanes = [ExpressLaneItem]()
        
        for (_,subJson):(String, JSON) in json["express_lanes"]["routes"] {
            let expressLaneItem = ExpressLaneItem(route: subJson["title"].stringValue, direction: subJson["status"].stringValue, updated: subJson["updated"].stringValue)
            expressLanes.append(expressLaneItem)
        }
        return expressLanes
    }
}
