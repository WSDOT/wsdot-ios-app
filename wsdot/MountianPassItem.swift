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

    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var weatherCondition: String = ""
    @objc dynamic var elevationInFeet: Int = 0
    let temperatureInFahrenheit = RealmProperty<Int?>()
    @objc dynamic var travelAdvisoryActive: Bool = false
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var roadCondition: String = ""
    @objc dynamic var dateUpdated: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var restrictionOneText: String = ""
    @objc dynamic var restrictionOneTravelDirection: String = ""
    @objc dynamic var restrictionTwoText: String = ""
    @objc dynamic var restrictionTwoTravelDirection: String = ""
    @objc dynamic var selected: Bool = false
    let cameraIds = List<PassCameraIDItem>()
    let forecast = List<ForecastItem>()
    
    @objc dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
