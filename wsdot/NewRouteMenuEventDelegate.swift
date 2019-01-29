//
//  HandleNewRouteMenuEventDelegate.swift
//  WSDOT
//
//  Created by Logan Sims on 1/29/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import MapKit

protocol NewRouteMenuEventDelegate {

    func locationSearch(_ cellIndex: Int)
    
    func searchRoutes()
    
}
