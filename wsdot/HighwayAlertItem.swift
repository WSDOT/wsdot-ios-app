//
//  HighwayAlertItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import RealmSwift

class HighwayAlertItem: Object {

    dynamic var alertId: Int = 0
    dynamic var priority: String = ""
    dynamic var region: String = ""
    dynamic var eventCategory: String = ""
    dynamic var headlineDesc: String = ""
    dynamic var eventStatus: String = ""
    dynamic var startDirection: String = ""
    dynamic var lastUpdatedTime = NSDate()

    dynamic var startTime = NSDate()
    
    dynamic var startLatitude: Double = 0.0
    dynamic var startLongitude: Double = 0.0
    dynamic var endLatitude: Double = 0.0
    dynamic var endLongitude: Double = 0.0
    
    dynamic var county: String? = nil
    dynamic var endTime: NSDate? = nil
    dynamic var extendedDesc: String? = nil

    override static func primaryKey() -> String? {
        return "alertId"
    }
}
