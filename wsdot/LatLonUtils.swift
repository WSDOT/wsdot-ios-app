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
    static func haversine(_ latA: Double, lonA: Double, latB: Double, lonB: Double) -> Int {
        
        let radius: Double = 20902200; // feet
        
        let deltaP = self.toRadians(latA - latB)
        let deltaL = self.toRadians(lonA - lonB)
        let a = sin(deltaP/2) * sin(deltaP/2) + cos(self.toRadians(latB)) * cos(self.toRadians(latA)) * sin(deltaL/2) * sin(deltaL/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = radius * c
        return Int(d)
        
    }
    
    fileprivate static func toRadians (_ degrees: Double) -> Double {
        return degrees * M_PI / 180
    }
    
    static func lineABSegmentDistanceFrom(pointP: CLLocationCoordinate2D, pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D) -> Float {
    
        let dAP = CGPoint(x: pointP.longitude - pointA.longitude, y: pointP.latitude - pointA.latitude)
        let dAB = CGPoint(x: pointB.longitude - pointA.longitude, y: pointB.latitude - pointA.latitude)
        
        let dot = dAP.x * dAB.x + dAP.y * dAB.y
        let squareLength = dAB.x * dAB.x + dAB.y * dAB.y
        
        let param = dot / squareLength
    
        var nearestPoint = CGPoint()
        
        if (param < 0 || (pointA.longitude == pointB.longitude && pointA.latitude == pointB.latitude)) {
            nearestPoint.x = CGFloat(pointA.longitude)
            nearestPoint.y = CGFloat(pointA.latitude)
        } else if (param > 1) {
            nearestPoint.x = CGFloat(pointB.longitude)
            nearestPoint.y = CGFloat(pointB.latitude)
        } else {
            nearestPoint.x = CGFloat(pointA.longitude) + param * dAB.x
            nearestPoint.y = CGFloat(pointA.latitude) + param * dAB.y
        }

        let dx: Float = Float(pointP.longitude) - Float(nearestPoint.x)
        let dy: Float = Float(pointP.latitude) - Float(nearestPoint.y)
        
        return sqrtf((dx * dx) + (dy * dy));
    
    }
    
}
