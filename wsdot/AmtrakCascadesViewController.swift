//
//  AmtrakCascadesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class AmtrakCascadesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    let cellIdentifier = "AmtrakCell"
    let segueAmtrakSchedulesViewController = "AmtrakCascadesScheduleViewController"

    let menu_options = ["Buy Tickets on Amtrak.com", "Check Schedules and Status"]

    override func viewDidLoad() {
    super.viewDidLoad()
        title = "Amtrak Cascades"

    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            UIApplication.sharedApplication().openURL(NSURL(string: "http://m.amtrak.com")!)
            break
        case 1:
            performSegueWithIdentifier(segueAmtrakSchedulesViewController, sender: self)
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}