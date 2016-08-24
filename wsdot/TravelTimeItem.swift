//
//  TravelTimeItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import RealmSwift

class TravelTimeItem: Object {
    dynamic var routeid: Int = 0
    dynamic var title: String = ""
    dynamic var distance: Float = 0.0
    dynamic var averageTime: Int = 0
    dynamic var currentTime: Int = 0
    dynamic var updated: String = ""
    dynamic var selected: Bool = false
    dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "routeid"
    }
    
}

