//
//  FerriesHomeTableViewController.swift
//  wsdot
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

class FerriesHomeViewController: UITableViewController {

    let cellIdentifier = "FerriesHomeCell"
    let SegueRouteSchedulesViewController = "RouteSchedulesViewController"
    let SegueVesselWatchViewController = "VesselWatchViewController"
    
    var menu_options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "Ferries"
        menu_options = ["Route Schedules", "Vehicle Reservations Website", "VesselWatch"]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Ferries")
    }

    // MARK: Table View Data Source Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }
    
    // MARK: Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegueWithIdentifier(SegueRouteSchedulesViewController, sender: self)
            break
        case 1:
            GoogleAnalytics.screenView("/Ferries/Vehicle Reservations")
            UIApplication.sharedApplication().openURL(NSURL(string: "https://secureapps.wsdot.wa.gov/Ferries/Reservations/Vehicle/default.aspx")!)
            break
        case 2:
            performSegueWithIdentifier(SegueVesselWatchViewController, sender: self)
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
