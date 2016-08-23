//
//  FavoriteLocationItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import RealmSwift

class FavoriteLocationItem: Object {
    dynamic var id: Int64 = 0
    dynamic var name: String = ""
    dynamic var zoom: Float = 0.0
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
}

