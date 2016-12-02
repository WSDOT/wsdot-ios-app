//
//  HighwayAlertItem.swift
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

class HighwayAlertItem: Object {

    dynamic var alertId: Int = 0
    dynamic var priority: String = ""
    dynamic var region: String = ""
    dynamic var eventCategory: String = ""
    dynamic var headlineDesc: String = ""
    dynamic var eventStatus: String = ""
    dynamic var startDirection: String = ""
    dynamic var lastUpdatedTime = Date()

    dynamic var startTime = Date()
    
    dynamic var startLatitude: Double = 0.0
    dynamic var startLongitude: Double = 0.0
    dynamic var endLatitude: Double = 0.0
    dynamic var endLongitude: Double = 0.0
    
    dynamic var county: String? = nil
    dynamic var endTime: Date? = nil
    dynamic var extendedDesc: String? = nil
    
    dynamic var delete = false

    override static func primaryKey() -> String? {
        return "alertId"
    }
}
