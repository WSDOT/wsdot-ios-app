//
//  MountianPassItem.swift
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
    let cameraIds = List<PassCameraIDItem>()
    let forecast = List<ForecastItem>()
    
    dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
