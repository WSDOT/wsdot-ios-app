//
//  RouteDepartureViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteDepartureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteDepartures"
    
    var routeItem : FerriesRouteScheduleItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = routeItem?.routeDescription
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        

        
        return cell
    }
    
    
    
    
    
}
