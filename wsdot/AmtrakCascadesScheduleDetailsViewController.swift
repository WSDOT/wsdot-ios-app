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
    
    var date = Date()
    var originId = ""
    var destId = ""
    
    var tripItems = [[(AmtrakCascadesServiceStopItem, AmtrakCascadesServiceStopItem?)]]()
    
    let refreshControl = UIRefreshControl()
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(AmtrakCascadesScheduleDetailsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
     
        tableView.rowHeight = UITableViewAutomaticDimension
        
        showOverlay(self.view)
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Amtrak Cascades/Schedules/Details")
    }
    
    func refreshAction(_ sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        let date = self.date
        let origin = self.originId
        let dest = self.destId
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            AmtrakCascadesStore.getSchedule(date, originId: origin, destId: dest, completion: { data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.tripItems = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                            
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    
    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        return "Trip " + String(section+1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tripItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AmtrakCascadesDetailsCell
        
        let originService = tripItems[indexPath.section][indexPath.row].0

        cell.departingStationNameLabel.text = originService.stationName
        
        cell.departingTimeLabel.text = TimeUtils.getTimeOfDay(originService.scheduledDepartureTime!)
        
        cell.departureNotesLabel.text = originService.departureComment
        
        if let train = AmtrakCascadesStore.trainNumberMap[originService.trainNumber]{
            cell.trainDetailsLabel.text = String(originService.trainNumber) + " " + train
        } else {
            cell.trainDetailsLabel.text = String(originService.trainNumber) + " Bus Service"
        }
        
        cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(date: originService.updated, numericDates: false)
        
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
