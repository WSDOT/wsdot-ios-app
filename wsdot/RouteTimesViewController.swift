//
//  RouteTimesViewController.swift
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
import RealmSwift

class RouteTimesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let departuresSailingSpacesCellIdentifier = "RouteDeparturesSailingSpaces"
    let departureCellIdentifier = "RouteDeparture"
    
    var routeId = -1
    
    var sailingSpaces : [SailingSpacesItem]?
    var vessel : VesselItem?
    
    // Set by parent view
    var currentSailing: FerryTerminalPairItem?
    var sailingsByDate: List<FerryScheduleDateItem>?
    
    var currentDay = 0
    var updatedAt = Date()
    
    var displayedSailing: FerrySailingsItem?
    var displayedTimes = List<FerryDepartureTimeItem>()
    
    var dateData = TimeUtils.nextNDayDates(n: 1, Date())
    
    fileprivate var timer: Timer?
    
    var showConnectionAlert = true
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var departuresHeader: UIView!

    deinit {
        displayedSailing = nil
        sailingSpaces = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDisplayedSailing(0)   
        
        self.tableView.isHidden = true
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteTimesViewController.refreshAction(_:)), for: .valueChanged)
        
        // attribute title still displays after loading when voice over is enabled.
        // Remove until better solution is found
        if (UIAccessibility.isVoiceOverRunning){
            refreshControl.attributedTitle = NSAttributedString.init(string: "loading sailing spaces")
        }
        
        activityIndicator.startAnimating()
        
        tableView.addSubview(refreshControl)
        
        timer = Timer.scheduledTimer(timeInterval: CachesStore.spacesUpdateTime, target: self, selector: #selector(RouteTimesViewController.spacesTimerTask), userInfo: nil, repeats: true)
    
        refresh(scrollToCurrentSailing: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "FerryTimes")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @objc func spacesTimerTask(_ timer:Timer) {
        refresh(scrollToCurrentSailing: false)
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        showConnectionAlert = true
        refresh(scrollToCurrentSailing: true)
    }
    
    func refresh(scrollToCurrentSailing: Bool) {
        
        // hidden when not in use, prevents
        // view from showing while voice over is on
        refreshControl.isHidden = false
        refreshControl.beginRefreshing()
        
        if (currentDay == 0) && (displayedSailing != nil){
            
            let departingId = displayedSailing!.departingTerminalId
            let arrivingId = displayedSailing!.arrivingTerminalId
            
            // fetch sailings spaces to show along side times
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
                SailingSpacesStore.getSailingSpacesForTerminal(departingId, arrivingId: arrivingId, completion: { data, error in
                    if let validData = data {
                        DispatchQueue.main.async { [weak self] in
                            if let selfValue = self {
                                selfValue.sailingSpaces = validData
                                selfValue.updatedAt = Date()
                                selfValue.tableView.reloadData()
                                selfValue.tableView.layoutIfNeeded()
                                selfValue.refreshControl.endRefreshing()
                                selfValue.refreshControl.isHidden = true
                                selfValue.activityIndicator.stopAnimating()
                                if (scrollToCurrentSailing){
                                    selfValue.scrollToNextSailing(selfValue.displayedTimes)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            if let selfValue = self{
                                selfValue.refreshControl.endRefreshing()
                                selfValue.refreshControl.isHidden = true
                                selfValue.activityIndicator.stopAnimating()
                                if (selfValue.showConnectionAlert){
                                    selfValue.showConnectionAlert = false
                                    selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                                }
                            }
                        }
                    }
                })
            }
            
            // fetch vessel actual departures and ETAs
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
                VesselWatchStore.getVesselForTerminalCombo(departingId, arrivingTerminalID: arrivingId, completion: { data, error in
                    if let vessel = data {
                        DispatchQueue.main.async { [weak self] in
                            if let selfValue = self {
                                selfValue.vessel = vessel
                                selfValue.tableView.reloadData()
                            }
                        }
                    }
                })
            }
        } else {
            self.refreshControl.endRefreshing()
            self.refreshControl.isHidden = true
        }
    }
    
    func changeDay(_ index: Int) {
        currentDay = index
        setDisplayedSailing(currentDay)
        self.tableView.reloadData()
        self.scrollToNextSailing(self.displayedTimes)
    }
    
    func changeTerminal(_ terminal: FerryTerminalPairItem?) {
        self.refreshControl.beginRefreshing()
        self.currentSailing = terminal
        self.setDisplayedSailing(currentDay)
        self.tableView.reloadData()
    }
    
    // MARK: -
    // MARK: Table View Delegate & data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTimes.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: departureCellIdentifier) as! DeparturesCustomCell
        
        // Check if sailing space information is avaliable. If so change prototype cell.
        if let sailingSpacesValue = sailingSpaces {
        
            for spaceItem: SailingSpacesItem in sailingSpacesValue {

                if displayedTimes[indexPath.row].departingTime == spaceItem.date {
                
                    // Only add sailing spaces for future sailings
                    if (displayedTimes[indexPath.row].departingTime.compare(NSDate() as Date) == .orderedDescending) {
                
                        cell = tableView.dequeueReusableCell(withIdentifier: departuresSailingSpacesCellIdentifier) as! DeparturesCustomCell
                        cell.sailingSpaces.isHidden = false
                        cell.sailingSpaces.text = String(spaceItem.remainingSpaces) + " Drive-up Spaces"
                        cell.avaliableSpacesBar.isHidden = false
                    
                        cell.avaliableSpacesBar.progress = spaceItem.percentAvaliable
                    
                        cell.avaliableSpacesBar.transform = UIProgressView().transform
                        cell.avaliableSpacesBar.transform = cell.avaliableSpacesBar.transform.scaledBy(x: 1, y: 3)
                    
                        cell.spacesDisclaimer.isHidden = false
                        cell.updated.isHidden = false
                        cell.updated.text = "Drive-up spaces updated " + TimeUtils.timeAgoSinceDate(date: updatedAt, numericDates: true)
                    
                    }
                }
            }
        }
        
        // check for actual departure time and ETA
        cell.actualDepartureLabel.text = ""
        cell.etaLabel.text = ""

        if let vesselValue = vessel {

            if let departure = vesselValue.nextDeparture {
                if departure == displayedTimes[indexPath.row].departingTime {

                    if let leftDock = vesselValue.leftDock {
                        cell.actualDepartureLabel.text = "Actual departure \(TimeUtils.getTimeOfDay(leftDock))"
                    }

                    if let eta = vesselValue.eta {
                        cell.etaLabel.text = "ETA \(TimeUtils.getTimeOfDay(eta))"
                        
                        // turn past etas gray
                        if (eta.compare(NSDate() as Date) != .orderedDescending) {
                            cell.etaLabel.textColor = UIColor.gray
                        } else {
                            cell.etaLabel.textColor = UIColor.black
                        }
                    }
                }
            }
        }
    
        let displayDepartingTime = TimeUtils.getTimeOfDay(displayedTimes[indexPath.row].departingTime)
        cell.departingTime.text = displayDepartingTime
        
        if let arrivingTime = displayedTimes[indexPath.row].arrivingTime {
            let displayArrivingTime = TimeUtils.getTimeOfDay(arrivingTime)
            cell.arrivingTime.text = displayArrivingTime
            cell.arrivingTime.accessibilityLabel = displayArrivingTime
        } else {
            cell.arrivingTime.text = ""
            cell.arrivingTime.accessibilityLabel = ""
        }
        
        var annotationsString = ""
        
        for indexObj in displayedTimes[indexPath.row].annotationIndexes{
            annotationsString += displayedSailing!.annotations[indexObj.index].message + " "
        }
        
        if (annotationsString != "") {
            cell.annotations.isHidden = false
            let taglessString = annotationsString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            cell.annotations.text = taglessString
        } else {
            cell.annotations.text = nil
        }
        
        // turn past departures gray
        if (displayedTimes[indexPath.row].departingTime.compare(NSDate() as Date) != .orderedDescending) {
            cell.departingTime.textColor = UIColor.gray
            cell.arrivingTime.textColor = UIColor.gray
            cell.annotations.textColor = UIColor.gray
            cell.actualDepartureLabel.textColor = UIColor.gray
        } else {
            cell.departingTime.textColor = UIColor.black
            cell.arrivingTime.textColor = UIColor.black
            cell.annotations.textColor = UIColor.black
            cell.actualDepartureLabel.textColor = UIColor.black
        }
 
        // Accessibility Setup
        cell.accessibilityLabel = "departing " + cell.departingTime.text!
            + (cell.arrivingTime.accessibilityLabel != "" ? ". arriving " + cell.arrivingTime.accessibilityLabel! + ". " : ".")
        
        if (cell.actualDepartureLabel.text != nil) {
            cell.accessibilityLabel = cell.accessibilityLabel! + cell.actualDepartureLabel.text!
        }
        
        // ETA text
        if (cell.arrivingTime.text != nil) {
            cell.accessibilityLabel = cell.accessibilityLabel! + cell.arrivingTime.text!
        }
        
        if (cell.annotations.attributedText != nil){
            cell.accessibilityLabel = cell.accessibilityLabel! + (cell.annotations.attributedText?.string)! + ". "
        }
        
        if (cell.sailingSpaces) != nil {
            cell.accessibilityLabel = cell.accessibilityLabel! + cell.sailingSpaces.text! + " " + cell.spacesDisclaimer.text! + ". "
            cell.accessibilityLabel = cell.accessibilityLabel! + cell.updated.text!
        }
        cell.isAccessibilityElement = true
        
        return cell
    }
    
    // MARK: Helper functions
    func setDisplayedSailing(_ day: Int){
        
        var sailings = List<FerrySailingsItem>()
        
        // get sailings for selected day
        if let sailingsByDateValue = sailingsByDate {
            sailings = sailingsByDateValue[day].sailings
        }
        
        // get sailings for current route
        for sailing in sailings {
            if ((sailing.departingTerminalName == currentSailing!.aTerminalName) && (sailing.arrivingTerminalName == currentSailing!.bTterminalName)) {
                displayedSailing = sailing
            }
        }
        
        displayedTimes.removeAll()
        
        // make list of displayable times
        if displayedSailing != nil {
            for time in displayedSailing!.times {
                displayedTimes.append(time)
            }
        }
    }
    
    // Scrolls table view to the next departure. Compares departing times with
    // current time to find it.
    // uses a quick sleep timer to ensure the cells have had time to get their size
    // so we scroll to the correct location.
    fileprivate func scrollToNextSailing(_ sailings: List<FerryDepartureTimeItem>) {
        let index = getNextSailingIndex(sailings)
        DispatchQueue.global(qos: .background).async {
            usleep(50000)
            DispatchQueue.main.async {
                if self.tableView.numberOfRows(inSection: 0) > index {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    fileprivate func getNextSailingIndex(_ sailings: List<FerryDepartureTimeItem>) -> Int {
        for time in sailings {
            if (time.departingTime.compare(Date()) == .orderedDescending) {
                return sailings.index(of: time) ?? 0
            }
        }
        return 0
    }
}
