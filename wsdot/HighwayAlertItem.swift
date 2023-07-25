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

    @objc dynamic var alertId: Int = 0
    @objc dynamic var priority: String = ""
    @objc dynamic var region: String = ""
    @objc dynamic var eventCategory: String = ""
    @objc dynamic var headlineDesc: String = ""
    @objc dynamic var eventStatus: String = ""
    @objc dynamic var startDirection: String = ""
    @objc dynamic var lastUpdatedTime = Date()

    @objc dynamic var startTime = Date()
    
    @objc dynamic var startLatitude: Double = 0.0
    @objc dynamic var startLongitude: Double = 0.0
    @objc dynamic var endLatitude: Double = 0.0
    @objc dynamic var endLongitude: Double = 0.0
    @objc dynamic var travelCenterPriorityId: Int = 0

    @objc dynamic var county: String? = nil
    @objc dynamic var endTime: Date? = nil
    @objc dynamic var extendedDesc: String? = nil
    
    @objc dynamic var delete = false

    override static func primaryKey() -> String? {
        return "alertId"
    }
}
