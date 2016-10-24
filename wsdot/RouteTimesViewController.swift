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
    var updatedAt = NSDate()
    
    var displayedSailing: FerrySailingsItem?
    var displayedTimes = List<FerryDepartureTimeItem>()
    
    var dayData = TimeUtils.nextSevenDaysStrings(NSDate())
    
    private var timer: NSTimer?
    
    var hasConnectionAlert = false
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
        dateButton.setTitle(dayData[0], forState: .Normal)
        dateButton.accessibilityHint = "double tap to change sailing day"
        
        setDisplayedSailing(0)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteTimesViewController.refresh(_:)), forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: "loading sailing spaces")

        activityIndicator.color = UIColor.grayColor()
        activityIndicator.startAnimating()
        
        tableView.addSubview(refreshControl)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(TimeUtils.spacesUpdateTime, target: self, selector: #selector(RouteTimesViewController.spacesTimerTask), userInfo: nil, repeats: true)
        refresh(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Ferries/Schedules/Sailings/Departures")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func spacesTimerTask(timer:NSTimer) {
        refresh(self.refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        if (currentDay == 0) && (displayedSailing != nil){
            let departingId = displayedSailing!.departingTerminalId
            let arrivingId = displayedSailing!.arrivingTerminalId
        
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
                SailingSpacesStore.getSailingSpacesForTerminal(departingId, arrivingId: arrivingId, completion: { data, error in
                    if let validData = data {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            if let selfValue = self{
                                selfValue.sailingSpaces = validData
                                selfValue.updatedAt = NSDate()
                                selfValue.tableView.reloadData()
                                selfValue.refreshControl.endRefreshing()
                                selfValue.activityIndicator.stopAnimating()
                                selfValue.activityIndicator.hidden = true
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            if let selfValue = self{
                                selfValue.refreshControl.endRefreshing()
                                selfValue.activityIndicator.stopAnimating()
                                selfValue.activityIndicator.hidden = true
                                if (!selfValue.hasConnectionAlert){
                                    selfValue.hasConnectionAlert = true
                                    selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                                }
                            }
                        }
                    }
                })
            }
        }else{
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }
    
    @IBAction func selectAccountAction(sender: UIButton) {
        performSegueWithIdentifier(segueDepartureDaySelectionViewController, sender: self)
    }
    
    func daySelected(index: Int) {
        currentDay = index
        dateButton.setTitle(dayData[currentDay], forState: .Normal)
        setDisplayedSailing(currentDay)
        self.tableView.reloadData()
    }
    
    // MARK: -
    // MARK: Table View Delegate & data source methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTimes.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(departureCellIdentifier) as! DeparturesCustomCell
        
        // Check if sailing space information is avaliable. If so change prototype cell.
        if let sailingSpacesValue = sailingSpaces{
            for spaceItem: SailingSpacesItem in sailingSpacesValue {
                if displayedTimes[indexPath.row].departingTime == spaceItem.date {
                    cell = tableView.dequeueReusableCellWithIdentifier(departuresSailingSpacesCellIdentifier) as! DeparturesCustomCell
                    cell.sailingSpaces.hidden = false
                    cell.sailingSpaces.text = String(spaceItem.remainingSpaces) + " Drive-up Spaces"
                    cell.avaliableSpacesBar.hidden = false
                    
                    cell.avaliableSpacesBar.progress = spaceItem.percentAvaliable
                    
                    cell.avaliableSpacesBar.transform = UIProgressView().transform
                    cell.avaliableSpacesBar.transform = CGAffineTransformScale(cell.avaliableSpacesBar.transform, 1, 3)
                    
                    
                    cell.spacesDisclaimer.hidden = false
                    cell.updated.text = "Drive-up spaces updated " + TimeUtils.timeAgoSinceDate(updatedAt, numericDates: true)
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
                data: (htmlStyleString + annotationsString).dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!],
                documentAttributes: nil)
            cell.annotations.hidden = false
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueDepartureDaySelectionViewController {
            let destinationViewController = segue.destinationViewController as! DepartureDaySelectionViewController
            destinationViewController.parent = self
            destinationViewController.menu_options = dayData
            destinationViewController.selectedIndex = currentDay
        }
    }
    
    // MARK: Helper functions
    private func setDisplayedSailing(day: Int){
        
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
                if (time.departingTime.compare(NSDate()) == .OrderedDescending) {
                    displayedTimes.append(time)
                }
            }
        }
    }
}
