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
    let SegueRouteDeparturesViewController = "RouteDeparturesViewController"
    
    @IBOutlet var tableView: UITableView!
    var routeItem : FerriesRouteScheduleItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // get routeItem
        let routeTabBarContoller = self.tabBarController as! RouteTabBarViewController
        routeItem = routeTabBarContoller.routeItem
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (routeItem?.sailings.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let sailing = routeItem?.sailings[indexPath.row]
        
        cell.textLabel?.text = (sailing?.0)! + " to " + (sailing?.1)!
        
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        performSegueWithIdentifier(SegueRouteDeparturesViewController, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destinationViewController as! RouteDeparturesViewController
                
                destinationViewController.routeItem = routeItem
                
                destinationViewController.currentSailing = (routeItem?.sailings[indexPath.row])!
                
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                self.tabBarController!.navigationItem.backBarButtonItem = backItem
            }
        }
    }

}
