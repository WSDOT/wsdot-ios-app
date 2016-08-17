//
//  MapSuperView.swift
//  WSDOT
//
//  Created by Logan Sims on 8/15/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

protocol MapMarkerDelegate {
    // Called by MapViewController when map is ready. 
    // All classes that use MapViewContoller must implement this method
    func drawOverlays()
}