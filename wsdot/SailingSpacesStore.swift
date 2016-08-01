//
//  FerriesSailingSpacesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 7/26/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SailingSpacesStore {

    typealias FetchSailingSpaceCompletion = (data: [SailingSpacesItem]?, error: NSError?) -> ()
    
    static func getSailingSpacesForTerminal(departingId: Int, arrivingId: Int, completion: FetchSailingSpaceCompletion) {
        
        Alamofire.request(.GET, "http://www.wsdot.wa.gov/ferries/api/terminals/rest/terminalsailingspace?apiaccesscode=" + ApiKeys.wsdot_key).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let sailingSpaces = parseSailingSpacesJSON(departingId, arrivingId: arrivingId, json: json)
                    completion(data: sailingSpaces, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    //Converts JSON from api into and array of FerriesRouteScheduleItems
    private static func parseSailingSpacesJSON(departingId: Int, arrivingId: Int, json: JSON) ->[SailingSpacesItem]{
        
        var sailingSpaces = [SailingSpacesItem]()
        var sailingSpaceItem: SailingSpacesItem
        
        for (_,subJson):(String, JSON) in json {
            //print(subJson["TerminalID"].int)
            if (subJson["TerminalID"].int == departingId){
                
                for (_,departure):(String, JSON) in subJson["DepartingSpaces"] {

                    for (_,arrivingTerminalSpace):(String, JSON) in departure["SpaceForArrivalTerminals"] {
                        
                        if (arrivingTerminalSpace["TerminalID"].int == arrivingId){
                            
                            sailingSpaceItem = SailingSpacesItem()
                            sailingSpaceItem.Date = departure["Departure"].stringValue
                            sailingSpaceItem.maxSpace = arrivingTerminalSpace["MaxSpaceCount"].intValue
                            sailingSpaceItem.remainingSpaces = arrivingTerminalSpace["DriveUpSpaceCount"].intValue
                            
                            sailingSpaces.append(sailingSpaceItem)
                            
                        }
                    }
                }
                
            }
        }
        return sailingSpaces
    }
    
}
