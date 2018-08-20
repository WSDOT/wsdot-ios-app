//
//  SimpleMapViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
import UIKit
import CoreLocation
import GoogleMaps

class SimpleMapViewController: UIViewController {
    
    weak var markerDelegate: MapMarkerDelegate? = nil
    weak var mapDelegate: GMSMapViewDelegate? = nil
    
    deinit {
        if let mapView = view as? GMSMapView{
            mapView.clear()
            mapView.delegate = nil
        }
        
        view.removeFromSuperview()

        markerDelegate = nil
        mapDelegate = nil
    }
    
    override func loadView() {
        super.loadView()
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 0))
        
        mapView.isTrafficEnabled = true
        
        mapView.delegate = mapDelegate
        
        view = mapView
        
        if let parent = markerDelegate {
            parent.drawMapOverlays()
        }
    }
}
