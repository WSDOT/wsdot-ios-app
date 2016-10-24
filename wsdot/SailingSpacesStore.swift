//
//  FerriesSailingSpacesStore.swift
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
 * Gets sailing space information from JSON API
 */
class SailingSpacesStore {

    typealias FetchSailingSpaceCompletion = (data: [SailingSpacesItem]?, error: NSError?) -> ()
    
    // Returns sailing space data from API. 
    static func getSailingSpacesForTerminal(departingId: Int, arrivingId: Int, completion: FetchSailingSpaceCompletion) {
        
        Alamofire.request(.GET, "http://www.wsdot.wa.gov/ferries/api/terminals/rest/terminalsailingspace/" + String(departingId) + "?apiaccesscode=" + ApiKeys.wsdot_key).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let sailingSpaces = parseSailingSpacesJSON(departingId, arrivingId: arrivingId, json: json)
                    completion(data: sailingSpaces, error: nil)
                }
            case .Failure(let error):
                if let code = response.response?.statusCode {
                    if code == 400{
                        completion(data: [SailingSpacesItem](), error: error)
                    } else {
                        completion(data: nil, error: error)
                    }
                } else {
                    completion(data: nil, error: error)
                }
            }
        }
    }
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseSailingSpacesJSON(departingId: Int, arrivingId: Int, json: JSON) ->[SailingSpacesItem]{
        
        var sailingSpaces = [SailingSpacesItem]()
        var hasSailingSpace = false

        for (_,departure):(String, JSON) in json["DepartingSpaces"] {
                    
            for (_,arrivingTerminalSpace):(String, JSON) in departure["SpaceForArrivalTerminals"] {
                        
                let sailingSpaceItem = SailingSpacesItem()
                hasSailingSpace = false
                        
                for (_,arrivalTermials):(String, JSON) in arrivingTerminalSpace["ArrivalTerminalIDs"]{
                    if( arrivalTermials.intValue == arrivingId){
                        hasSailingSpace = true
                        sailingSpaceItem.date = TimeUtils.parseJSONDateToNSDate(departure["Departure"].stringValue)
                        sailingSpaceItem.maxSpace = arrivingTerminalSpace["MaxSpaceCount"].intValue
                        sailingSpaceItem.remainingSpaces = arrivingTerminalSpace["DriveUpSpaceCount"].intValue
                    }
                }
                        
                if (arrivingTerminalSpace["TerminalID"].int == arrivingId){
                    hasSailingSpace = true
                    sailingSpaceItem.date = TimeUtils.parseJSONDateToNSDate(departure["Departure"].stringValue)
                    sailingSpaceItem.maxSpace = arrivingTerminalSpace["MaxSpaceCount"].intValue
                    sailingSpaceItem.remainingSpaces = arrivingTerminalSpace["DriveUpSpaceCount"].intValue
                }
                        
                if (hasSailingSpace){
                    sailingSpaces.append(sailingSpaceItem)
                }
            }
  
        }
        return sailingSpaces
    }
}
