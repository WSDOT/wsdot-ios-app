//
//  RouteSetupViewController.swift
//  WSDOT
//
//  Copyright (c) 2019 Washington State Department of Transportation
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
        
        let mapView = MKMapView()
    
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
        
        mapView.backgroundColor = UIColor.clear

        var preferredStyle = UIAlertController.Style.alert
        
        if let splitView = self.splitViewController {
            if splitView.isCollapsed {
                preferredStyle = .actionSheet
            }
        }
        
        let alertController = UIAlertController(title: placemark.title,
                                customView: mapView,
                                fallbackMessage: "Map unavalible",
                                preferredStyle: preferredStyle)

        alertController.view.tintColor = Colors.tintColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in }
        
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
