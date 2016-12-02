//
//  VesselWatchStore.swift
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

/*
 *  Gets Vessel Watch data from JSON API.
 */
class VesselWatchStore {

    typealias FetchVesselsCompletion = (_ data: [VesselItem]?, _ error: NSError?) -> ()
    
    static func getVessels(_ completion: @escaping FetchVesselsCompletion) {
        
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
    fileprivate static func parseVesselsJSON(_ json: JSON) ->[VesselItem]{
        
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
                vessel.route = routes[0].stringValue.uppercased()
            }
            
            vessels.append(vessel)
        }
        return vessels
    }
}
