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
import GoogleMobileAds

class TravelTimesViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, GADBannerViewDelegate {
    
    let cellIdentifier = "TravelTimeCell"
    
    let segueTravelTimesViewController = "TravelTimesViewController"
    
    var travelTimeGroups = [TravelTimeItemGroup]()
    var filtered = [TravelTimeItemGroup]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GAMBannerView!
    
    let refreshControl = UIRefreshControl()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Travel Times"
        
        // init search Controlller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        //searchController.dimsBackgroundDuringPresentation = false
     
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TravelTimesViewController.refreshAction(_:)), for: .valueChanged)
        
        if #available(iOS 13, *) {
            refreshControl.backgroundColor = .systemGroupedBackground
            tableView.backgroundView = refreshControl
            extendedLayoutIncludesOpaqueBars = true
        } else {
            tableView.addSubview(refreshControl)
        }

        showOverlay(self.view)
        refresh(true)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.adSize = getFullWidthAdaptiveAdSize()
        bannerView.rootViewController = self
        let request = GAMRequest()
        request.customTargeting = ["wsdotapp":"traffic"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TravelTimes")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    // Make sure table has the latest data when the view displays
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.travelTimeGroups = TravelTimesStore.getAllTravelTimeGroups().sorted(by: {$0.routes[0].title < $1.routes[0].title })
        self.tableView.reloadData()
        tableView.rowHeight = UITableView.automaticDimension

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.travelTimeGroups = TravelTimesStore.getAllTravelTimeGroups().sorted(by: {$0.routes[0].title < $1.routes[0].title })
                            selfValue.filtered = selfValue.travelTimeGroups.sorted(by: {$0.routes[0].title < $1.routes[0].title })
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.travelTimes)
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
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! GroupRouteCell
        let travelTimeGroup = filtered[indexPath.row]
        
        // Remove any RouteViews carried over from being recycled.
        for route in cell.dynamicRouteViews {
            route.removeFromSuperview()
        }
        cell.dynamicRouteViews.removeAll()
        
    
        
        cell.routeLabel.text = travelTimeGroup.title

        // set up favorite button
        cell.favoriteButton.setImage(travelTimeGroup.selected ? UIImage(named: "icStarSmallFilled") : UIImage(named: "icStarSmall"), for: .normal)
        cell.favoriteButton.tintColor = ThemeManager.currentTheme().darkColor

        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(_:)), for: .touchUpInside)

        let lastRouteView: RouteView? = nil
        
        for route in travelTimeGroup.routes {
        
            let routeView = RouteView.instantiateFromXib()
            
            routeView.translatesAutoresizingMaskIntoConstraints = false
            routeView.contentView.translatesAutoresizingMaskIntoConstraints = false
            routeView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.updatedLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            routeView.titleLabel.text = "Via \(route.viaText)"
            routeView.subtitleLabel.text = "\(route.distance) miles"
            
            if ((route.startLatitude != 0 && route.startLongitude != 0) && (route.endLatitude != 0 && route.endLongitude != 0)) {
                routeView.mapButton.routeIndex = indexPath.row
                routeView.mapButton.travelTimeIndex = travelTimeGroup.routes.index(of: route)
                routeView.mapButton.addTarget(self, action: #selector(travelTimeButtonAction(_:)), for: .touchUpInside)
                routeView.mapButton.setTitleColor(Colors.wsdotGreen, for: .normal)
            }
            else {
                routeView.mapButton.isHidden = true
            }
            
            if self is MyRouteTravelTimesViewController {
                routeView.mapButton.isHidden = true
            }
            
            do {
                let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(route.updated), numericDates: true)
                routeView.updatedLabel.text = updated
            } catch {
                routeView.updatedLabel.text = "N/A"
            }
            
            if (route.averageTime > route.currentTime){
                routeView.valueLabel.textColor = Colors.tintColor
            } else if (route.averageTime < route.currentTime){
                routeView.valueLabel.textColor = UIColor.red
            } else {
           
                if #available(iOS 13, *) {
                    routeView.valueLabel.textColor = UIColor.label
                } else {
                    routeView.valueLabel.textColor = UIColor.darkText
                }
           
            }
            
            if ((route.currentTime != 0) && (route.currentTime != -1)) {
                routeView.valueLabel.text = "\(route.currentTime) min"
                routeView.subtitleLabel.isHidden = false
            } else if (route.status.lowercased() == "closed"){
                routeView.valueLabel.text = route.status
                routeView.subtitleLabel.isHidden = true
                routeView.mapButton.isHidden = true
                routeView.valueLabel.textColor = UIColor.darkText
                if #available(iOS 13, *) {
                    routeView.valueLabel.textColor = UIColor.label
                } else {
                    routeView.valueLabel.textColor = UIColor.darkText
                }
            }
            else {
                routeView.valueLabel.text = "N/A"
                routeView.subtitleLabel.isHidden = true
                routeView.mapButton.isHidden = true
                routeView.valueLabel.textColor = UIColor.darkText
                if #available(iOS 13, *) {
                    routeView.valueLabel.textColor = UIColor.label
                } else {
                    routeView.valueLabel.textColor = UIColor.darkText
                }
            }
            
            if (route.currentTime == -1) {
                routeView.valueLabel.text = "N/A"
                routeView.subtitleLabel.text = "Not Available"
                routeView.mapButton.isHidden = true
                if #available(iOS 13.0, *) {
                    routeView.valueLabel.textColor = UIColor.label
                } else {
                    routeView.valueLabel.textColor = UIColor.darkText
                }
            }
            
            cell.contentView.addSubview(routeView)
            
            let leadingSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView as Any, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
            cell.contentView.addConstraint(leadingSpaceConstraintForRouteView)
            
            let trailingSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView as Any, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(trailingSpaceConstraintForRouteView)
            
            let topSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView as Any, attribute: .top, relatedBy: .equal, toItem: (lastRouteView == nil ? cell.routeLabel : lastRouteView!.updatedLabel), attribute: .bottom, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(topSpaceConstraintForRouteView)
            
            if travelTimeGroup.routes.index(of: route) == travelTimeGroup.routes.index(of: travelTimeGroup.routes.last!) {
                let bottomSpaceConstraint = NSLayoutConstraint(item: routeView.updatedLabel as Any, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: -16)
                cell.contentView.addConstraint(bottomSpaceConstraint)
                routeView.line.isHidden = true
            }
            
            cell.dynamicRouteViews.append(routeView)
            routeView.line.isHidden = true
            // lastRouteView = routeView

        }

        cell.sizeToFit()
     
        return cell
    }
    
    @objc func travelTimeButtonAction(_ sender: UIButton) {
        // Perform Segue
        performSegue(withIdentifier: segueTravelTimesViewController, sender: sender)
        
    }

    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueTravelTimesViewController {
            if let button = sender as? TravelTimeMapButton {
                
                if let searchText = searchController.searchBar.text {
                    
                    if (searchText.isEmpty) {
                        let routeIndex = travelTimeGroups[button.routeIndex!]
                        let travelTimeIndex = routeIndex.routes[button.travelTimeIndex!]
                        let destinationViewController = segue.destination as! TravelTimeAlertViewController
                        destinationViewController.travelTimeId = travelTimeIndex.routeid
                    }
                    else {
                        
                        filtered = searchText.isEmpty ? travelTimeGroups : travelTimeGroups.filter({(travelTimeGroup: TravelTimeItemGroup) -> Bool in
                            
                            let tollSign = filtered[button.routeIndex!]
                            let tollTrip = tollSign.routes[button.travelTimeIndex!]
                            let destinationViewController = segue.destination as! TravelTimeAlertViewController
                            destinationViewController.travelTimeId = tollTrip.routeid
                            return travelTimeGroup.title.range(of: searchText, options: .caseInsensitive) != nil
                            
                        })
                    }
                }
            }
        }
    }
    
    // MARK: UISearchBar Delegate Methods
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filtered = searchText.isEmpty ? travelTimeGroups : travelTimeGroups.filter({(travelTimeGroup: TravelTimeItemGroup) -> Bool in
                return travelTimeGroup.title.range(of: searchText, options: .caseInsensitive) != nil
            }).sorted(by: {$0.routes[0].title < $1.routes[0].title })
            tableView.reloadData()
        }
    }
    
    // MARK: Favorite action
    @objc func favoriteAction(_ sender: UIButton) {
        let index = sender.tag
        let travelTimeGroup = filtered[index]
        
        if (travelTimeGroup.selected){
            TravelTimesStore.updateFavorite(travelTimeGroup, newValue: false)
            sender.setImage(UIImage(named: "icStarSmall"), for: .normal)
        }else {
            TravelTimesStore.updateFavorite(travelTimeGroup, newValue: true)
            sender.setImage(UIImage(named: "icStarSmallFilled"), for: .normal)
        }
    }
}
