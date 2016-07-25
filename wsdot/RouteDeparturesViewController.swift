//
//  RouteDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit

class RouteDeparturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteDepartures"

    var routeItem : FerriesRouteScheduleItem? = nil
    var departingTerminal : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = departingTerminal
        
        let backItem = UIBarButtonItem()
        navigationItem.backBarButtonItem = backItem
        
        print("departing from")
        print(departingTerminal)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // TODO
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        return cell
    }
}
