//
//  FerriesTerminalMap.swift
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

struct FerriesConsts {
    
    let terminalMap: [Int : FerriesTerminalItem]
    
    init() {
        terminalMap = [
        1: FerriesTerminalItem(id: 1, name: "Anacortes", lat: 48.507351, long: -122.677),
        3: FerriesTerminalItem(id: 3, name: "Bainbridge Island", lat: 47.622339, long: -122.509617),
        4: FerriesTerminalItem(id: 4, name: "Bremerton", lat: 47.561847, long: -122.624089),
        5: FerriesTerminalItem(id: 5, name: "Clinton", lat: 47.9754, long: -122.349581),
        8: FerriesTerminalItem(id: 8, name: "Edmonds", lat: 47.813378, long: -122.385378),
        7: FerriesTerminalItem(id: 7, name: "Seattle", lat: 47.602501, long: -122.340472),
        9: FerriesTerminalItem(id: 9, name: "Fauntleroy", lat: 47.5232, long: -122.3967),
        10: FerriesTerminalItem(id: 10, name: "Friday Harbor", lat: 48.535783, long: -123.013844),
        11: FerriesTerminalItem(id: 11, name: "Coupeville", lat: 48.159008, long: -122.672603),
        12: FerriesTerminalItem(id: 12, name: "Kingston", lat: 47.794606, long: -122.494328),
        13: FerriesTerminalItem(id: 13, name: "Lopez Island", lat: 48.570928, long: -122.882764),
        14: FerriesTerminalItem(id: 14, name: "Mukilteo", lat: 47.949544, long: -122.304997),
        15: FerriesTerminalItem(id: 15, name: "Orcas Island", lat: 48.597333, long: -122.943494),
        16: FerriesTerminalItem(id: 16, name: "Point Defiance", lat: 47.306519, long: -122.514053),
        17: FerriesTerminalItem(id: 17, name: "Port Townsend", lat: 48.110847, long: -122.759039),
        18: FerriesTerminalItem(id: 18, name: "Shaw Island", lat: 48.584792, long: -122.92965),
        19: FerriesTerminalItem(id: 19, name: "Sidney B.C.", lat: 48.643114, long: -123.396739),
        20: FerriesTerminalItem(id: 20, name: "Southworth", lat: 47.513064, long: -122.495742),
        21: FerriesTerminalItem(id: 21, name: "Tahlequah", lat: 47.331961, long: -122.507786),
        22: FerriesTerminalItem(id: 22, name: "Vashon Island", lat: 47.51095, long: -122.463639)
        ]
    }
}
