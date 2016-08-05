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

typealias CameraDataModel = (
    cameraId: Int64,
    url: String,
    title: String,
    roadName: String,
    latitude: Double,
    longitude: Double,
    video: Int64,
    selected: Bool
)
