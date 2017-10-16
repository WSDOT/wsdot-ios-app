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
import SafariServices

class ExpressLanesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "ExpressLanesCell"
    let webLinkcellIdentifier = "WebsiteLinkCell"
    
    @IBOutlet weak var tableView: UITableView!
    var expressLanes = [ExpressLaneItem]()

    let expressLanesUrlString = "http://www.wsdot.wa.gov/Northwest/King/ExpressLanes"
    let refreshControl = UIRefreshControl()
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Express Lanes"
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(ExpressLanesViewController.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        refresh(self.refreshControl)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information/Express Lanes")
    }

    func refresh(_ refreshControl: UIRefreshControl) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            ExpressLanesStore.getExpressLanes({ data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.expressLanes = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
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
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressLanes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == expressLanes.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: webLinkcellIdentifier, for: indexPath)
            cell.textLabel?.text = "Express Lanes Schedule Website"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .blue
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ExpressLaneCell
            cell.routeLabel.text = expressLanes[indexPath.row].route
            cell.directionLabel.text = expressLanes[indexPath.row].direction
            
            do {
                let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(expressLanes[indexPath.row].updated), numericDates: false)
                cell.updatedLabel.text = updated
            } catch TimeUtils.TimeUtilsError.invalidTimeString {
                cell.updatedLabel.text = "N/A"
            } catch {
                cell.updatedLabel.text = "N/A"
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case expressLanes.count:
            GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information/Express Lanes/Express Lanes Schedule Website")
            let svc = SFSafariViewController(url: URL(string: self.expressLanesUrlString)!, entersReaderIfAvailable: true)
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = UIColor.white
                svc.preferredBarTintColor = Colors.wsdotPrimary
            } else {
                svc.view.tintColor = Colors.tintColor
            }
            self.present(svc, animated: true, completion: nil)
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
