//
//  FerriesRealmModels.swift
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

class FerryScheduleItem: Object {
    dynamic var routeId = 0
    dynamic var routeDescription = ""
    dynamic var selected = false
    dynamic var crossingTime: String? = nil
    dynamic var cacheDate = NSDate(timeIntervalSince1970: 0)
    let routeAlerts = List<FerryAlertItem>()
    let scheduleDates = List<FerryScheduleDateItem>()
    let terminalPairs = List<FerryTerminalPairItem>()
    
    dynamic var delete = false
    
    override static func primaryKey() -> String? {
        return "routeId"
    }
}

class FerryAlertItem: Object {
    dynamic var bulletinId = 0
    dynamic var publishDate = ""
    dynamic var alertDescription = ""
    dynamic var alertFullTitle = ""
    dynamic var alertFullText = ""
}

class FerryTerminalPairItem: Object {
    dynamic var aTerminalId = 0
    dynamic var aTerminalName = ""
    dynamic var bTerminalId = 0
    dynamic var bTterminalName = ""
}

class FerryScheduleDateItem: Object {
    dynamic var date = NSDate(timeIntervalSince1970: 0)
    let sailings = List<FerrySailingsItem>()
}

class FerrySailingsItem: Object {
    dynamic var departingTerminalId = -1
    dynamic var departingTerminalName = ""
    dynamic var arrivingTerminalId = -1
    dynamic var arrivingTerminalName = ""
    let annotations = List<Annotation>()
    let times = List<FerryDepartureTimeItem>()
}

class FerryDepartureTimeItem: Object {
    dynamic var departingTime = NSDate(timeIntervalSince1970: 0)
    dynamic var  arrivingTime: NSDate? = nil
    let annotationIndexes = List<AnnotationIndex>()

}

class AnnotationIndex: Object {
    dynamic var index = -1
}

class Annotation: Object{
    dynamic var message = ""
}

