//
//  FerriesDataModel.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

/*
    This file contains typealias for data held in the database.
    Used when retreving data from the database.
*/

typealias RouteScheduleDataModel = (
    routeId: Int64?,
    routeDescription: String?,
    selected: Int64?,
    crossingTime: String?,
    routeAlert: String?,
    scheduleDate: String?
)
