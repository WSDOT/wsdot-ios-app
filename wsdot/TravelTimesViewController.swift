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
    
    var travelTimes = [TravelTimeItem]()
    var filtered = [TravelTimeItem]()
    
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
        
        self.travelTimes = TravelTimesStore.getAllTravelTimes()
        self.tableView.reloadData()
        
        refresh(false)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map/Traveler Information/Travel Times")
    }
    
    func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.travelTimes = TravelTimesStore.getAllTravelTimes()
                            selfValue.filtered = selfValue.travelTimes
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

        let travelTime = filtered[indexPath.row]
        
        cell.routeLabel.text = travelTime.title
        
        cell.subtitleLabel.text = String(travelTime.distance) + " miles / " + String(travelTime.averageTime) + " min"
        
        do {
            let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(travelTime.updated), numericDates: false)
            cell.updatedLabel.text = updated
        } catch TimeUtils.TimeUtilsError.invalidTimeString {
            cell.updatedLabel.text = "N/A"
        } catch {
            cell.updatedLabel.text = "N/A"
        }
        
        if travelTime.currentTime == 0{
            cell.currentTimeLabel.text = "N/A"
        } else {
            cell.currentTimeLabel.text = String(travelTime.currentTime) + " min"
        }
        
        if (travelTime.averageTime > travelTime.currentTime){
            cell.currentTimeLabel.textColor = Colors.tintColor
        } else if (travelTime.averageTime < travelTime.currentTime){
            cell.currentTimeLabel.textColor = UIColor.red
        } else {
            cell.currentTimeLabel.textColor = UIColor.darkText
        }

        cell.sizeToFit()
        
        return cell
    }
    

    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueTravelTimesViewController, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UISearchBar Delegate Methods
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filtered = searchText.isEmpty ? travelTimes : travelTimes.filter({(travelTime: TravelTimeItem) -> Bool in
                return travelTime.title.range(of: searchText, options: .caseInsensitive) != nil
            })
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueTravelTimesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let travelTimeItem = self.filtered[indexPath.row] as TravelTimeItem
                let destinationViewController = segue.destination as! TravelTimeDetailsViewController
                destinationViewController.travelTime = travelTimeItem
            }
        }
    }
}


    
