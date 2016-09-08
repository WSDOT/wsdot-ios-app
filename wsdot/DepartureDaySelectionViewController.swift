//
//  DepartureDaySelectionViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 9/8/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class DepartureDaySelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "dayCell"

    var parent: RouteTimesViewController? = nil

    var menu_options: [String] = []
    var selectedIndex = 0
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
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
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
     
        if (indexPath.row == selectedIndex){
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parent!.daySelected(indexPath.row)
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
    }
}

