//
//  HandleLocationConfirmed.swift
//  WSDOT
//
//  Created by Logan Sims on 1/28/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import MapKit

protocol HandleLocationPicked {
    func locationSelected(placemark: MKPlacemark)
}
