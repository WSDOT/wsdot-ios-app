//
//  RestAreaStore.swift
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

import SwiftyJSON

class RestAreaStore {

    static func readRestAreas() -> [RestAreaItem] {
    
        var restareas = [RestAreaItem]()
        if let path = Bundle.main.path(forResource: "restareas", ofType: "json"){
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            let json = JSON(data: data!, options: JSONSerialization.ReadingOptions.AllowFragments, error: nil)
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
