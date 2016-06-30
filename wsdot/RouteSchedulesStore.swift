//
//  RouteSchedulesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
// TODO: Database logic

import Foundation
import Alamofire
import SwiftyJSON

class RouteSchedulesStore {

    typealias FetchRouteScheduleCompletion = (data: [FerriesRouteScheduleItem]?, error: NSError?) -> ()

    // a function definition that takes a function as an argument (its completion function)
    static func getRouteSchedules(completion: FetchRouteScheduleCompletion) {
        // do asyncrounous work
        Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js").validate().responseJSON { response in
            switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        //print("JSON: \(json)")
                        completion(data: self.parseRouteSchedulesJSON(json), error: nil)
                    }
                case .Failure(let error):
                    print(error)
                    completion(data: nil, error: error)
            }
        }
    }

    
    private static func parseRouteSchedulesJSON(json: JSON) ->[FerriesRouteScheduleItem]{
    
        var routeSchedules = [FerriesRouteScheduleItem]()
    
        for (index,subJson):(String, JSON) in json {
            let route = FerriesRouteScheduleItem(description: subJson["Description"].stringValue, id: subJson["RouteID"].intValue)
            routeSchedules.append(route)
        }
    
    
        return routeSchedules
    }
    
    // TODO: implement
    private static func parseRouteAlertJSON(json: JSON) ->[FerriesRouteAlertItem]{
        return [FerriesRouteAlertItem]()
    }
    
    // TODO: implement
    private static func parseRouteDatesJSON(json: JSON) ->[FerriesScheduleDateItem]{
        return [FerriesScheduleDateItem]()
    }
}
