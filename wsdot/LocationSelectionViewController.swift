//
//  MyRouteSetupViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 1/24/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import Foundation
import MapKit

/**
 * Handles selecting start and end locations for MyRoutes
 */
class LocationSelectionViewController: UIViewController  {

    // Center at the center of Washington
    // WA is 360 miles wide, thats 579364 meters.
    // Set the longitudinal meters (east-to-west) distance to 600,000
    // WA is 240 miles long, thats 386243 meters.
    // Set the latitudinal meters (north-to-south) distance to 400,000
    let washingtionRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: 47.3268164, longitude: -120.711365), latitudinalMeters: 300000, longitudinalMeters: 600000)

    var resultSearchController: UISearchController!

    var handleLocationPickedDelegate: HandleLocationPicked!

    let locationManager = CLLocationManager()
    var usersLocation: CLLocation!
    
    var selectedPin:MKPlacemark!
    
    @IBOutlet weak var containerSearchTable: MKMapView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationSearchViewController" {
            if let vc = segue.destination as? LocationSearchViewController {
            
                vc.handleMapSearchDelegate = self
                
                resultSearchController = UISearchController(searchResultsController: vc)
                resultSearchController?.searchResultsUpdater = vc
        
                // set up search bar
                let searchBar = resultSearchController!.searchBar
                searchBar.sizeToFit()
                searchBar.placeholder = "Search for a place"
                navigationItem.titleView = resultSearchController?.searchBar
        
                resultSearchController?.hidesNavigationBarDuringPresentation = false
                resultSearchController?.dimsBackgroundDuringPresentation = true
                definesPresentationContext = true
            
            }
        }
    }
}


extension LocationSelectionViewController: HandleMapSearch {

    func locationSelected(placemark: MKPlacemark) {
        
        let alertController = (UIDevice.current.userInterfaceIdiom == .phone ?
              UIAlertController(title: placemark.title, message: nil, preferredStyle: .actionSheet)
            : UIAlertController(title: "Use this location?", message: nil, preferredStyle: .alert) )
        
        let mapView = MKMapView()
        alertController.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 45).isActive = true
        mapView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -10).isActive = true
        mapView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 10).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 250).isActive = true

        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: false)

        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 430).isActive = true

        alertController.view.tintColor = Colors.tintColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (result : UIAlertAction) -> Void in
            self.handleLocationPickedDelegate.locationSelected(placemark: placemark)
            self.navigationController!.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
    
        self.present(alertController, animated: true, completion: nil)
    }

    
}
