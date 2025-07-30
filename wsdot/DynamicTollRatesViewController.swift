//
//  I405ViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

import Foundation
import UIKit
import SafariServices

class DynamicTollRatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "I405TollRatesCell"
    let SegueTollTripDetailsViewController = "SegueTollTripDetailsViewController"

    var stateRoute: String?
    
    var displayedTollRates = [TollRateSignItem]()
    var northboundTollRates = [TollRateSignItem]()
    var southboundTollRates = [TollRateSignItem]()
    
    var northboundTravelTime = ""
    var southboundTravelTime = ""
    
    let refreshControl = UIRefreshControl()
    
    fileprivate var actionSheet: UIAlertController!
    
    @IBOutlet weak var travelTimeTextLabel: UILabel!
    @IBOutlet weak var infoLinkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var directionSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BorderWaitsViewController.refreshAction(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh(true)
        tableView.addSubview(refreshControl)
        activityIndicator.startAnimating()
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TollRateSignsStore.updateTollRateSigns(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            if let route = selfValue.stateRoute {
                            
                                selfValue.northboundTollRates = TollRateSignsStore.getNorthboundTollRatesByRoute(route: route)
                                selfValue.southboundTollRates = TollRateSignsStore.getSouthboundTollRatesByRoute(route: route)
                                
                                if (selfValue.directionSegmentControl.selectedSegmentIndex == 0){
                                    selfValue.displayedTollRates = selfValue.northboundTollRates
                                } else {
                                    selfValue.displayedTollRates = selfValue.southboundTollRates
                                }
                            
                            }
                            selfValue.tableView.reloadData()
                            selfValue.activityIndicator.stopAnimating()
                            selfValue.activityIndicator.isHidden = true
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            selfValue.refreshControl.endRefreshing()
                            selfValue.activityIndicator.stopAnimating()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.tolling, message: WSDOTErrorStrings.tollRates)
                        }
                    }
                }
            })
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            if let route = selfValue.stateRoute {
                                if (route == "405") {
                                    MyAnalytics.screenView(screenName: "I405TollRates")
                                    if let travelTimeGroup = TravelTimesStore.getTravelTimeBy(id: 35) {
                                        selfValue.northboundTravelTime = selfValue.getTravelTimeFromGroup(travelTimeGroup: travelTimeGroup)
                                    }
                                    
                                    if let travelTimeGroup = TravelTimesStore.getTravelTimeBy(id: 38) {
                                        selfValue.southboundTravelTime = selfValue.getTravelTimeFromGroup(travelTimeGroup: travelTimeGroup)
                                    }
                                } else if (route == "167") {
                                    MyAnalytics.screenView(screenName: "SR167TollRates")
                                    if let travelTimeGroup = TravelTimesStore.getTravelTimeBy(id: 67) {
                                        selfValue.northboundTravelTime = selfValue.getTravelTimeFromGroup(travelTimeGroup: travelTimeGroup)
                                    }
                                    
                                    if let travelTimeGroup = TravelTimesStore.getTravelTimeBy(id: 70) {
                                        selfValue.southboundTravelTime = selfValue.getTravelTimeFromGroup(travelTimeGroup: travelTimeGroup)
                                    }
                                }
                                
                                if (selfValue.directionSegmentControl.selectedSegmentIndex == 0){
                                    if let label = selfValue.travelTimeTextLabel {
                                        label.text = selfValue.northboundTravelTime
                                    }
                                } else {
                                    if let label = selfValue.travelTimeTextLabel {
                                        label.text = selfValue.southboundTravelTime
                                    }
                                }
                                
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        AlertMessages.getConnectionAlert(backupURL: WsdotURLS.tolling, message: WSDOTErrorStrings.travelTimes)
                    }
                }
            })
        }
    }

    @IBAction func infoLinkAction(_ sender: UIButton) {
        if stateRoute == "405" {
            MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_405")
     
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            let svc = SFSafariViewController(url: URL(string: "https://www.wsdot.wa.gov/Tolling/405/rates.htm")!, configuration: config)
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            self.present(svc, animated: true, completion: nil)
        } else if stateRoute == "167" {
            MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_hot_lanes")
            
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            let svc = SFSafariViewController(url: URL(string: "https://wsdot.wa.gov/travel/roads-bridges/toll-roads-bridges-tunnels/sr-167-high-occupancy-toll-hot-lanes")!, configuration: config)
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            self.present(svc, animated: true, completion: nil)
        }
    }

    /*
     * Creates a string for the travel time header,
     * Checks if the group has a general purpose and HOV travel time.
     */
    func getTravelTimeFromGroup(travelTimeGroup: TravelTimeItemGroup) -> String {
        
        var gpTime = -1
        var etlTime = -1
        
        gpTime = travelTimeGroup.routes[0].currentTime
        etlTime = travelTimeGroup.routes[0].hovCurrentTime
        
        if (gpTime != -1 && etlTime != -1) {
            return "\(travelTimeGroup.title): \(gpTime) min or \(etlTime) min via ETL"
        } else {
            return ""
        }
    }

    // MARK -- TableView delegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTollRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! GroupRouteCell
        
        // Remove any RouteViews carried over from being recycled.
        for route in cell.dynamicRouteViews {
            route.removeFromSuperview()
        }
        
        cell.dynamicRouteViews.removeAll()
        
        let tollSign = displayedTollRates[indexPath.row]

        cell.routeLabel.text = "\(tollSign.locationTitle)"
        
        // set up favorite button
        cell.favoriteButton.setImage(tollSign.selected ? UIImage(named: "icStarSmallFilled") : UIImage(named: "icStarSmall"), for: .normal)
        cell.favoriteButton.tintColor = ThemeManager.currentTheme().darkColor

        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(_:)), for: .touchUpInside)
        
        var lastTripView: TollTripView? = nil
        
        for trip in tollSign.trips {
        
            let tripView = TollTripView.instantiateFromXib()
            
            tripView.translatesAutoresizingMaskIntoConstraints = false
            tripView.contentView.translatesAutoresizingMaskIntoConstraints = false
            tripView.topLabel.translatesAutoresizingMaskIntoConstraints = false
            tripView.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
            tripView.actionButton.translatesAutoresizingMaskIntoConstraints = false
            tripView.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            tripView.actionButton.signIndex = indexPath.row
            tripView.actionButton.tripIndex = tollSign.trips.index(of: trip)
            tripView.actionButton.addTarget(self, action: #selector(tripButtonAction(_:)), for: .touchUpInside)
            
            if tollSign.stateRoute == 405 {
                tripView.topLabel.text = "to \(trip.endLocationName)"
            } else {
                tripView.topLabel.text = "Carpools and motorcycles free"
            }
                
            tripView.bottomLabel.text = TimeUtils.timeAgoSinceDate(date: trip.updatedAt, numericDates: true)
                
            if (trip.message == ""){
                tripView.valueLabel.text = "$" + String(format: "%.2f", locale: Locale.current, arguments: [trip.toll])
            } else {
                //tripView.valueLabel.adjustsFontSizeToFitWidth = true
                tripView.valueLabel.allowsDefaultTighteningForTruncation = true
                tripView.valueLabel.text = trip.message
                tripView.valueLabel.font = UIFont.preferredFont(forTextStyle: .body)

            }
            
            cell.contentView.addSubview(tripView)
   
            tripView.contentView.leadingAnchor.constraint(equalTo: cell.routeLabel.leadingAnchor).isActive = true
            tripView.contentView.trailingAnchor.constraint(equalTo: cell.routeLabel.trailingAnchor, constant: 8).isActive = true
            tripView.contentView.topAnchor.constraint(equalTo: (lastTripView == nil ? cell.routeLabel.bottomAnchor : lastTripView!.bottomLabel.bottomAnchor), constant: (lastTripView == nil ? 0 : 8)).isActive = true
            
            if tollSign.trips.index(of: trip) == tollSign.trips.index(of: tollSign.trips.last!) {
                tripView.bottomLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16).isActive = true
                tripView.line.isHidden = true
            }
            
            cell.dynamicRouteViews.append(tripView)
            lastTripView = tripView
        
        }

        cell.sizeToFit()
        return cell
    }

    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
        case 0:
            displayedTollRates = northboundTollRates
            if let label = travelTimeTextLabel {
                label.text = northboundTravelTime
            }
            tableView.reloadData()
            break
        case 1:
            displayedTollRates = southboundTollRates
            if let label = travelTimeTextLabel {
                label.text = southboundTravelTime
            }
            tableView.reloadData()
            break
        default:
            break
        }
    }

    @objc func tripButtonAction(_ sender: UIButton) {
        // Perform Segue
        performSegue(withIdentifier: SegueTollTripDetailsViewController, sender: sender)
    }

    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTollTripDetailsViewController {

            if let button = sender as? TripMapButton {
            
                let tollSign = displayedTollRates[button.signIndex!]
                let tollTrip = tollSign.trips[button.tripIndex!]

                let destinationViewController = segue.destination as! TollTripDetailsViewController
                
                destinationViewController.title = tollSign.locationTitle
                destinationViewController.text = tollTrip.endLocationName
                
                destinationViewController.startLatitude = tollSign.startLatitude
                destinationViewController.startLongitude = tollSign.startLongitude
                
                destinationViewController.endLatitude = tollTrip.endLatitude
                destinationViewController.endLongitude = tollTrip.endLongitude
            
            }
        }
    }
    
    @objc func actionSheetBackgroundTapped() {
        self.actionSheet.dismiss(animated: true, completion: nil)
    }

    // MARK: Favorite action
    @objc func favoriteAction(_ sender: UIButton) {
        let index = sender.tag
        let tollSign = self.displayedTollRates[index]
        let alertTime = 1.5
        
        if (tollSign.selected){
            TollRateSignsStore.updateFavorite(tollSign, newValue: false)
            sender.setImage(UIImage(named: "icStarSmall"), for: .normal)
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                actionSheet = UIAlertController(title: nil, message: "Removed from Favorites", preferredStyle: .actionSheet)
                self.present(actionSheet, animated: true) {
                    self.actionSheet.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertTime) {
                        self.actionSheet.dismiss(animated: true)
                    }
                }
            }
            
        } else {
            TollRateSignsStore.updateFavorite(tollSign, newValue: true)
            sender.setImage(UIImage(named: "icStarSmallFilled"), for: .normal)
                        
            if UIDevice.current.userInterfaceIdiom != .pad {
                actionSheet = UIAlertController(title: nil, message: "Added to Favorites", preferredStyle: .actionSheet)
                self.present(actionSheet, animated: true) {
                    self.actionSheet.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertTime) {
                        self.actionSheet.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
