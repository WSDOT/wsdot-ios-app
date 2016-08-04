//
//  FerriesRealmModels.swift
//  WSDOT
//
//  Created by Logan Sims on 8/3/16.
//  Copyright © 2016 WSDOT. All rights reserved.
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

