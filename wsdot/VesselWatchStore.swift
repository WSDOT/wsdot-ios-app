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
class VesselWatchStore: Decodable {

    typealias FetchVesselCompletion = (_ data: VesselItem?, _ error: Error?) -> ()
    typealias FetchVesselsCompletion = (_ data: [VesselItem]?, _ error: Error?) -> ()
    
    static func getVessels(_ completion: @escaping FetchVesselsCompletion) {
        
        AF.request("https://www.wsdot.wa.gov/ferries/api/vessels/rest/vessellocations?apiaccesscode=" + ApiKeys.getWSDOTKey()).validate().responseDecodable(of: VesselWatchStore.self) { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    let vessels = parseVesselsJSON(json)
                    completion(vessels, nil)
                }
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
    
    static func getVesselForTerminalCombo(_ departingTerminalID: Int, arrivingTerminalID: Int, completion: @escaping FetchVesselCompletion) {
    
        AF.request("https://www.wsdot.wa.gov/ferries/api/vessels/rest/vessellocations?apiaccesscode=" + ApiKeys.getWSDOTKey()).validate().responseDecodable(of: VesselWatchStore.self) { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    let vessels = parseVesselsJSON(json)
                    
                    for vessel in vessels {
                        if vessel.departingTerminalID == departingTerminalID && vessel.arrivingTerminalID == arrivingTerminalID {
                            completion(vessel, nil)
                            return
                        }
                    }
                    
                    completion(nil, nil)
                }
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    
    
    }
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
     static func parseVesselsJSON(_ json: JSON) ->[VesselItem]{
        
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
            
            if let atDock = vesselJson["AtDock"].bool {
                vessel.atDock = atDock
            }
            
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
            
            if let arrTermId = vesselJson["ArrivingTerminalID"].int {
                vessel.arrivingTerminalID = arrTermId
            }
            
            if let deptTermId = vesselJson["DepartingTerminalID"].int {
                vessel.departingTerminalID = deptTermId
            }
            
            let routes = vesselJson["OpRouteAbbrev"].arrayValue
            
            if (routes.count > 0){
                vessel.route = routes[0].stringValue.uppercased()
            }
            
            vessels.append(vessel)
        }
        return vessels
    }
    
    static func getRouteLocation(scheduleId: Int) -> CLLocationCoordinate2D {

        switch (scheduleId) {
            case 272: // Ana-SJ
                return CLLocationCoordinate2D(latitude: 48.550921, longitude: -122.840836);
            case 9: // Ana-SJ
                return CLLocationCoordinate2D(latitude: 48.550921, longitude: -122.840836);
            case 10: // Ana-Sid
                return CLLocationCoordinate2D(latitude: 48.550921, longitude: -122.840836);
            case 6: // Ed-King
                return CLLocationCoordinate2D(latitude: 47.803096, longitude: -122.438718);
            case 13: // F-S
                return CLLocationCoordinate2D(latitude: 47.513625, longitude: -122.450820);
            case 14: // F-V
                return CLLocationCoordinate2D(latitude: 47.513625, longitude: -122.450820);
            case 7: // Muk-Cl
                return CLLocationCoordinate2D(latitude: 47.963857, longitude: -122.327721);
            case 8: // Pt-Key
                return CLLocationCoordinate2D(latitude: 48.135562, longitude: -122.714449);
            case 1: // Pd-Tal
                return CLLocationCoordinate2D(latitude: 47.319040, longitude: -122.510890);
            case 5: // Sea-Bi
                return CLLocationCoordinate2D(latitude: 47.600325, longitude: -122.437249);
            case 3: // Sea-Br
                return CLLocationCoordinate2D(latitude: 47.565125, longitude: -122.480508);
            case 15: // S-V
                return CLLocationCoordinate2D(latitude: 47.513625, longitude: -122.450820);
            default:
                return CLLocationCoordinate2D(latitude: 47.565125, longitude: -122.480508);
        }
    }

    static func getRouteZoom(scheduleId: Int) -> Float {
        switch (scheduleId) {
            case 272: // Ana-SJ
                return 10;
            case 9: // Ana-SJ
                return 10;
            case 10: // Ana-Sid
                return 10;
            case 6: // Ed-King
                return 12;
            case 13: // F-S
                return 12;
            case 14: // F-V
                return 12;
            case 7: // Muk-Cl
                return 13;
            case 8: // Pt-Key
                return 12;
            case 1: // Pd-Tal
                return 13;
            case 5: // Sea-Bi
                return 11;
            case 3: // Sea-Br
                return 10;
            case 15: // S-V
                return 12;
            default:
                return 11;
        }
    }
}
