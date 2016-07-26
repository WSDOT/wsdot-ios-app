//
//  SailingsItem.swift
//  WSDOT
//
//  Created by Logan Sims on 7/19/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import SwiftyJSON

class SailingsItem: NSObject {
    
    var uuid: String = NSUUID().UUIDString
    var departingTerminalId: Int = -1
    var departingTerminalName: String = ""
    var arrivingTerminalId: Int = -1
    var arrivingTerminalName: String = ""
    var annotations = [String]()
    var times = [SailingTimeItem]()
    
    init(departingTerminalId: Int, departingTerminalName: String, arrivingTerminalId: Int, arrivingTerminalName: String, annotationsJSON: JSON, timesJSON: JSON) {
        super.init()
        self.departingTerminalId = departingTerminalId
        self.departingTerminalName = departingTerminalName
        self.arrivingTerminalId = arrivingTerminalId
        self.arrivingTerminalName = arrivingTerminalName
        self.annotations = getAnnotationsFromJSON(annotationsJSON)
        self.times = getTimesFromJSON(timesJSON)
    
    }

    private func getTimesFromJSON(timesJSON: JSON) -> [SailingTimeItem]{
    
        var times = [SailingTimeItem]()

        for (_,timeJSON):(String, JSON) in timesJSON {
            let time = SailingTimeItem(departingTime: timeJSON["DepartingTime"].string!, arrivingTime: timeJSON["ArrivingTime"].string, annotationIndexesJSON: timeJSON["AnnotationIndexes"])
            times.append(time)
        }
    
        return times
    }
    
    private func getAnnotationsFromJSON(annotationsJSON: JSON) -> [String]{
        var annotations = [String]()

        for (_,annotationJSON):(String, JSON) in annotationsJSON {
            annotations.append(annotationJSON.stringValue)
        }
        
        return annotations
    }
}
