//
//  RestAreaItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
class RestAreaItem {

    let route: String
    let location: String
    let description: String
    let milepost: Int
    let direction: String
    let latitude: Double
    let longitude: Double
    let notes: String?
    let hasDump: Bool
    let isOpen: Bool
    let amenities: [String]

    init(route: String, location: String, description: String, milepost: Int, direction: String, latitude: Double, longitude: Double, notes: String?, hasDump: Bool, isOpen: Bool, amenities: [String]){
        self.route = route
        self.location = location
        self.description = description
        self.milepost = milepost
        self.direction = direction
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.hasDump = hasDump
        self.isOpen = isOpen
        self.amenities = amenities
    }
}