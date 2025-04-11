//
//  TravelTimeItem.swift
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

// v3
class TravelTimeItem: Object {

    @objc dynamic var routeid: Int = 0
    @objc dynamic var viaText: String = ""
    
    @objc dynamic var startLatitude: Double = 0.0
    @objc dynamic var startLongitude: Double = 0.0
    @objc dynamic var endLatitude: Double = 0.0
    @objc dynamic var endLongitude: Double = 0.0
    
    @objc dynamic var distance: Float = 0.0
    
    @objc dynamic var averageTime: Int = 0
    @objc dynamic var currentTime: Int = 0
    @objc dynamic var hovCurrentTime: Int = 0
    
    @objc dynamic var status: String = ""

    @objc dynamic var updated: String = ""
    
    @objc dynamic var title: String = ""
    
    @objc dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "routeid"
    }

}

/*
// v2
class TravelTimeItem: Object {

    dynamic var routeid: Int = 0
    dynamic var title: String = ""
    
    dynamic var startLatitude: Double = 0.0
    dynamic var startLongitude: Double = 0.0
    dynamic var endLatitude: Double = 0.0
    dynamic var endLongitude: Double = 0.0
    
    dynamic var distance: Float = 0.0
    dynamic var averageTime: Int = 0
    dynamic var currentTime: Int = 0
    dynamic var updated: String = ""
    dynamic var selected: Bool = false
    dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "routeId"
    }
}
*/

/*
// v1
class TravelTimeItem: Object {
    dynamic var routeid: Int = 0
    dynamic var title: String = ""
    dynamic var distance: Float = 0.0
    dynamic var averageTime: Int = 0
    dynamic var currentTime: Int = 0
    dynamic var updated: String = ""
    dynamic var selected: Bool = false
    dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "routeid"
    }
}
*/
