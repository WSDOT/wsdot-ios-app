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
class MyRouteSetupViewController: UITableViewController{


    let segueLocationSelectionViewController = "LocationSelectionViewController"
    let segueMyRouteRouteSelectionViewController = "MyRouteRouteSelectionViewController"


    @IBOutlet weak var originCell: SelectionCell!
    @IBOutlet weak var destinationCell: SelectionCell!
    
    @IBOutlet weak var submitCell: UITableViewCell!
    @IBOutlet weak var submitLabel: UILabel!
    
    var selectionType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "New Route"
        submitLabel.textColor = Colors.wsdotPrimary
        
             //getRoute(source: CLLocationCoordinate2D(latitude: 48.756302, longitude: -122.46151), destination: CLLocationCoordinate2D(latitude: 47.021461, longitude: -122.899933))
        
    }

    // MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            performSegue(withIdentifier: segueMyRouteRouteSelectionViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            selectionType = indexPath.row
            performSegue(withIdentifier: segueLocationSelectionViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueLocationSelectionViewController {
        
            let destViewController = segue.destination as! LocationSelectionViewController
            destViewController.handleLocationPickedDelegate = self
        }
        
        
        if segue.identifier == segueMyRouteRouteSelectionViewController {

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

extension MyRouteSetupViewController: HandleLocationPicked {

    func locationSelected(placemark: MKPlacemark) {
        
         switch (selectionType){
            case 0: // Point A
                originCell.selection.text = placemark.title
                break
            case 1: // Point B
                destinationCell.selection.text = placemark.title
                break
            default: break
        }
    
        
        
    }

}
