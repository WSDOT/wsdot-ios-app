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

class ExpressLanesViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "ExpressLanesCell"
    let webLinkcellIdentifier = "WebsiteLinkCell"
    
    @IBOutlet weak var tableView: UITableView!
    var expressLanes = [ExpressLaneItem]()

    let expressLanesUrlString = "https://wsdot.wa.gov/travel/operations-services/express-lanes/home"
    let refreshControl = UIRefreshControl()
    var overlayView = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Express Lanes"
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(ExpressLanesViewController.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        refresh(self.refreshControl)
        
        tableView.rowHeight = UITableView.automaticDimension
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "ExpressLanes")
    }

    @objc func refresh(_ refreshControl: UIRefreshControl) {
        
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.homepage, message: WSDOTErrorStrings.expressLanes)
                        }
                    }
                }
            })
        }
    }

    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
            MyAnalytics.screenView(screenName: "Express Lanes Schedule Website")
            
            MyAnalytics.event(category: "Travel Information", action: "open_link", label: "express_lanes_schedule")
            
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let svc = SFSafariViewController(url: URL(string: self.expressLanesUrlString)!, configuration: config)
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            self.present(svc, animated: true, completion: nil)
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
