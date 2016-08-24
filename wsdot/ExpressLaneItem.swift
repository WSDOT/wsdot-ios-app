//
//  ExpressLanesItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import Foundation

class ExpressLaneItem {

    let route: String
    let direction: String
    let updated: String
    
    init(route: String, direction: String, updated: String){
        self.route = route
        self.direction = direction
        self.updated = updated
    }
}
