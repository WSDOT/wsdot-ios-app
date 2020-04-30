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
    
    var displayedSailing: FerrySailingsItem?
    var displayedTimes = List<FerryDepartureTimeItem>()
    
    var dateData = TimeUtils.nextNDayDates(n: 1, Date())
    
    fileprivate var timer: Timer?
    
    var showConnectionAlert = true
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var departuresHeader: UIView!
    
    deinit {
        displayedSailing = nil
        sailingSpaces = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteTimesViewController.refreshAction(_:)), for: .valueChanged)
        
        // attribute title still displays after loading when voice over is enabled.
        // Remove until better solution is found
        if (UIAccessibility.isVoiceOverRunning){
            refreshControl.attributedTitle = NSAttributedString.init(string: "loading sailing spaces")
        }
        
        
        tableView.addSubview(refreshControl)
        
        timer = Timer.scheduledTimer(timeInterval: CachesStore.spacesUpdateTime, target: self, selector: #selector(RouteTimesViewController.spacesTimerTask), userInfo: nil, repeats: true)
    
        setDisplayedSailing(0)

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
                                selfValue.tableView.isHidden = true
                                selfValue.sailingSpaces = validData
                                selfValue.tableView.reloadData()
                       
                                selfValue.refreshControl.endRefreshing()
                                selfValue.refreshControl.isHidden = true
                    
                                if (scrollToCurrentSailing){
                                    selfValue.scrollToLastDeparture(selfValue.displayedTimes)
                                } else {
                                    selfValue.tableView.isHidden = false
                                }
                                
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            if let selfValue = self{
                                selfValue.refreshControl.endRefreshing()
                                selfValue.refreshControl.isHidden = true
                                if (selfValue.showConnectionAlert){
                                    selfValue.showConnectionAlert = false
                                    AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.ferrySailings)
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
                                selfValue.tableView.beginUpdates()
                                selfValue.tableView.endUpdates()
                                
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
        self.scrollToLastDeparture(self.displayedTimes)
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

    // reload data on rotations to ensure cells display correctly
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.reloadData()
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            self.tableView.reloadData()
        })
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: departuresSailingSpacesCellIdentifier) as! DeparturesCustomCell
     
        cell.sailingSpaces.isHidden = true
        cell.spacesDisclaimer.isHidden = true
        cell.avaliableSpacesBar.isHidden = true
        
        cell.vesselAtDockStack.isHidden = true
        
        if let sailingSpacesValue = sailingSpaces {
            
            for spaceItem: SailingSpacesItem in sailingSpacesValue {
                    
                if displayedTimes[indexPath.row].departingTime == spaceItem.date {
                
                    // Only add sailing spaces for future sailings
                    if (displayedTimes[indexPath.row].departingTime.compare(NSDate() as Date) == .orderedDescending) {
                
                        cell.sailingSpaces.isHidden = false
                        cell.spacesDisclaimer.isHidden = false
                        cell.avaliableSpacesBar.isHidden = false
                
                        cell.sailingSpaces.text = String(spaceItem.remainingSpaces) + " drive-up spaces"
                        cell.avaliableSpacesBar.progress = spaceItem.percentAvaliable
                    
                        
                        cell.avaliableSpacesBar.transform = UIProgressView().transform
                        cell.avaliableSpacesBar.transform = cell.avaliableSpacesBar.transform.scaledBy(x: 1, y: 4)
                        
                    }
                }
            }
        }
        
        // check for actual departure time and ETA
        cell.deptAndETAStack.isHidden = true
        cell.etaLabel.isHidden = true
        cell.actualDepartureLabel.isHidden = true

        if let vesselValue = vessel {

            if let departure = vesselValue.nextDeparture {
                if departure == displayedTimes[indexPath.row].departingTime {

                    cell.vesselAtDockStack.isHidden = !vesselValue.atDock

                    if let leftDock = vesselValue.leftDock {
                        cell.actualDepartureLabel.text = "\(TimeUtils.getTimeOfDay(leftDock))"
                        cell.actualDepartureLabel.isHidden = false
                        cell.deptAndETAStack.isHidden = false
                        
                    }

                    if let eta = vesselValue.eta {
                        cell.etaLabel.text = "\(TimeUtils.getTimeOfDay(eta))"
                        cell.etaLabel.isHidden = false
                        cell.deptAndETAStack.isHidden = false
                        
                        // turn past etas gray
                        if (eta.compare(NSDate() as Date) != .orderedDescending) {
                            cell.departingTimeBox.backgroundColor = UIColor.gray
                        } else {
                            cell.departingTimeBox.backgroundColor = Colors.wsdotPrimary
                        }
                    }
                }
            }
        }
    
        // Check for annotations

        cell.annotations.isHidden = true
        
        var annotationsString = ""
        
        for indexObj in displayedTimes[indexPath.row].annotationIndexes{
            annotationsString += displayedSailing!.annotations[indexObj.index].message + " "
        }
        
        if (annotationsString != "") {
            cell.annotations.isHidden = false
            let taglessString = annotationsString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            cell.annotations.text = taglessString
        }
    
        let displayDepartingTime = TimeUtils.getTimeOfDay(displayedTimes[indexPath.row].departingTime)
        cell.departingTime.text = displayDepartingTime
        
        if let arrivingTime = displayedTimes[indexPath.row].arrivingTime {
            let displayArrivingTime = TimeUtils.getTimeOfDay(arrivingTime)
                cell.arrivingTime.text = displayArrivingTime
                cell.arrivingTime.accessibilityLabel = displayArrivingTime
            
            if (arrivingTime.compare(NSDate() as Date) != .orderedDescending) {
                cell.arrivingTimeBox.backgroundColor = UIColor.gray
            } else {
                cell.arrivingTimeBox.backgroundColor = Colors.wsdotPrimary
            }
            cell.arrivingTimeLabel.isHidden = false

        } else {
            cell.arrivingTime.text = ""
            cell.arrivingTimeLabel.isHidden = true
            cell.arrivingTimeBox.backgroundColor = UIColor.clear
            cell.arrivingTime.accessibilityLabel = ""
        }

        // turn past departures gray
        if (displayedTimes[indexPath.row].departingTime.compare(NSDate() as Date) != .orderedDescending) {
            cell.departingTimeBox.backgroundColor = UIColor.gray
            cell.annotations.textColor = UIColor.gray
        } else {
            cell.annotations.textColor = UIColor.black
            cell.departingTimeBox.backgroundColor = Colors.wsdotPrimary
            if #available(iOS 13, *) {
            cell.annotations.textColor = UIColor.label
                cell.actualDepartureLabel.textColor = UIColor.label
            }
            
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
        }
        cell.isAccessibilityElement = true
       
        // Round only the right corners
        cell.departingTimeBox.roundCorners(corners: UIRectCorner(arrayLiteral: [.bottomRight, .topRight]), radius: 5)
        cell.arrivingTimeBox.roundCorners(corners: UIRectCorner(arrayLiteral: [.bottomLeft, .topLeft]), radius: 5)
        
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
        
        refresh(scrollToCurrentSailing: true)
    }
    
    // Scrolls table view to the last departure. Compares departing times with
    // current time to find it.
    fileprivate func scrollToLastDeparture(_ sailings: List<FerryDepartureTimeItem>) {
        let index = getLastDepartureIndex(sailings)
        if (index != 0) {
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    if self.tableView.numberOfRows(inSection: 0) > index {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        self.tableView.isHidden = false
                    }
                }
            }
        }
    }
    
    fileprivate func getLastDepartureIndex(_ sailings: List<FerryDepartureTimeItem>) -> Int {
        for time in sailings {
            if (time.departingTime.compare(Date()) == .orderedDescending) {
                var index = sailings.index(of: time) ?? 0
                if (index != 0) {
                    index = index - 1
                }
                return index
            }
        }
        return 0
    }
 
}
