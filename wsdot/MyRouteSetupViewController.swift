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
class MyRouteSetupViewController: UIViewController {

    let segueNewRouteSelectionViewController = "NewRouteSelectionViewController"
    
    let segueNewRouteMenuTableViewController = "NewRouteMenuTableViewController"
    let segueLocationSearchViewController = "LocationSearchViewController"
    
    var searchController: UISearchController!
    
    var locationIndex = 0
    
    var newRouteMenuViewController: NewRouteMenuTableViewController!
    
    var pointA: MKPlacemark!
    var pointB: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "New Route"
   
    }
    
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueNewRouteSelectionViewController {
            if let vc = segue.destination as? NewRouteSelectionViewController {
                vc.pointA = pointA
                vc.pointB = pointB
            }
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
                pointA = placemark
                break
            case 1: // Point B
                newRouteMenuViewController.destinationCell.selection.text = placemark.title
                pointB = placemark
                break
            default: break
        }
        
        if (pointA != nil && pointB != nil) {
            newRouteMenuViewController.submitLabel.textColor = Colors.wsdotPrimary
            newRouteMenuViewController.submitCell.isUserInteractionEnabled = true
        }
        
    }
}

extension MyRouteSetupViewController: NewRouteMenuEventDelegate {

    func searchRoutes() {
        performSegue(withIdentifier: segueNewRouteSelectionViewController, sender: self)
    }

    func locationSearch(_ cellIndex: Int) {
        locationIndex = cellIndex
        present(searchController, animated: true, completion: nil)
    }
    
}



