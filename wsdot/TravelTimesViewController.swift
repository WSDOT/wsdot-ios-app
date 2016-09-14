//
//  TravelTimesViewController.swift
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

class TravelTimesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating{
    
    let cellIdentifier = "TravelTimeCell"
    
    let segueTravelTimesViewController = "TravelTimesViewController"
    
    var travelTimes = [TravelTimeItem]()
    var filtered = [TravelTimeItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Travel Times"
        
        // init search Controlller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.view.tintColor = Colors.tintColor
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TravelTimesViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        refresh(false)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map/Traveler Information/Travel Times")
    }
    
    func refreshAction(refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(force: Bool){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.travelTimes = TravelTimesStore.getAllTravelTimes()
                            selfValue.filtered = selfValue.travelTimes
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(view: UIView) {
        
        overlayView.frame = CGRectMake(0, 0, 80, 80)
        overlayView.center = CGPointMake(view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.7
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
        
        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! TravelTimeCell

        let travelTime = filtered[indexPath.row]
        
        cell.routeLabel.text = travelTime.title
        
        cell.subtitleLabel.text = String(travelTime.distance) + " miles / " + String(travelTime.averageTime) + " min"
        
        do {
            let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(travelTime.updated), numericDates: false)
            cell.updatedLabel.text = updated
        } catch TimeUtils.TimeUtilsError.InvalidTimeString {
            cell.updatedLabel.text = "N/A"
        } catch {
            cell.updatedLabel.text = "N/A"
        }
        
        cell.currentTimeLabel.text = String(travelTime.currentTime) + " min"
        
        if (travelTime.averageTime > travelTime.currentTime){
            cell.currentTimeLabel.textColor = Colors.tintColor
        } else if (travelTime.averageTime < travelTime.currentTime){
            cell.currentTimeLabel.textColor = UIColor.redColor()
        } else {
            cell.currentTimeLabel.textColor = UIColor.darkTextColor()
        }

        cell.sizeToFit()
        
        return cell
    }
    

    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(segueTravelTimesViewController, sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: UISearchBar Delegate Methods
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filtered = searchText.isEmpty ? travelTimes : travelTimes.filter({(travelTime: TravelTimeItem) -> Bool in
                return travelTime.title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            tableView.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueTravelTimesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let travelTimeItem = self.filtered[indexPath.row] as TravelTimeItem
                let destinationViewController = segue.destinationViewController as! TravelTimeDetailsViewController
                destinationViewController.travelTime = travelTimeItem
            }
        }
    }
}


    
