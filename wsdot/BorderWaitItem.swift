//
//  BorderWaitItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import RealmSwift

class BorderWaitItem: Object {

    dynamic var id: Int = 0
    dynamic var route: Int = 0
    dynamic var waitTime: Int = 0
    dynamic var title: String = ""
    dynamic var name: String = ""
    dynamic var lane: String = ""
    dynamic var direction: String = ""
    dynamic var updated: String = ""

}
