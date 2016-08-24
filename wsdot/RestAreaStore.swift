//
//  RestAreaStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import SwiftyJSON

class RestAreaStore {

    static func readRestAreas() -> [RestAreaItem] {
    
        var restareas = [RestAreaItem]()
        if let path = NSBundle.mainBundle().pathForResource("restareas", ofType: "json"){
            let data = NSData(contentsOfFile: path)
            let json = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            for (_,restareaJson):(String, JSON) in json {
                let restarea = RestAreaItem(route: restareaJson["route"].stringValue,
                                            location: restareaJson["location"].stringValue,
                                            description: restareaJson["description"].stringValue,
                                            milepost: restareaJson["milepost"].intValue,
                                            direction: restareaJson["direction"].stringValue,
                                            latitude: restareaJson["latitude"].doubleValue,
                                            longitude: restareaJson["longitude"].doubleValue,
                                            notes: restareaJson["notes"].string,
                                            hasDump: restareaJson["hasDump"].boolValue,
                                            isOpen: restareaJson["isOpen"].boolValue,
                                            amenities: restareaJson["amenities"].arrayValue.map { $0.stringValue})
            
                restareas.append(restarea)
        
            }
        }else {
            print("failed to open file?")
        }
        return restareas
    }
}