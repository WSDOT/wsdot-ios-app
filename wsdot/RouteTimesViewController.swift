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
    
    let segueDepartureDaySelectionViewController = "DepartureDaySelectionViewController"
    
    var sailingSpaces : [SailingSpacesItem]?
    
    // Set by parent view
    var currentSailing: FerryTerminalPairItem?
    var sailingsByDate: List<FerryScheduleDateItem>?
    
    var currentDay = 0
    var updatedAt = Date()
    
    var displayedSailing: FerrySailingsItem?
    var displayedTimes = List<FerryDepartureTimeItem>()
    
    var dayData = TimeUtils.nextSevenDaysStrings(Date())
    
    fileprivate var timer: Timer?
    
    var showConnectionAlert = true
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var departuresHeader: UIView!
        
    deinit {
        displayedSailing = nil
        sailingSpaces = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let sailingsByDateValue = sailingsByDate {
            if let firstSailingDateValue = sailingsByDateValue.first {
                dayData = TimeUtils.nextSevenDaysStrings(firstSailingDateValue.date)
            }
        }

        dateButton.layer.cornerRadius = 8.0
        dateButton.setTitle(dayData[0], for: UIControlState())
        dateButton.accessibilityHint = "double tap to change sailing day"
        
        setDisplayedSailing(0)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteTimesViewController.refreshAction(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: "loading sailing spaces")

        activityIndicator.color = UIColor.gray
        activityIndicator.startAnimating()
        
        tableView.addSubview(refreshControl)
        
        timer = Timer.scheduledTimer(timeInterval: TimeUtils.spacesUpdateTime, target: self, selector: #selector(RouteTimesViewController.spacesTimerTask), userInfo: nil, repeats: true)
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Ferries/Schedules/Sailings/Departures")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func spacesTimerTask(_ timer:Timer) {
        refresh()
    }
    
    func refreshAction(_ refreshControl: UIRefreshControl) {
        showConnectionAlert = true
        refresh()
    }
    
    func refresh() {
        if (currentDay == 0) && (displayedSailing != nil){
            let departingId = displayedSailing!.departingTerminalId
            let arrivingId = displayedSailing!.arrivingTerminalId
        
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
                SailingSpacesStore.getSailingSpacesForTerminal(departingId, arrivingId: arrivingId, completion: { data, error in
                    if let validData = data {
                        DispatchQueue.main.async { [weak self] in
                            if let selfValue = self{
                                selfValue.sailingSpaces = validData
                                selfValue.updatedAt = Date()
                                selfValue.tableView.reloadData()
                                selfValue.refreshControl.endRefreshing()
                                selfValue.activityIndicator.stopAnimating()
                                selfValue.activityIndicator.isHidden = true
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            if let selfValue = self{
                                selfValue.refreshControl.endRefreshing()
                                selfValue.activityIndicator.stopAnimating()
                                selfValue.activityIndicator.isHidden = true
                                if (selfValue.showConnectionAlert){
                                    selfValue.showConnectionAlert = false
                                    selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                                }
                            }
                        }
                    }
                })
            }
        }else{
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    @IBAction func selectAccountAction(_ sender: UIButton) {
        performSegue(withIdentifier: segueDepartureDaySelectionViewController, sender: self)
    }
    
    func daySelected(_ index: Int) {
        currentDay = index
        dateButton.setTitle(dayData[currentDay], for: UIControlState())
        setDisplayedSailing(currentDay)
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
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: departureCellIdentifier) as! DeparturesCustomCell
        
        // Check if sailing space information is avaliable. If so change prototype cell.
        if let sailingSpacesValue = sailingSpaces{
            for spaceItem: SailingSpacesItem in sailingSpacesValue {
                if displayedTimes[indexPath.row].departingTime == spaceItem.date {
                    cell = tableView.dequeueReusableCell(withIdentifier: departuresSailingSpacesCellIdentifier) as! DeparturesCustomCell
                    cell.sailingSpaces.isHidden = false
                    cell.sailingSpaces.text = String(spaceItem.remainingSpaces) + " Drive-up Spaces"
                    cell.avaliableSpacesBar.isHidden = false
                    
                    cell.avaliableSpacesBar.progress = spaceItem.percentAvaliable
                    
                    cell.avaliableSpacesBar.transform = UIProgressView().transform
                    cell.avaliableSpacesBar.transform = cell.avaliableSpacesBar.transform.scaledBy(x: 1, y: 3)
                    
                    cell.spacesDisclaimer.isHidden = false
                    cell.updated.text = "Drive-up spaces updated " + TimeUtils.timeAgoSinceDate(date: updatedAt, numericDates: true)
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
            cell.arrivingTime.accessibilityLabel = "not available"
        }
        
        var annotationsString = ""
        
        for indexObj in displayedTimes[indexPath.row].annotationIndexes{
            annotationsString += displayedSailing!.annotations[indexObj.index].message + " "
        }
        
        if (annotationsString != ""){
            let htmlStyleString = "<style>body{font-family: '\(cell.annotations.font.fontName)'; font-size:\(cell.annotations.font.pointSize)px;}</style>"
            let attrAnnotationsStr = try! NSMutableAttributedString(
                data: (htmlStyleString + annotationsString).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!],
                documentAttributes: nil)
            cell.annotations.isHidden = false
            cell.annotations.attributedText = attrAnnotationsStr
        }else {
            cell.annotations.attributedText = nil
            cell.annotations.text = nil
        }
        
        // Accessibility Setup
        cell.accessibilityLabel = "departing " + cell.departingTime.text! + ". arriving " + cell.arrivingTime.accessibilityLabel! + ". "
        
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
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueDepartureDaySelectionViewController {
            let destinationViewController = segue.destination as! DepartureDaySelectionViewController
            destinationViewController.my_parent = self
            destinationViewController.menu_options = dayData
            destinationViewController.selectedIndex = currentDay
        }
    }
    
    // MARK: Helper functions
    fileprivate func setDisplayedSailing(_ day: Int){
        
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
                if (time.departingTime.compare(NSDate() as Date) == .orderedDescending) {
                    displayedTimes.append(time)
                }
            }
        }
    }
}
