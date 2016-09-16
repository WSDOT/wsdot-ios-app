//
//  MapViewController.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
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

class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    var markerDelegate: MapMarkerDelegate? = nil
    var mapDelegate: GMSMapViewDelegate? = nil
    
    let locationManager = CLLocationManager()
    
    override func loadView() {
        super.loadView()
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
        super.viewWillDisappear(animated)
        if let mapView = view as? GMSMapView{
            NSUserDefaults.standardUserDefaults().setObject(mapView.camera.target.latitude, forKey: UserDefaultsKeys.mapLat)
            NSUserDefaults.standardUserDefaults().setObject(mapView.camera.target.longitude, forKey: UserDefaultsKeys.mapLon)
            NSUserDefaults.standardUserDefaults().setObject(mapView.camera.zoom, forKey: UserDefaultsKeys.mapZoom)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
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
                goToUsersLocation()
            }
        }
        if status == .Denied {
            if let mapView = view as? GMSMapView{
                mapView.myLocationEnabled = false
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let hasSeenWarning = NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKeys.hasSeenWarning)
        
        if (!hasSeenWarning){
            if let location = locationManager.location {
                if location.speed > 11 {
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: UserDefaultsKeys.hasSeenWarning)
                    parentViewController!.presentViewController(AlertMessages.getAlert("You're moving too fast.", message: "Please don't use the app while driving."), animated: true, completion: { })
                }
            }
        }
    }
}
