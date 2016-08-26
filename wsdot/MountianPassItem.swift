//
//  MountianPassItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import RealmSwift

class MountainPassItem: Object {

    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var weatherCondition: String = ""
    dynamic var elevationInFeet: Int = 0
    let temperatureInFahrenheit = RealmOptional<Int>()
    dynamic var travelAdvisoryActive: Bool = false
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var roadCondition: String = ""
    dynamic var dateUpdated: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var restrictionOneText: String = ""
    dynamic var restrictionOneTravelDirection: String = ""
    dynamic var restrictionTwoText: String = ""
    dynamic var restrictionTwoTravelDirection: String = ""
    dynamic var selected: Bool = false
    let cameras = List<CameraItem>()
    let forecast = List<ForecastItem>()
    
    dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}