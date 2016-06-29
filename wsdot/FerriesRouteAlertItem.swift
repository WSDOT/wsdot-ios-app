//
//  FerriesRouteAlertItem.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit
 
class FerriesRouteAlertItem: NSObject {
 
    var uuid: String = NSUUID().UUIDString
    var routeId: Int = 0
 
    init(id: Int) {
        super.init()
        self.routeId = id
    }
}
