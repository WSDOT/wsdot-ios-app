//
//  MapViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/15/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    
    let locationManager = CLLocationManager()
    
    override func loadView() {
        
        let mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: GMSCameraPosition.cameraWithLatitude(47.5990, longitude: -122.3350, zoom: 12.0))
        view = mapView
        
    }
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func goToUsersLocation(){
        if let mapView = view as? GMSMapView{
            if let location = locationManager.location?.coordinate {
                mapView.animateToLocation(location)
            }
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            if let mapView = view as? GMSMapView{
                mapView.myLocationEnabled = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if let mapView = view as? GMSMapView{
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
                locationManager.stopUpdatingLocation()
            }
        }
        
    }
}
