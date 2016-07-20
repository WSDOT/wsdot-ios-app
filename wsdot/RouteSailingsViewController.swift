//
//  RouteDepartureViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteSailingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteSailings"
    
    var routeItem : FerriesRouteScheduleItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sailings"
        self.tabBarController!.navigationItem.title = "Sailings";
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (routeItem?.sailings.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = routeItem?.sailings[indexPath.row]
        
        return cell
    }
    
    
    
    
    
}
