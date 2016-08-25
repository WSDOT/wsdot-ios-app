//
//  ForcastItem.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import RealmSwift

class ForecastItem: Object {
    dynamic var day: String = ""
    dynamic var forecastText: String = ""
}