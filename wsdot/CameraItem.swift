//
//  CameraItem.swift
//  WSDOT
//
//  Created by Logan Sims on 7/27/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation

class CameraItem {

    let cameraId: Int64
    let url: String
    let title: String
    let roadName: String
    let latitude: Double
    let longitude: Double
    let video: Bool
    var selected: Bool

    init(id: Int64, url: String, title: String, road: String, lat: Double, long: Double, video: Bool, isFavorite: Bool) {
        self.cameraId = id
        self.url = url
        self.title = title
        self.roadName = road
        self.latitude = lat
        self.longitude = long
        self.video = video
        self.selected = isFavorite
    }
}
