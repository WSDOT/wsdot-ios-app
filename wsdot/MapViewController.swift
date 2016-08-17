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
    
    var markerDelegate: MapMarkerDelegate? = nil
    var mapDelegate: GMSMapViewDelegate? = nil
    
    let locationManager = CLLocationManager()
    
    override func loadView() {
        
        var lat = NSUserDefaults.standardUserDefaults().doubleForKey(UserDefaultsKeys.mapLat)
        var lon = NSUserDefaults.standardUserDefaults().doubleForKey(UserDefaultsKeys.mapLon)
        var zoom = NSUserDefaults.standardUserDefaults().floatForKey(UserDefaultsKeys.mapZoom)
        
        if lat == 0 {
            lat = 47.5990
        }
        if lon == 0 {
            lon = -122.3350
        }
        if zoom == 0 {
            zoom = 12
        }
        
        let mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: zoom))
        
        mapView.trafficEnabled = true
        
        mapView.delegate = mapDelegate
        
        view = mapView
        
        if let parent = markerDelegate {
            parent.drawOverlays()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let mapView = view as? GMSMapView{
            NSUserDefaults.standardUserDefaults().setObject(mapView.camera.target.latitude, forKey: UserDefaultsKeys.mapLat)
            NSUserDefaults.standardUserDefaults().setObject(mapView.camera.target.longitude, forKey: UserDefaultsKeys.mapLon)
            NSUserDefaults.standardUserDefaults().setObject(mapView.camera.zoom, forKey: UserDefaultsKeys.mapZoom)
        }
    }
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
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
        if status == .Denied {
            if let mapView = view as? GMSMapView{
                mapView.myLocationEnabled = false
            }
        }
    }
}
