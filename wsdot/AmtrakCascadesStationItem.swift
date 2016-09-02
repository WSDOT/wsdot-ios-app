//
//  AmtrakStationItem.swift
//  WSDOT
//
//  Created by Logan Sims on 9/1/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

class AmtrakCascadesStationItem {
    
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    var distance: Int = -1
    
    init(id: String, name: String, lat: Double, lon: Double){
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
    }
    
    //items.sort({$0.sortOrder > $1.sortOrder})
}
