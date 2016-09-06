//
//  ExpressLanesViewController.swift
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

class ExpressLanesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "ExpressLanesCell"
    let webLinkcellIdentifier = "WebsiteLinkCell"
    
    @IBOutlet weak var tableView: UITableView!
    var expressLanes = [ExpressLaneItem]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Express Lanes"
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(ExpressLanesViewController.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refresh(self.refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map/Traveler Information/Express Lanes")
    }

    func refresh(refreshControl: UIRefreshControl) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            ExpressLanesStore.getExpressLanes({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.expressLanes = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressLanes.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == expressLanes.count){
            let cell = tableView.dequeueReusableCellWithIdentifier(webLinkcellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = "Express Lanes Schedule Website"
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .Blue
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ExpressLaneCell
            cell.routeLabel.text = expressLanes[indexPath.row].route
            cell.directionLabel.text = expressLanes[indexPath.row].direction
            
            do {
                let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(expressLanes[indexPath.row].updated), numericDates: false)
                cell.updatedLabel.text = updated
            } catch TimeUtils.TimeUtilsError.InvalidTimeString {
                cell.updatedLabel.text = "N/A"
            } catch {
                cell.updatedLabel.text = "N/A"
            }
            
            cell.selectionStyle = .None
            return cell
        }
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case expressLanes.count:
            GoogleAnalytics.screenView("/Traffic Map/Traveler Information/Express Lanes/Express Lanes Schedule Website")
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.wsdot.wa.gov/Northwest/King/ExpressLanes")!)
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}