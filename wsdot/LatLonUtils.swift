//
//  LatLonUtils.swift
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
import Foundation


class LatLonUtils {
    
    /*
     * Haversine formula
     *
     * Provides great-circle distances between two points on a sphere from
     * their longitudes and latitudes in feet.
     *
     * http://en.wikipedia.org/wiki/Haversine_formula
     *
     */
    static func haversine(latA: Double, lonA: Double, latB: Double, lonB: Double) -> Int {
        
        let radius: Double = 20902200; // feet
        
        let deltaP = self.toRadians(latA - latB)
        let deltaL = self.toRadians(lonA - lonB)
        let a = sin(deltaP/2) * sin(deltaP/2) + cos(self.toRadians(latB)) * cos(self.toRadians(latA)) * sin(deltaL/2) * sin(deltaL/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = radius * c
        return Int(d)
        
    }
    
    private static func toRadians (degrees: Double) -> Double {
        return degrees * M_PI / 180
    }
    
}
