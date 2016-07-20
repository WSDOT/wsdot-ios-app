//
//  RouteSchedulesViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteSchedulesViewController: UITableViewController {
    
    let cellIdentifier = "FerriesRouteSchedulesCell"
    let SegueRouteDeparturesViewController = "RouteSailingsViewController"
    
    var routes = [FerriesRouteScheduleItem]()
    
    // MARK: -
    // MARK: Initialization
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Route Schedules"
        
        self.refreshControl?.beginRefreshing()
        
        // Dispatch work with QOS user initated for top priority. 
        // weak binding in case user navigates away and self becomes nil.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            RouteSchedulesStore.getRouteSchedules(false, completion: { data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.routes = validData
                            selfValue.tableView.reloadData()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
                if let selfValue = self {
                    selfValue.refreshControl?.endRefreshing()
                }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        RouteSchedulesStore.getRouteSchedules (true, completion: { data, error in
            if let validData = data {
                self.routes = validData
                // Reload tableview on UI thread
                dispatch_async(dispatch_get_main_queue(),
                    { () -> Void in
                        self.tableView.reloadData()}
                )
                sender.endRefreshing()
            } else {
                // TODO: Display error
            }
        })
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! RoutesCustomCell
        
        cell.title.text = routes[indexPath.row].routeDescription
        
        if self.routes[indexPath.row].crossingTime != nil {
            cell.subTitleOne.hidden = false
            cell.subTitleOne.text = "Crossing time: ~ " + self.routes[indexPath.row].crossingTime! + " min"
        } else {
            cell.subTitleOne.hidden = true
        }

        cell.subTitleTwo.text = TimeUtils.timeSinceDate(self.routes[indexPath.row].cacheDate, numericDates: true)
     
        return cell
    }

    // MARK: -
    // MARK: Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Perform Segue
        performSegueWithIdentifier(SegueRouteDeparturesViewController, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let routeItem = self.routes[indexPath.row] as FerriesRouteScheduleItem
                //let destinationViewController = segue.destinationViewController as! RouteSailingsViewController
                
                let ctrl: UITabBarController = segue.destinationViewController as! UITabBarController
                let sailingsViewController = ctrl.childViewControllers[0] as! RouteSailingsViewController
                
                if (routeItem.routeAlerts.count > 0){
                    ctrl.tabBar.items?[1].badgeValue = String(routeItem.routeAlerts.count)
                }
                sailingsViewController.routeItem = routeItem
                
            }
        }
    }
}
