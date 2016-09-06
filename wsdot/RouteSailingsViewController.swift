//
//  RouteDepartureViewController.swift
//  WSDOT
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

class RouteSailingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteSailings"
    let SegueRouteDeparturesViewController = "RouteDeparturesViewController"
    
    @IBOutlet var tableView: UITableView!
    var routeItem : FerryScheduleItem = FerryScheduleItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // get routeItem
        let routeTabBarContoller = self.tabBarController as! RouteTabBarViewController
        routeItem = routeTabBarContoller.routeItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Ferries/Schedules/Sailings")
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeItem.terminalPairs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let sailing = routeItem.terminalPairs[indexPath.row]
        
        cell.textLabel?.text = sailing.aTerminalName + " to " + sailing.bTterminalName
        
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
                
                destinationViewController.sailingsByDate = routeItem.scheduleDates
                destinationViewController.currentSailing = routeItem.terminalPairs[indexPath.row]

                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                self.tabBarController!.navigationItem.backBarButtonItem = backItem
            }
        }
    }

}
