//
//  TravelTimeItemGroup.swift
//  WSDOT
//
//  Created by Logan Sims on 2/14/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import RealmSwift

class TravelTimeItemGroup: Object {

    dynamic var title: String = ""
    
    let routes = List<TravelTimeItem>()

    dynamic var selected: Bool = false
    dynamic var delete: Bool = false
    
    override static func primaryKey() -> String? {
        return "title"
    }
}

