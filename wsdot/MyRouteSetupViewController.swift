//
//  RouteSetupViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 1/25/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import Foundation
import MapKit

/**
 * Handles creation of new MyRoutes
 */
class MyRouteSetupViewController: UIViewController{

    let segueMyRouteRouteSelectionViewController = "MyRouteRouteSelectionViewController"
    
    let segueNewRouteMenuTableViewController = "NewRouteMenuTableViewController"
    let segueLocationSearchViewController = "LocationSearchViewController"
    
    var searchController: UISearchController!
    
    var locationIndex = 0
    
    var newRouteMenuViewController: NewRouteMenuTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "New Route"
      
        
        //getRoute(source: CLLocationCoordinate2D(latitude: 48.756302, longitude: -122.46151), destination: CLLocationCoordinate2D(latitude: 47.021461, longitude: -122.899933))
        
    }
    
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == segueMyRouteRouteSelectionViewController {
            // TODO:
        }
        
        
        // container view segue for new route table
        if segue.identifier == segueNewRouteMenuTableViewController {
            if let vc = segue.destination as? NewRouteMenuTableViewController {
   
                vc.newRouteMenuEventDelegate = self
                newRouteMenuViewController = vc
            
            }
        }
        
        // container view segue for search table
        if segue.identifier == segueLocationSearchViewController {
            if let vc = segue.destination as? LocationSearchViewController {
                vc.mapSearchDelegate = self
                
                searchController = UISearchController(searchResultsController: vc)
                searchController?.searchResultsUpdater = vc
                
                let searchBar = searchController!.searchBar
                searchBar.sizeToFit()
                searchBar.placeholder = "Search for a place"
                
                searchController?.hidesNavigationBarDuringPresentation = false
                searchController?.dimsBackgroundDuringPresentation = true
                
                definesPresentationContext = true
                
            }
        }
    }
    
    // MARK: Presentation
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: Helper methods
    func getRoute(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        // Make a MKDirections request and plot the first returned route
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            //self.mapView.addOverlay(unwrappedResponse.routes[0].polyline)
            //self.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
            
            self.getAlertsOnPolyline(polyline: unwrappedResponse.routes[0].polyline)
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
    
}


// MARK: Map Delegate methods
extension MyRouteSetupViewController {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}

extension MyRouteSetupViewController: LocationSearchDelegate {

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
            self.locationConfirmed(placemark: placemark)
            self.searchController.searchBar.text = nil
            self.searchController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
    
        self.present(alertController, animated: true, completion: nil)
    }

    func locationConfirmed(placemark: MKPlacemark) {
        
         switch (locationIndex){
            case 0: // Point A
                newRouteMenuViewController.originCell.selection.text = placemark.title
                break
            case 1: // Point B
                newRouteMenuViewController.destinationCell.selection.text = placemark.title
                break
            default: break
        }
    }
}

extension MyRouteSetupViewController: NewRouteMenuEventDelegate {


    func searchRoutes() {
         performSegue(withIdentifier: segueMyRouteRouteSelectionViewController, sender: self)
    }

    func locationSearch(_ cellIndex: Int) {
        locationIndex = cellIndex
        
        present(searchController, animated: true, completion: nil)
        
    }
    

}



