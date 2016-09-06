//
//  RouteTimesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit
import RealmSwift

class RouteTimesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let departuresSailingSpacesCellIdentifier = "RouteDeparturesSailingSpaces"
    let departureCellIdentifier = "RouteDeparture"
    
    var sailingSpaces : [SailingSpacesItem]?
    
    // Set by parent view
    var currentSailing = FerryTerminalPairItem()
    var sailingsByDate = List<FerryScheduleDateItem>()
    
    var currentDay = 0
    var updatedAt = NSDate()
    
    var displayedSailing = FerrySailingsItem()
    var displayedTimes = List<FerryDepartureTimeItem>()
    
    var pickerData = [String]()
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var dateTextField: PickerTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var departuresHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDisplayedSailing(0)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteTimesViewController.refresh(_:)), forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: "loading sailing spaces")
        
        tableView.addSubview(refreshControl)
        
        // Set up day of week picker
        let picker: UIPickerView
        picker = UIPickerView()
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        pickerData = TimeUtils.nextSevenDaysStrings(sailingsByDate[0].date)
        pickerData = Array(pickerData[0...sailingsByDate.count - 1])
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RouteTimesViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        dateTextField.text = pickerData[0]
        dateTextField.inputView = picker
        dateTextField.inputAccessoryView = toolBar
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        refresh(self.refreshControl)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Ferries/Schedules/Sailings/Departures")
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        if (currentDay == 0){
            let departingId = displayedSailing.departingTerminalId
            let arrivingId = displayedSailing.arrivingTerminalId
        
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
                SailingSpacesStore.getSailingSpacesForTerminal(departingId, arrivingId: arrivingId, completion: { data, error in
                    if let validData = data {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            if let selfValue = self{
                                selfValue.sailingSpaces = validData
                                selfValue.updatedAt = NSDate()
                                selfValue.tableView.reloadData()
                                selfValue.refreshControl.endRefreshing()
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            if let selfValue = self{
                                selfValue.refreshControl.endRefreshing()
                                selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                                
                            }
                        }
                    }
                    
                })
            }
        }else{
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: -
    // MARK: Picker View Delegate & data source methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentDay = row
    }
    
    func donePicker() {
        dateTextField.text = pickerData[currentDay]
        dateTextField.resignFirstResponder()
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
                    cell.sailingSpaces.text = String(spaceItem.remainingSpaces) + " Drive-up spaces"
                    cell.avaliableSpacesBar.hidden = false
                    cell.avaliableSpacesBar.progress = spaceItem.percentAvaliable
                    cell.spacesDisclaimer.hidden = false
                    cell.updated.text = TimeUtils.timeAgoSinceDate(updatedAt, numericDates: true)
                }
            }
        }
        
        let displayDepartingTime = TimeUtils.getTimeOfDay(displayedTimes[indexPath.row].departingTime)
        
        cell.departingTime.text = displayDepartingTime
        
        if let arrivingTime = displayedTimes[indexPath.row].arrivingTime {
            let displayArrivingTime = TimeUtils.getTimeOfDay(arrivingTime)
            cell.arrivingTime.text = displayArrivingTime
        } else {
            cell.arrivingTime.text = ""
        }
        
        var annotationsString = ""
        
        for indexObj in displayedTimes[indexPath.row].annotationIndexes{
            annotationsString += displayedSailing.annotations[indexObj.index].message + " "
        }
        
        if (annotationsString != ""){
            let htmlStyleString = "<style>body{font-family: '\(cell.annotations.font.fontName)'; font-size:\(cell.annotations.font.pointSize)px;}</style>"
            let attrAnnotationsStr = try! NSMutableAttributedString(
                data: (htmlStyleString + annotationsString).dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!],
                documentAttributes: nil)
            cell.annotations.hidden = false
            cell.annotations.attributedText = attrAnnotationsStr
            cell.annotations.text = nil
        }else {
            cell.annotations.attributedText = nil
            cell.annotations.text = annotationsString
        }
        
        return cell
    }
    
    // MARK: Helper functions
    private func setDisplayedSailing(day: Int){
        
        // get sailings for selected day
        let sailings = sailingsByDate[day].sailings
        
        // get sailings for current route
        for sailing in sailings {
            if ((sailing.departingTerminalName == currentSailing.aTerminalName) && (sailing.arrivingTerminalName == currentSailing.bTterminalName)) {
                displayedSailing = sailing
            }
        }
        
        displayedTimes.removeAll()
        
        // make list of displayable times
        for time in displayedSailing.times {
            if (time.departingTime.compare(NSDate()) == .OrderedDescending) {
                displayedTimes.append(time)
            }
        }
    }
}
