//
//  AmtrakCascadesScheduleViewController.swift
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

class AmtrakCascadesScheduleViewController: UITableViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    let segueAmtrakCascadesScheduleDetailsViewController = "AmtrakCascadesScheduleDetailsViewController"
    let segueAmtrakCascadesSelectionViewController = "AmtrakCascadesSelectionViewController"

    let stationItems = AmtrakCascadesStore.getStations()

    var usersLocation: CLLocation? = nil

    @IBOutlet weak var dayCell: SelectionCell!
    @IBOutlet weak var originCell: SelectionCell!
    @IBOutlet weak var destinationCell: SelectionCell!
    @IBOutlet weak var submitCell: UITableViewCell!
    @IBOutlet weak var submitLabel: UILabel!
    
    var originTableData = AmtrakCascadesStore.getOriginData()
    var destinationTableData = AmtrakCascadesStore.getDestinationData()
    var dayTableData = TimeUtils.nextSevenDaysStrings(Date())
    
    var dayIndex = 0
    var originIndex = 0
    var destinationIndex = 0
    
    var selectionType = 0 // Used to determine how to populate the AmtrakCascadesSelectionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Find Schedules" 
        
        submitLabel.textColor = ThemeManager.currentTheme().darkColor
        
        dayCell.selection.text = dayTableData[0]
        originCell.selection.text = originTableData[0]
        destinationCell.selection.text = destinationTableData[0]

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "AmtrakSchedules")
    }


    // The following 3 methods are called by the AmtrakCascadesSelectionViewContorller to set the selected option.
    func daySelected(_ index: Int){
        dayIndex = index
        dayCell.selection.text = dayTableData[dayIndex]
    }
    
    func originSelected(_ index: Int){
        originIndex = index
        originCell.selection.text = originTableData[originIndex]
    }
    
    func destinationSelected(_ index: Int){
        destinationIndex = index
        destinationCell.selection.text = destinationTableData[destinationIndex]
    }

    // MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if AmtrakCascadesStore.stationIdsMap[originTableData[originIndex]]! == AmtrakCascadesStore.stationIdsMap[destinationTableData[destinationIndex]]! {
                let alert = UIAlertController(title: "Select a different station", message: "Select different origin and destination stations.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            performSegue(withIdentifier: segueAmtrakCascadesScheduleDetailsViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            selectionType = indexPath.row
            performSegue(withIdentifier: segueAmtrakCascadesSelectionViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // MARK: CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        usersLocation = manager.location
        
        let userLat: Double = usersLocation!.coordinate.latitude
        let userLon: Double = usersLocation!.coordinate.longitude
        
        var closest = (station: AmtrakCascadesStationItem(id: "", name: "", lat: 0.0, lon: 0.0), distance: Int.max)
        
        for station in stationItems {
            
            let distance = LatLonUtils.haversine(userLat, lonA: userLon, latB: station.lat, lonB: station.lon)
    
            if closest.1 > distance{
                closest.station = station
                closest.distance = distance
            }
        
        }
        
        let index = originTableData.firstIndex(of: closest.station.name)
        
        originCell.selection.text = originTableData[index!]
        originIndex = index!
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueAmtrakCascadesSelectionViewController {
            let destinationViewController = segue.destination as! AmtrakCascadesSelectionViewController
            destinationViewController.my_parent = self
            destinationViewController.selectionType = selectionType
            
            switch (selectionType){
            case 0: // day selection
                destinationViewController.titleText = "Departure Day"
                destinationViewController.menu_options = dayTableData
                destinationViewController.selectedIndex = dayTableData.firstIndex(of: dayCell.selection.text!)!
                break
            case 1: // Origin selection
            
                destinationViewController.titleText = "Origin"
                destinationViewController.menu_options = originTableData
                destinationViewController.selectedIndex = originTableData.firstIndex(of: originCell.selection.text!)!
                break
            case 2: // Destination selection
                destinationViewController.titleText = "Destination"
                destinationViewController.menu_options = destinationTableData
                destinationViewController.selectedIndex = destinationTableData.firstIndex(of: destinationCell.selection.text!)!
                break
            default: break
            }
        }
        
        
        if segue.identifier == segueAmtrakCascadesScheduleDetailsViewController {
            let destinationViewController = segue.destination as! AmtrakCascadesScheduleDetailsViewController
            
            let interval = TimeInterval(60 * 60 * 24 * dayIndex)
        
            destinationViewController.date = Date().addingTimeInterval(interval)
            
            destinationViewController.originId = AmtrakCascadesStore.stationIdsMap[originTableData[originIndex]]!
            
            destinationViewController.destId = AmtrakCascadesStore.stationIdsMap[destinationTableData[destinationIndex]]!
        
            if destinationViewController.destId == "N/A" {
                destinationViewController.title = "Departing " + originTableData[originTableData.firstIndex(of: originCell.selection.text!)!]
            } else {
                destinationViewController.title = originTableData[originIndex] + " to " + destinationTableData[destinationIndex]
            }
        }
    }
    
    // MARK: Presentation
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
