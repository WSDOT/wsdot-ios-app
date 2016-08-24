//
//  CachesRealmDataModel.swift
//  WSDOT
//
//  Created by Logan Sims on 8/4/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import Foundation
import RealmSwift

class CacheItem: Object{
    dynamic var id = 0
    
    dynamic var travelTimesLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var highwayAlertsLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var ferriesLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var camerasLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var borderWaitsLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    override class func primaryKey() -> String {
        return "id"
    }
}

