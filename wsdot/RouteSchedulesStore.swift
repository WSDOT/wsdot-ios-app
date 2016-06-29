//
//  RouteSchedulesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
/* TODO: 
    Check Database for data
        if there and current return
        if there and NOT current fetch, save to DB, return
        if NOT there fetch, save, return
*/
import Foundation
import Alamofire

class RouteSchedulesStore {

    static func getRouteSchedules() -> [FerriesRouteScheduleItem]{
        Alamofire.request(.GET, "http://data.wsdot.wa.gov/mobile/WSFRouteSchedules.js.gz")
         .responseJSON { response in
             print(response.request)  // original URL request
             print(response.response) // URL response
             print(response.data)     // server data
             print(response.result)   // result of response serialization

             if let JSON = response.result.value {
                 print("JSON: \(JSON)")
             }
        }
        return [FerriesRouteScheduleItem]()
    }
}
