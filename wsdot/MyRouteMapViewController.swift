//
//  MyRouteMapViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 2/28/17.
//  Copyright © 2017 WSDOT. All rights reserved.
//

import UIKit

class MyRouteMapViewController: UIViewController {

    var myRouteLocations: [CLLocation] = [CLLocation(latitude: 47.5990, longitude: -122.3350)]

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var accessibilityMapLabel: UILabel!
    
    override func loadView() {
        super.loadView()
        
        // Prepare Google mapView
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.isTrafficEnabled = true
    
        _ = displayRouteOnMap(myRouteLocations)
    
    
        if let myLocation = mapView.myLocation{
            mapView.animate(toLocation: myLocation.coordinate)
        }
    
        
        GoogleAnalytics.screenView(screenName: "/Favorites/My Route/Route Map")
    }

    /**
     * Method name: displayRouteOnMap()
     * Description: sets mapView camera to show all of the newly recording route if there is data.
     * Parameters: locations: Array of CLLocations that make up the route.
     */
    func displayRouteOnMap(_ locations: [CLLocation]) -> Bool {
        
        if let region = MyRouteStore.getRouteMapRegion(locations: locations) {
            
            // set Map Bounds
            let bounds = GMSCoordinateBounds(coordinate: region.nearLeft,coordinate: region.farRight)
            let camera = mapView.camera(for: bounds, insets:UIEdgeInsets.zero)
            mapView.camera = camera!
            
            let myPath = GMSMutablePath()
            
            for location in locations {
                myPath.add(location.coordinate)
            }
            
            let MyRoute = GMSPolyline(path: myPath)
            
            setRouteAccessibilityLabel(locations: locations)
            
            MyRoute.spans = [GMSStyleSpan(color: UIColor(red: 0, green: 0.6588, blue: 0.9176, alpha: 1.0))] /* #00a8ea */
            MyRoute.strokeWidth = 4
            MyRoute.map = mapView
            mapView.animate(toZoom: (camera?.zoom)! - 0.5)
        
            return true
        } else {
            return false
        }
    }

}

extension MyRouteMapViewController: GMSMapViewDelegate {}

extension MyRouteMapViewController {

    func setRouteAccessibilityLabel(locations: [CLLocation]) {
        
        self.accessibilityMapLabel.isHidden = false
        self.accessibilityMapLabel.accessibilityLabel = "Checking route start and end points..."
        
        if let firstLocation = locations.first {
            
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(firstLocation.coordinate) { response, error in
                if let address = response?.firstResult() {
 
                    let lines = address.lines!
                    let startAddress = lines.joined(separator: "\n")
                    
                    if let endLocation = locations.last {
                    
                        geocoder.reverseGeocodeCoordinate(endLocation.coordinate) { response, error in
                            if let address = response?.firstResult() {
 
                                let lines = address.lines!
                                let endAddress = lines.joined(separator: "\n")
 
                                self.accessibilityMapLabel.accessibilityLabel = "Route starts near " + startAddress + " and ends near " + endAddress

                            }
                        }
                    }else {
                        self.accessibilityMapLabel.accessibilityLabel = "Route starts near " + startAddress + " and ends at an unknown location"
                    }
                } else {
                    self.accessibilityMapLabel.accessibilityLabel = "Uable to determine recorded route start and end points because of network issues. Double tap to try again."
                    print(error ?? "no error found")

                    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapResponse(_:)))
                    tapGesture.numberOfTapsRequired = 1
                    self.accessibilityMapLabel.isUserInteractionEnabled =  true
                    self.accessibilityMapLabel.addGestureRecognizer(tapGesture)

                }
            }
        }
    }
    
    @objc func tapResponse(_ recognizer: UITapGestureRecognizer) {
        setRouteAccessibilityLabel(locations: myRouteLocations)
    }
    
    func screenChange() {
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 1, target: self,
                                   selector: #selector(self.timerDidFire(timer:)), userInfo: nil, repeats: false)
        }
    }

    @objc private func timerDidFire(timer: Timer) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.titleView)
    }

}
