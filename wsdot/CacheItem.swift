//
//  CachesRealmDataModel.swift
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
import RealmSwift

class CacheItem: Object{
    dynamic var id = 0
    
    dynamic var travelTimesLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var highwayAlertsLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var ferriesLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var camerasLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var borderWaitsLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    dynamic var mountainPassesLastUpdate: NSDate = NSDate(timeIntervalSince1970: 0)
    
    override class func primaryKey() -> String {
        return "id"
    }
}
