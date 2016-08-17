//
//  VesselWatchStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/16/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class VesselWatchStore {

    typealias FetchVesselsCompletion = (data: [VesselItem]?, error: NSError?) -> ()
    
    static func getVessels(completion: FetchVesselsCompletion) {
        
        Alamofire.request(.GET, "http://www.wsdot.wa.gov/ferries/api/vessels/rest/vessellocations?apiaccesscode=" + ApiKeys.wsdot_key).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let vessels = parseVesselsJSON(json)
                    completion(data: vessels, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseVesselsJSON(json: JSON) ->[VesselItem]{
        
        var vessels = [VesselItem]()
        
        for (_,vesselJson):(String, JSON) in json {
        
            let vessel = VesselItem(id: vesselJson["VesselID"].intValue,
                                    name: vesselJson["VesselName"].stringValue,
                                    lat: vesselJson["Latitude"].doubleValue,
                                    lon: vesselJson["Longitude"].doubleValue,
                                    heading: vesselJson["Heading"].intValue,
                                    speed: vesselJson["Speed"].floatValue,
                                    inService: vesselJson["InService"].boolValue,
                                    updated: TimeUtils.parseJSONDateToNSDate(vesselJson["TimeStamp"].stringValue))
            
            if let timeJson = vesselJson["Eta"].string{
                vessel.eta = TimeUtils.parseJSONDateToNSDate(timeJson)
            }
            
            if let timeJson = vesselJson["LeftDock"].string{
                vessel.leftDock = TimeUtils.parseJSONDateToNSDate(timeJson)
            }
            
            if let timeJson = vesselJson["ScheduledDeparture"].string{
                vessel.nextDeparture = TimeUtils.parseJSONDateToNSDate(timeJson)
            }
            
            if let arrTerm = vesselJson["ArrivingTerminalName"].string{
                vessel.arrivingTerminal = arrTerm
            }
            
            if let deptTerm = vesselJson["DepartingTerminalName"].string {
                vessel.departingTerminal = deptTerm
            }
            
            let routes = vesselJson["OpRouteAbbrev"].arrayValue
            
            if (routes.count > 0){
                vessel.route = routes[0].stringValue.capitalizedString
            }
            
            vessels.append(vessel)
        }
        return vessels
    }
}
