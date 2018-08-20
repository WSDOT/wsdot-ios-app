//
//  I405TollRateItem.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

class TollRateSignItem: Object {

    @objc dynamic var startLocationName: String = ""
    public func setCompoundLocationName(name: String) {
        self.startLocationName = name
        compoundKey = compoundKeyValue()
    }
    
    @objc dynamic var travelDirection: String = ""
    public func setCompoundTravelDirection(direction: String) {
        self.travelDirection = direction
        compoundKey = compoundKeyValue()
    }
    
    // Key for this item is a combination of start location and travel direction
    @objc dynamic var compoundKey: String = "-"
    
    override static func primaryKey() -> String? {
        return "compoundKey"
    }
    
    private func compoundKeyValue() -> String {
        return "\(startLocationName)-\(travelDirection)"
    }
    
    @objc dynamic var locationTitle: String = ""
    @objc dynamic var selected: Bool = false
    @objc dynamic var stateRoute: Int = 0
    @objc dynamic var milepost: Int = 0
    @objc dynamic var startLatitude: Double = 0.0
    @objc dynamic var startLongitude: Double = 0.0
    
    var trips = List<TollTripItem>()

    @objc dynamic var delete: Bool = false

}

