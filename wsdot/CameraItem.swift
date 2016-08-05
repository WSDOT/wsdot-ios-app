//
//  CameraItem.swift
//  WSDOT
//
//  Created by Logan Sims on 7/27/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
import RealmSwift

class CameraItem: Object {

    dynamic var cameraId = 0
    dynamic var url = ""
    dynamic var title = ""
    dynamic var roadName = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var video = false
    dynamic var selected = false
    
    override static func primaryKey() -> String? {
        return "cameraId"
    }
}
