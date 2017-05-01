//
//  ApiKeys.swift
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

struct ApiKeys {
  
    static func getAdId() -> String {
        let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let key = plist?.object(forKey: "AD_UNIT_ID") as! String
        return key
    }
  
    static func getWSDOTKey() -> String {
        let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let key = plist?.object(forKey: "WSDOT_KEY") as! String
        return key
    }
  
    static func getGoogleAPIKey() -> String {
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let key = plist?.object(forKey: "API_KEY") as! String
        return key
    }
}


