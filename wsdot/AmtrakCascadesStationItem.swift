//
//  AmtrakStationItem.swift
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

// Data about an Amtrak station, it's name, code, location and distance from user.
class AmtrakCascadesStationItem {
    
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    var distance: Int = -1
    
    init(id: String, name: String, lat: Double, lon: Double){
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
