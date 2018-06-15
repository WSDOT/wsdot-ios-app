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
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information/Travel Times")
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
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TravelTimeCell
        let travelTimeGroup = filtered[indexPath.row]
        
        // Remove any labels & lines carried over from being recycled.
        for label in cell.dynamicLabels {
            label.removeFromSuperview()
        }
        cell.dynamicLabels.removeAll()
        for line in cell.dynamicLines {
            line.removeFromSuperview()
        }
        cell.dynamicLines.removeAll()
        
        cell.routeLabel.text = travelTimeGroup.title

        // set up favorite button
        cell.favoriteButton.setImage(travelTimeGroup.selected ? UIImage(named: "icStarSmallFilled") : UIImage(named: "icStarSmall"), for: .normal)
        cell.favoriteButton.tintColor = ThemeManager.currentTheme().mainColor

        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(_:)), for: .touchUpInside)

        var lastLine: UIView? = nil
        
        for route in travelTimeGroup.routes {
        
            let line = UIView()
            line.backgroundColor = .lightGray
            line.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(line)
            cell.dynamicLines.append(line)
            let negativeLineRightPadding: CGFloat = -24.0
        
            let viaLabel = UILabel()
            viaLabel.text = "Via \(route.viaText)"
            viaLabel.translatesAutoresizingMaskIntoConstraints = false
            viaLabel.numberOfLines = 0
            cell.contentView.addSubview(viaLabel)
            cell.dynamicLabels.append(viaLabel)
        
            let distanceLabel = UILabel()
            distanceLabel.text = "\(route.distance) miles / \(route.averageTime) min"
            distanceLabel.font = UIFont.systemFont(ofSize: 15)
            distanceLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(distanceLabel)
            cell.dynamicLabels.append(distanceLabel)
            
            let updatedLabel = UILabel()
            do {
                let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(route.updated), numericDates: true)
                updatedLabel.text = updated
            } catch {
                updatedLabel.text = "N/A"
            }
            
            updatedLabel.font = UIFont.systemFont(ofSize: 15)
            updatedLabel.textColor = UIColor.lightGray
            updatedLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(updatedLabel)
            cell.dynamicLabels.append(updatedLabel)
        
            let timeLabel = UILabel()
            
            if (route.status == "open"){
                timeLabel.text = "\(route.currentTime) min"                
                distanceLabel.isHidden = false
            } else {
                distanceLabel.isHidden = true
                timeLabel.text = route.status
            }
            
            if (route.averageTime > route.currentTime){
                timeLabel.textColor = Colors.tintColor
            } else if (route.averageTime < route.currentTime){
                timeLabel.textColor = UIColor.red
            } else {
                timeLabel.textColor = UIColor.darkText
            }
            
            timeLabel.font = UIFont.systemFont(ofSize: 20)
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(timeLabel)
            cell.dynamicLabels.append(timeLabel)
        
            // Align labels with title
            let leadingSpaceConstraintForLine = NSLayoutConstraint(item: line, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
            cell.contentView.addConstraint(leadingSpaceConstraintForLine)
            
            let trailingSpaceConstraintForLine = NSLayoutConstraint(item: line, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(trailingSpaceConstraintForLine)
            
            let leadingSpaceConstraintForViaLabel = NSLayoutConstraint(item: viaLabel, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
            cell.contentView.addConstraint(leadingSpaceConstraintForViaLabel)
        
            let trailingConstraintForViaLabel = NSLayoutConstraint(item: viaLabel, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8)
            cell.contentView.addConstraint(trailingConstraintForViaLabel)
        
            let leadingSpaceConstraintForDistanceLabel = NSLayoutConstraint(item: distanceLabel, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(leadingSpaceConstraintForDistanceLabel)
            
            let leadingSpaceConstraintForUpdatedLabel = NSLayoutConstraint(item: updatedLabel, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(leadingSpaceConstraintForUpdatedLabel)
        
            // set top constraints
            let topSpaceConstraintForViaLabel = NSLayoutConstraint(item: viaLabel, attribute: .top, relatedBy: .equal, toItem: (lastLine == nil ? cell.routeLabel : lastLine), attribute: .bottom, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(topSpaceConstraintForViaLabel)
        
            let topSpaceConstraintForDistanceLabel = NSLayoutConstraint(item: distanceLabel, attribute: .top, relatedBy: .equal, toItem: viaLabel, attribute: .bottom, multiplier: 1, constant: 8)
            cell.contentView.addConstraint(topSpaceConstraintForDistanceLabel)
       
            let topSpaceConstraintForUpdatedLabel = NSLayoutConstraint(item: updatedLabel, attribute: .top, relatedBy: .equal, toItem: distanceLabel, attribute: .bottom, multiplier: 1, constant: 8)
            cell.contentView.addConstraint(topSpaceConstraintForUpdatedLabel)
       
            let topSpaceConstraintForLine = NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: updatedLabel, attribute: .bottom, multiplier: 1, constant: 8)
            cell.contentView.addConstraint(topSpaceConstraintForLine)
       
            // Set travel time constraints
            let centerYConstraintForTimeLabel = NSLayoutConstraint(item: timeLabel, attribute: .bottom, relatedBy: .equal, toItem: updatedLabel, attribute: .bottom, multiplier: 1, constant: 0)
            cell.contentView.addConstraint(centerYConstraintForTimeLabel)
        
            let trailingConstraintForTimeLabel = NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8)
            cell.contentView.addConstraint(trailingConstraintForTimeLabel)
            
            // Set line contraints
            let widthConstraintForLine = NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: cell.contentView, attribute: .width, multiplier: 1, constant: negativeLineRightPadding)
            let heightConstraintForLine = NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 1)
            cell.contentView.addConstraint(widthConstraintForLine)
            cell.contentView.addConstraint(heightConstraintForLine)
        
            if travelTimeGroup.routes.index(of: route) == travelTimeGroup.routes.index(of: travelTimeGroup.routes.last!) {
                let bottomSpaceConstraint = NSLayoutConstraint(item: updatedLabel, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: -8)
                cell.contentView.addConstraint(bottomSpaceConstraint)
                line.isHidden = true
            }
        
            lastLine = line
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
