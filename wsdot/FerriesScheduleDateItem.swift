//
//  FerriesScheduleDateItem.swift
//  WSDOT
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
import SwiftyJSON

class FerriesScheduleDateItem: NSObject {
    
    let uuid: String = NSUUID().UUIDString
    var date: String = "0"
    var sailings = [SailingsItem]()
    
    init(date: String, sailingsJSON: JSON) {
        super.init()
        self.date = date
        self.sailings = getSailingsFromJSON(sailingsJSON)
    }
    
    private func getSailingsFromJSON(sailingsJSON: JSON) -> [SailingsItem]{
        
        var sailings = [SailingsItem]()
        
        for (_,sailingJSON):(String, JSON) in sailingsJSON {
            let sailing = SailingsItem(departingTerminalId: sailingJSON["DepartingTerminalID"].intValue, departingTerminalName: sailingJSON["DepartingTerminalName"].stringValue, arrivingTerminalId: sailingJSON["ArrivingTerminalID"].intValue, arrivingTerminalName: sailingJSON["ArrivingTerminalName"].stringValue, annotationsJSON: sailingJSON["Annotations"], timesJSON: sailingJSON["Times"])

            sailings.append(sailing)
        }
        

        
        return  sailings
    }
    
}
