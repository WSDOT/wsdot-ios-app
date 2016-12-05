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
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Route Schedules"
        
        showOverlay(self.view)
        
        self.routes = FerryRealmStore.findAllSchedules()
        self.tableView.reloadData()
        
        self.refresh(false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Ferries/Schedules")
    }
    
    func refresh(_ force: Bool){

        
        //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Loading Ferry Routes")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            FerryRealmStore.updateRouteSchedules(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.routes = FerryRealmStore.findAllSchedules()
                            selfValue.tableView.reloadData()
                            selfValue.hideOverlayView()
                            selfValue.refreshControl?.endRefreshing()
                            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.refreshControl?.endRefreshing()
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
    
    @IBAction func refreshAction() {
        refresh(true)
    }
    
    // MARK: Table View Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RoutesCustomCell
        
        cell.title.text = routes[indexPath.row].routeDescription
        
        if self.routes[indexPath.row].crossingTime != nil {
            cell.subTitleOne.isHidden = false
            cell.subTitleOne.text = "Crossing time: ~ " + self.routes[indexPath.row].crossingTime! + " min"
        } else {
            cell.subTitleOne.isHidden = true
        }

        cell.subTitleTwo.text = TimeUtils.timeAgoSinceDate(date: self.routes[indexPath.row].cacheDate, numericDates: false)
     
        return cell
    }

    // MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        performSegue(withIdentifier: SegueRouteDeparturesViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let routeItem = self.routes[indexPath.row] as FerryScheduleItem
                let destinationViewController: RouteTabBarViewController = segue.destination as! RouteTabBarViewController
                destinationViewController.routeItem = routeItem
            }
        }
    }
}
