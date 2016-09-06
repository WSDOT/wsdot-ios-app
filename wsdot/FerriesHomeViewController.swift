//
//  FerriesHomeTableViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
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
