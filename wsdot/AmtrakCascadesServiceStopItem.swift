//
//  AmtrakCascadesServiceItem.swift
//  WSDOT
//
//  Created by Logan Sims on 9/1/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

class AmtrakCascadesServiceStopItem{
    
    var stationId: String = ""
    var stationName: String = ""
    
    var trainNumber: Int = -1
    
    var tripNumer: Int = -1
    var sortOrder: Int = -1
    
    var arrivalComment: String? = nil
    var departureComment: String? = nil
    
    var scheduledArrivalTime: NSDate? = nil
    var scheduledDepartureTime: NSDate? = nil
    
    var updated = NSDate(timeIntervalSince1970: 0)

}