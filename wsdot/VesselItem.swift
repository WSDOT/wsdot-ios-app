//
//  VesselItem.swift
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
import UIKit

class VesselItem {
    let vesselID: Int
    let vesselName: String
    let inService: Bool
    
    fileprivate let directions = ["N", "NxE", "E", "SxE", "S", "SxW", "W", "NxW", "N"]
    
    var headText: String {
        get {
            return directions[Int(round(((Double(heading).truncatingRemainder(dividingBy: 360)) / 45)))]
        }
    }
    
    var icon: UIImage {
        get {
            return UIImage(named: "ferry" + String( (heading + 30 / 2) / 30 * 30))!// round heading to nearest 30 degrees
        }
    }
    
    let heading: Int
    let lat: Double
    let lon: Double
    let speed: Float
    let updateTime: Date
   
    var route: String = "Not Available"
    var arrivingTerminal = "N/A"
    var departingTerminal = "N/A"
    
    var arrivingTerminalID = -1
    var departingTerminalID = -1
    
    var nextDeparture: Date? = nil
    var leftDock: Date? = nil
    var eta: Date? = nil
    
    var atDock: Bool = true
    
    init(id: Int, name: String, lat: Double, lon: Double, heading: Int, speed: Float, inService: Bool, updated: Date) {
        self.vesselName = name
        self.vesselID = id
        self.lat = lat
        self.lon = lon
        self.heading = heading
        self.speed = speed
        self.inService = inService
        self.updateTime = updated
    }
}
