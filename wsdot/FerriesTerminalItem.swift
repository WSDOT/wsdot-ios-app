//
//  FerriesTerminalItem.swift
//  WSDOT
//
//  Created by Logan Sims on 7/27/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation

class FerriesTerminalItem {
    let terminalName: String
    let terminalId: Int
    let latitude: Double
    let longitude: Double

    init(id : Int, name : String, lat: Double, long: Double) {
        self.latitude = lat
        self.terminalName = name
        self.terminalId = id
        self.longitude = long
    }
}
