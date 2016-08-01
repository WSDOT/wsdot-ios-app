//
//  LatLonUtils.swift
//  WSDOT
//
//  Created by Logan Sims on 7/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
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
