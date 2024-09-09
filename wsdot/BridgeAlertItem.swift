//
//  BridgeAlertItem.swift
//  WSDOT
//
//  Copyright (c) 2024 Washington State Department of Transportation
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

class BridgeAlertItem: Object {

    @objc dynamic var alertId: Int = 0
    @objc dynamic var bridge: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var duration: String = ""
    @objc dynamic var descText: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var milepost: Double = 0.0
    @objc dynamic var direction: String = ""
    @objc dynamic var roadName: String = ""
    @objc dynamic var priority: String = ""
    @objc dynamic var travelCenterPriorityId: Int = 0
    @objc dynamic var eventCategory: String = ""
    @objc dynamic var openingTime: Date? = nil
    @objc dynamic var lastUpdatedTime = Date()
    @objc dynamic var delete = false

    override static func primaryKey() -> String? {
        return "alertId"
    }
}

