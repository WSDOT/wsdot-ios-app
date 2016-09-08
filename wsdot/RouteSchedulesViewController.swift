//
//  RouteSchedulesViewController.swift
//  wsdot
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

import UIKit
import RealmSwift

class RouteSchedulesViewController: UITableViewController {
    
    let cellIdentifier = "FerriesRouteSchedulesCell"
    let SegueRouteDeparturesViewController = "RouteSailingsViewController"
    
    var routes = [FerryScheduleItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Route Schedules"
        
        self.refreshControl?.beginRefreshing()
        
        self.refresh(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Ferries/Schedules")
    }
    
    func refresh(force: Bool){

        
        //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Loading Ferry Routes")
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            FerryRealmStore.updateRouteSchedules(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.routes = FerryRealmStore.findAllSchedules()
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl?.isAccessibilityElement = false
                            selfValue.refreshControl?.endRefreshing()
                            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, selfValue.tableView)
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl?.endRefreshing()
                            selfValue.refreshControl?.isAccessibilityElement = false
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func refreshAction() {
        refresh(true)
    }
    
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

        cell.subTitleTwo.text = TimeUtils.timeAgoSinceDate(self.routes[indexPath.row].cacheDate, numericDates: false)
     
        return cell
    }

    // MARK: Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        performSegueWithIdentifier(SegueRouteDeparturesViewController, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Naviagtion
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let routeItem = self.routes[indexPath.row] as FerryScheduleItem
                let destinationViewController: RouteTabBarViewController = segue.destinationViewController as! RouteTabBarViewController
                destinationViewController.routeItem = routeItem
            }
        }
    }
}
