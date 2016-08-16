//
//  VesselItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/16/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class VesselItem {
    let vesselID: Int
    let vesselName: String
    let inService: Bool
    
    private let directions = ["N", "NxE", "E", "SxE", "S", "SxW", "W", "NxW", "N"]
    
    var headText: String {
        get {
            return directions[Int(round(((Double(heading) % 360) / 45)))]
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
    let updateTime: NSDate
   
    var route: String = "Not available"
    var arrivingTerminal = "Not available"
    var departingTerminal = "Not available"
    
    var nextDeparture: NSDate? = nil
    var leftDock: NSDate? = nil
    var eta: NSDate? = nil
    
    init(id: Int, name: String, lat: Double, lon: Double, heading: Int, speed: Float, inService: Bool, updated: NSDate) {
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