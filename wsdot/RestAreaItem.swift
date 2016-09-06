//
//  RestAreaItem.swift
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
class RestAreaItem {

    let route: String
    let location: String
    let description: String
    let milepost: Int
    let direction: String
    let latitude: Double
    let longitude: Double
    let notes: String?
    let hasDump: Bool
    let isOpen: Bool
    let amenities: [String]

    init(route: String, location: String, description: String, milepost: Int, direction: String, latitude: Double, longitude: Double, notes: String?, hasDump: Bool, isOpen: Bool, amenities: [String]){
        self.route = route
        self.location = location
        self.description = description
        self.milepost = milepost
        self.direction = direction
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.hasDump = hasDump
        self.isOpen = isOpen
        self.amenities = amenities
    }
}