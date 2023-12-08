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

class MapViewController: UIViewController, CLLocationManagerDelegate, GMUClusterRendererDelegate {
    
    var clusterManager: GMUClusterManager!
    
    let clusterIcons = [UIImage(named: "icCameraCluster1"),
                        UIImage(named: "icCameraCluster2"),
                        UIImage(named: "icCameraCluster3"),
                        UIImage(named: "icCameraCluster4"),
                        UIImage(named: "icCameraCluster5")]
    
    let cameraClusterOpenableIcon = UIImage(named: "icCameraClusterOpen")
    
    weak var markerDelegate: MapMarkerDelegate? = nil
    weak var mapDelegate: GMSMapViewDelegate? = nil
    
    
    var locationManager = CLLocationManager()
    
    deinit {
        if let mapView = view as? GMSMapView{
            mapView.clear()
            mapView.delegate = nil
        }
        
        view.removeFromSuperview()
        clusterManager.clearItems()
        clusterManager.setDelegate(nil, mapDelegate: nil)
        clusterManager = nil
        locationManager.delegate = nil
        markerDelegate = nil
        mapDelegate = nil
    }
    
    func addClusterableMarker(_ item: CameraClusterItem){
        clusterManager.add(item)
    }
    
    func removeClusterItems(){
        clusterManager.clearItems()
    }
    
    func clusterReady(){
        clusterManager.cluster()
    }
    
    override func loadView() {
        super.loadView()
        
        locationManager.delegate = self
        
        var lat = UserDefaults.standard.double(forKey: UserDefaultsKeys.mapLat)
        var lon = UserDefaults.standard.double(forKey: UserDefaultsKeys.mapLon)
        var zoom = UserDefaults.standard.float(forKey: UserDefaultsKeys.mapZoom)
        
        if lat == 0 {lat = 47.5990}
        if lon == 0 {lon = -122.3350}
        if zoom == 0 {zoom = 12}
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: zoom))
  
        // Set Dark mode if needed
        MapThemeUtils.setMapStyle(mapView, traitCollection)

        // Set default value for traffic layer if there is none
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.trafficLayer) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.trafficLayer)
        }
        
        // Check for traffic layer setting
        let trafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.trafficLayer)
        if let trafficLayerVisible = trafficLayerPref {
            if (trafficLayerVisible == "on") {
                mapView.isTrafficEnabled = true
            } else {
                mapView.isTrafficEnabled = false
            }
        }
        
        mapView.settings.compassButton = true
        mapView.delegate = mapDelegate
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = WSDOTClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        view = mapView
        if let parent = markerDelegate {
            parent.mapReady()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    
    func goToUsersLocation() {
        if let mapView = view as? GMSMapView{
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
                if let location = locationManager.location?.coordinate {
                    mapView.animate(toLocation: location)
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                self.present(AlertMessages.getAlert("Location Services Are Disabled", message: "You can enable location services from Settings.", confirm: "OK"), animated: true, completion: nil)
            } else if CLLocationManager.authorizationStatus() == .denied {
                self.present(AlertMessages.getAlert("\"WSDOT\" Doesn't Have Permission To Use Your Location", message: "You can enable location services for this app in Settings", confirm: "OK"), animated: true, completion: nil)
            } else {
                self.locationManager.requestWhenInUseAuthorization()
            }
        } 
    }
    
    func goToLocation(location: CLLocationCoordinate2D, zoom: Float) {
        if let mapView = view as? GMSMapView {
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            mapView.animate(toZoom: zoom)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let mapView = view as? GMSMapView{
            MapThemeUtils.setMapStyle(mapView, traitCollection)
        }
    }

    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let mapView = view as? GMSMapView{
            if status == .authorizedWhenInUse {
                manager.startUpdatingLocation()
                mapView.isMyLocationEnabled = true
            }else{
                mapView.isMyLocationEnabled = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let hasSeenWarning = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenWarning)
        
        if (!hasSeenWarning){
            if let location = manager.location {
                if location.speed > 11 {
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenWarning)
                    
                    parent!.present(AlertMessages.getAlert("You're moving fast.", message: "Please do not use the app while driving.", confirm: "I'm a Passenger"), animated: true, completion: { })
                }
            }
        }
    }
    
    // GMUClusterRendererDelegate
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let cluster = marker.userData as? GMUCluster {
            if let mapView = view as? GMSMapView{
                if mapView.camera.zoom > Utils.maxClusterOpenZoom {
                    marker.icon = UIImage(named: "icCameraClusterOpen")
                } else {
                    marker.icon = getClusterImage(cluster.count)
                }
            }
            
        } else if marker.userData is CameraClusterItem {
            marker.icon = UIImage(named: "icMapCamera")
        }
    }
    
    func getClusterImage(_ clusterCount: UInt) -> UIImage {
        if clusterCount > 1000 {
            return Utils.textToImage("1000+", inImage: clusterIcons[4]!, fontSize: 13.0)
        } else if clusterCount > 200 {
            return Utils.textToImage("200+", inImage: clusterIcons[3]!, fontSize: 13.0)
        } else if clusterCount > 100 {
            return Utils.textToImage("100+", inImage: clusterIcons[2]!, fontSize: 13.0)
        } else if clusterCount > 50 {
            return Utils.textToImage("50+", inImage: clusterIcons[1]!, fontSize: 13.0)
        } else if clusterCount > 10 {
            return Utils.textToImage("10+", inImage: clusterIcons[0]!, fontSize: 13.0)
        } else {
            return Utils.textToImage(String(clusterCount) as NSString, inImage: clusterIcons[0]!, fontSize: 13.0)
        }
    }
    
}
