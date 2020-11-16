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
import GoogleMobileAds
import SafariServices

class RouteSchedulesViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    let cellIdentifier = "FerriesRouteSchedulesCell"
    
    let SegueRouteDeparturesViewController = "RouteDeparturesViewController"
    let SegueVesselWatchViewController = "VesselWatchViewController"
    
    var routes = [FerryScheduleItem]()
    
    var overlayView = UIView()
    
    let ticketsUrlString = "https://wave2go.wsdot.com/Webstore/Content.aspx?Kind=LandingPage&CG=21&C=10"
    
    let reservationsUrlString = "https://secureapps.wsdot.wa.gov/Ferries/Reservations/Vehicle/default.aspx"
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: DFPBannerView!
    
    @IBOutlet weak var ticketsButton: UIButton!
    @IBOutlet weak var reservationsButton: UIButton!
    @IBOutlet weak var vesselWatchButton: UIButton!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        title = "Ferries"
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteSchedulesViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = [
            "wsdotapp":"ferries",
            "wsdotferries":"ferries-home"
        ]
        
        bannerView.load(request)
        bannerView.delegate = self
        
        styleButtons()
        
        self.routes = FerryRealmStore.findAllSchedules()
        self.tableView.reloadData()
        
        self.refresh(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "FerrySchedules")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            FerryRealmStore.updateRouteSchedules(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.routes = FerryRealmStore.findAllSchedules()
                            selfValue.tableView.reloadData()
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.ferries, message: WSDOTErrorStrings.ferriesSchedule)
                        }
                    }
                }
            })
        }
    }

    @IBAction func refreshAction() {
        refresh(true)
    }
    
    
    @IBAction func vesselWatchAction(_ sender: UIButton) {
        performSegue(withIdentifier: SegueVesselWatchViewController, sender: self)
    }
    
    
    @IBAction func ticketsAction(_ sender: Any) {
        MyAnalytics.screenView(screenName: "Buy Ferries TIckets")
        
        MyAnalytics.event(category: "Ferries", action: "open_link", label: "buy_tickets_ferries")
        
        let config = SFSafariViewController.Configuration()
        let svc = SFSafariViewController(url: URL(string: self.ticketsUrlString)!, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func reservationsAction(_ sender: Any) {
        MyAnalytics.screenView(screenName: "Vehicle Reservations")
        
        MyAnalytics.event(category: "Ferries", action: "open_link", label: "vehicle_reservations")
        
        let config = SFSafariViewController.Configuration()
        let svc = SFSafariViewController(url: URL(string: self.reservationsUrlString)!, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }

    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Route Schedules"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        performSegue(withIdentifier: SegueRouteDeparturesViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let routeItem = self.routes[indexPath.row] as FerryScheduleItem
                let destinationViewController: RouteDeparturesViewController = segue.destination as! RouteDeparturesViewController
                destinationViewController.title = routeItem.routeDescription
                destinationViewController.routeItem = routeItem
                destinationViewController.routeId = routeItem.routeId
            }
        }
    }
    
    fileprivate func styleButtons() {
    
        vesselWatchButton.layer.cornerRadius = 5
        vesselWatchButton.clipsToBounds = true
        vesselWatchButton.titleLabel?.lineBreakMode = .byWordWrapping
    
        ticketsButton.layer.cornerRadius = 5
        ticketsButton.clipsToBounds = true
        ticketsButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        reservationsButton.layer.cornerRadius = 5
        reservationsButton.clipsToBounds = true
        reservationsButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
}
