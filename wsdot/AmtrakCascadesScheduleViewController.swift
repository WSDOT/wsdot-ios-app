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
    
    var originTableData = AmtrakCascadesStore.getOriginData()
    var destinationTableData = AmtrakCascadesStore.getDestinationData()
    var dayTableData = TimeUtils.nextSevenDaysStrings(NSDate())
    
    var dayIndex = 0
    var originIndex = 0
    var destinationIndex = 0
    
    var selectionType = 0 // Used to determine how to populate the AmtrakCascadesSelectionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Find Schedules" 
        
        dayCell.selection.text = dayTableData[0]
        originCell.selection.text = originTableData[0]
        destinationCell.selection.text = destinationTableData[0]

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Amtrak Cascades/Schedules")
    }


    func daySelected(index: Int){
        dayIndex = index
        dayCell.selection.text = dayTableData[dayIndex]
    }
    
    func originSelected(index: Int){
        originIndex = index
        originCell.selection.text = originTableData[originIndex]
    }
    
    func destinationSelected(index: Int){
        destinationIndex = index
        destinationCell.selection.text = destinationTableData[destinationIndex]
    }

    // MARK: Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            if AmtrakCascadesStore.stationIdsMap[originTableData[originIndex]]! == AmtrakCascadesStore.stationIdsMap[destinationTableData[destinationIndex]]! {
                destinationIndex = 0
            }
            performSegueWithIdentifier(segueAmtrakCascadesScheduleDetailsViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        default:
            selectionType = indexPath.row
            performSegueWithIdentifier(segueAmtrakCascadesSelectionViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // MARK: CLLocationManagerDelegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
        
        let index = originTableData.indexOf(closest.station.name)
        
        originCell.selection.text = originTableData[index!]
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //print("failed to get location")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // MARK: Naviagtion
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueAmtrakCascadesSelectionViewController {
            let destinationViewController = segue.destinationViewController as! AmtrakCascadesSelectionViewController
            destinationViewController.parent = self
            destinationViewController.selectionType = selectionType
            
            switch (selectionType){
            case 0: // day selection
                destinationViewController.titleText = "Departure Day"
                destinationViewController.menu_options = dayTableData
                destinationViewController.selectedIndex = dayTableData.indexOf(dayCell.selection.text!)!
                break
            case 1: // Origin selection
            
                destinationViewController.titleText = "Origin"
                destinationViewController.menu_options = originTableData
                destinationViewController.selectedIndex = originTableData.indexOf(originCell.selection.text!)!
                break
            case 2: // Destination selection
                destinationViewController.titleText = "Destination"
                destinationViewController.menu_options = destinationTableData
                destinationViewController.selectedIndex = destinationTableData.indexOf(destinationCell.selection.text!)!
                break
            default: break
            }
        }
        
        
        if segue.identifier == segueAmtrakCascadesScheduleDetailsViewController {
            let destinationViewController = segue.destinationViewController as! AmtrakCascadesScheduleDetailsViewController
            
            let interval = NSTimeInterval(60 * 60 * 24 * dayIndex)
        
            destinationViewController.date = NSDate().dateByAddingTimeInterval(interval)
            
            destinationViewController.originId = AmtrakCascadesStore.stationIdsMap[originTableData[originIndex]]!
            
            destinationViewController.destId = AmtrakCascadesStore.stationIdsMap[destinationTableData[destinationIndex]]!
        
            if destinationViewController.destId == "N/A" {
                destinationViewController.title = "Departing " + originTableData[originTableData.indexOf(originCell.selection.text!)!]
            } else {
                destinationViewController.title = originTableData[originIndex] + " to " + destinationTableData[destinationIndex]
            }
        }
    }
}