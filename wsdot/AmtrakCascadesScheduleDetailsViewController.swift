//
//  AmtrakCascadesScheduleDetailsViewController.swift
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

class AmtrakCascadesScheduleDetailsViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    let cellIdentifier = "AmtrakCascadesCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var date = NSDate()
    var originId = ""
    var destId = ""
    
    var tripItems = [[(AmtrakCascadesServiceStopItem, AmtrakCascadesServiceStopItem?)]]()
    
    let refreshControl = UIRefreshControl()
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(AmtrakCascadesScheduleDetailsViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
     
        tableView.rowHeight = UITableViewAutomaticDimension
        
        showOverlay(self.view)
        refresh()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Amtrak Cascades/Schedules/Details")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        let date = self.date
        let origin = self.originId
        let dest = self.destId
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            AmtrakCascadesStore.getSchedule(date, originId: origin, destId: dest, completion: { data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.tripItems = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, selfValue.tableView)
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
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        
        if self.splitViewController!.collapsed {
            activityIndicator.center = CGPointMake(view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPointMake(view.center.x - self.splitViewController!.viewControllers[0].view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        return "Trip " + String(section+1)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tripItems.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripItems[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! AmtrakCascadesDetailsCell
        
        let originService = tripItems[indexPath.section][indexPath.row].0

        cell.departingStationNameLabel.text = originService.stationName
        
        cell.departingTimeLabel.text = TimeUtils.getTimeOfDay(originService.scheduledDepartureTime!)
        
        cell.departureNotesLabel.text = originService.departureComment
        
        if let train = AmtrakCascadesStore.trainNumberMap[originService.trainNumber]{
            cell.trainDetailsLabel.text = String(originService.trainNumber) + " " + train
        } else {
            cell.trainDetailsLabel.text = String(originService.trainNumber) + " Bus Service"
        }
        
        cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(originService.updated, numericDates: false)
        
        if let destinationService = tripItems[indexPath.section][indexPath.row].1 {
            
            cell.arrivingStationNameLabel.text = destinationService.stationName
            
            cell.arrivingTimeLabel.text = TimeUtils.getTimeOfDay(destinationService.scheduledArrivalTime!)

            cell.arrivalNotesLabel.text = destinationService.arrivalComment
            
        } else {
            cell.arrivingStationNameLabel.text = ""
            cell.arrivingTimeLabel.text = ""
            cell.arrivalNotesLabel.text = ""
        }
        
        // Accessibility Setup
        cell.accessibilityLabel = "Scheduled departure from " + cell.departingStationNameLabel.text! + " at " + cell.departingTimeLabel.text! + ". "
        cell.accessibilityLabel = cell.accessibilityLabel! + cell.departureNotesLabel.text! + ". "
        
        if (destId != "N/A"){
            cell.accessibilityLabel = cell.accessibilityLabel! + "Scheduled arrival at " + cell.arrivingStationNameLabel.text! + " at " + cell.arrivingTimeLabel.text! + ". "
            cell.accessibilityLabel = cell.accessibilityLabel! + cell.arrivalNotesLabel.text! + ". "
        }
        
        cell.accessibilityLabel = cell.accessibilityLabel! + "  via " + cell.trainDetailsLabel.text! + ". updated" + cell.updatedLabel.text!
        
        cell.isAccessibilityElement = true
        
        return cell
    }
}
