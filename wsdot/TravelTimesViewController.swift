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
    
    var travelTimeGroups = [TravelTimeItemGroup]()
    var filtered = [TravelTimeItemGroup]()
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
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
        refreshControl.addTarget(self, action: #selector(TravelTimesViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        self.travelTimeGroups = TravelTimesStore.getAllTravelTimeGroups()
        self.tableView.reloadData()
        
        refresh(false)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TravelTimes")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.travelTimeGroups = TravelTimesStore.getAllTravelTimeGroups()
                            selfValue.filtered = selfValue.travelTimeGroups
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
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if let splitVC = self.splitViewController {
            if splitVC.isCollapsed {
                activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
            } else {
                activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
            }
        } else {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.tableView.frame.size.height)
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
        cell.favoriteButton.tintColor = ThemeManager.currentTheme().mainColor

        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(_:)), for: .touchUpInside)

        var lastRouteView: RouteView? = nil
        
        for route in travelTimeGroup.routes {
        
            let routeView = RouteView.instantiateFromXib()
            
            routeView.translatesAutoresizingMaskIntoConstraints = false
            routeView.contentView.translatesAutoresizingMaskIntoConstraints = false
            routeView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.updatedLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            routeView.titleLabel.text = "Via \(route.viaText)"
            routeView.subtitleLabel.text = "\(route.distance) miles / \(route.averageTime) min"
            
            do {
                let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(route.updated), numericDates: true)
                routeView.updatedLabel.text = updated
            } catch {
                routeView.updatedLabel.text = "N/A"
            }
            
            if (route.status == "open"){
                routeView.valueLabel.text = "\(route.currentTime) min"
                routeView.subtitleLabel.isHidden = false
            } else {
                routeView.subtitleLabel.isHidden = true
                routeView.valueLabel.text = route.status
            }
            
            if (route.averageTime > route.currentTime){
                routeView.valueLabel.textColor = Colors.tintColor
            } else if (route.averageTime < route.currentTime){
                routeView.valueLabel.textColor = UIColor.red
            } else {
                routeView.valueLabel.textColor = UIColor.darkText
            }
            
            cell.contentView.addSubview(routeView)
            
            let leadingSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
            cell.contentView.addConstraint(leadingSpaceConstraintForRouteView)
            
            let trailingSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(trailingSpaceConstraintForRouteView)
            
            let topSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView, attribute: .top, relatedBy: .equal, toItem: (lastRouteView == nil ? cell.routeLabel : lastRouteView!.updatedLabel), attribute: .bottom, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(topSpaceConstraintForRouteView)
            
            if travelTimeGroup.routes.index(of: route) == travelTimeGroup.routes.index(of: travelTimeGroup.routes.last!) {
                let bottomSpaceConstraint = NSLayoutConstraint(item: routeView.updatedLabel, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: -16)
                cell.contentView.addConstraint(bottomSpaceConstraint)
                routeView.line.isHidden = true
            }
            
            cell.dynamicRouteViews.append(routeView)
            lastRouteView = routeView
            
        }

        cell.sizeToFit()
     
        return cell
    }

    
    // MARK: UISearchBar Delegate Methods
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filtered = searchText.isEmpty ? travelTimeGroups : travelTimeGroups.filter({(travelTimeGroup: TravelTimeItemGroup) -> Bool in
                return travelTimeGroup.title.range(of: searchText, options: .caseInsensitive) != nil
            })
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
