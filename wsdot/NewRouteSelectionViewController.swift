//
//  NewRouteSelectionViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 1/30/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import Foundation
import MapKit

class NewRouteSelectionViewController: UIViewController  {

    let washingtionRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: 47.3268164, longitude: -120.611365), latitudinalMeters: 400000, longitudinalMeters: 600000)

    var directions: MKDirections!
    
    var pointA: MKPlacemark!
    var pointB: MKPlacemark!
    
    var routes = [MKRoute]()

    var selectedRouteIndex = 0

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Routes"
        
        styleButtons()
        mapView.setRegion(washingtionRegion, animated: false)
      
        getRoute(source: CLLocationCoordinate2D(latitude: pointA.coordinate.latitude, longitude: pointA.coordinate.longitude), destination: CLLocationCoordinate2D(latitude: pointB.coordinate.latitude, longitude: pointB.coordinate.longitude))
        
    }
    
    // Cancel any pending request when user leaves screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let directionsValue = directions {
            directionsValue.cancel()
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
    
        let route = routes[selectedRouteIndex]

        let name = "\(pointA.name!) to \(pointB.name!) via \(route.name)"

        let _ =  MyRouteStore.save(route: route.polyline.coordinates, name: name,
            displayLat: 0,
            displayLong: 0,
            displayZoom: 11)
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    
    }
    
    func getRoute(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        submitButton.isEnabled = false
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        directions = MKDirections(request: request)
        
        // Make a MKDirections request and plot the first returned route
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            self.routes = unwrappedResponse.routes
            self.tableView.reloadData()
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            self.tableView(self.tableView, didSelectRowAt: indexPath)

            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.submitButton.isEnabled = true

        }
    }
    
    func getAlertsOnPolyline(polyline: MKPolyline) {
    
        let alerts = HighwayAlertsStore.getAllAlerts()
        
        for alert in alerts {
        
            if polylineIsNearby(locations:
                    [CLLocation(latitude: alert.startLatitude, longitude: alert.startLongitude),
                    CLLocation(latitude: alert.endLatitude, longitude: alert.endLongitude)], polyline: polyline) {
        
                print(alert.headlineDesc)
            }
        }
    }
    
    func polylineIsNearby(locations: [CLLocation], polyline:MKPolyline) -> Bool {
    
        for coord in polyline.coordinates {
            for location in locations {
                let coordLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                // distance in meters
                if location.distance(from: coordLocation) < 400 {
                    return true
                }
            }
        }
        return false
    }

    /**
     * Method name: styleButtons()
     * Description: programmatically styles button background, colors, etc...
     */
    func styleButtons() {
        submitButton.layer.cornerRadius = 5
        submitButton.clipsToBounds = true
    }

}

extension NewRouteSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell")!
        cell.textLabel?.text = "Via \(routes[indexPath.row].name)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRouteIndex = indexPath.row
    
        mapView.removeOverlays(mapView.overlays)
        
        mapView.setVisibleMapRect(self.routes[selectedRouteIndex].polyline.boundingMapRect, edgePadding:  UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0), animated: true)
        
        mapView.addOverlay(self.routes[selectedRouteIndex].polyline)
        
        //getAlertsOnPolyline(polyline: self.routes[selectedRouteIndex].polyline)
        
    }
    
}

// MARK: Map Delegate methods
extension NewRouteSelectionViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = Colors.wsdotPrimary
        return renderer
    }
}
