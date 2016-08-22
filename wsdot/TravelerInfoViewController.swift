//
//  TravelerInfoViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class TravelerInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let cellIdentifier = "TravelerInfoCell"
    
    let SegueTravelTimesViewController = "TravelTimesViewController"
    let SegueExpressLanesViewController = "ExpressLanesViewController"
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "Traveler Information"
        menu_options = ["Travel Times", "Express Lanes"]
        
    }
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
        
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        /*
        switch (indexPath.row) {
        case 0:
            performSegueWithIdentifier(SegueTravelTimesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 1:
            performSegueWithIdentifier(SegueExpressLanesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        default:
            break
        }
        */
    }
}
