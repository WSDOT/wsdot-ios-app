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
    
    var menu_options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "Ferries"
        menu_options = ["Route Schedules", "Vehicle Reservations", "VesselWatch"]
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -
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

    // MARK: -
    // MARK: Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
            case 0:
                performSegueWithIdentifier(SegueRouteSchedulesViewController, sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            default:
                break
        }
    }
}
