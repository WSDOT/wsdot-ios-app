//
//  ExpressLanesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ExpressLanesStore {

    typealias FetchExpressLanesCompletion = (data: [ExpressLaneItem]?, error: NSError?) -> ()
    
    static func getExpressLanes(completion: FetchExpressLanesCompletion) {
        
        Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/ExpressLanes.js").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let expressLanes = parseExpressLanesJSON(json)
                    completion(data: expressLanes, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseExpressLanesJSON(json: JSON) ->[ExpressLaneItem]{
        
        var expressLanes = [ExpressLaneItem]()
        
        for (_,subJson):(String, JSON) in json["express_lanes"]["routes"] {
            let expressLaneItem = ExpressLaneItem(route: subJson["title"].stringValue, direction: subJson["status"].stringValue, updated: subJson["updated"].stringValue)
            expressLanes.append(expressLaneItem)
        }
        return expressLanes
    }
}