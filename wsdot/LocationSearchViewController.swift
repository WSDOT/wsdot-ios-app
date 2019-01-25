//
//  LocationSearchTableViewController.swift
//  WSDOT
//

import UIKit
import MapKit

class LocationSearchViewController : UIViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView!
    var handleMapSearchDelegate: HandleMapSearch!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Center at the center of Washington
    // WA is 360 miles wide, thats 579364 meters.
    // Set the longitudinal meters (east-to-west) distance to 600,000
    // WA is 240 miles long, thats 386243 meters.
    // Set the latitudinal meters (north-to-south) distance to 400,000
    let washingtionRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: 47.3268164, longitude: -118.611365), latitudinalMeters: 400000, longitudinalMeters: 600000)
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}

extension LocationSearchViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchBarText = searchController.searchBar.text else { return }

        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchBarText
        request.region = washingtionRegion
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        
        handleMapSearchDelegate?.locationSelected(placemark: selectedItem)
        
        dismiss(animated: true, completion: nil)
    }
}
