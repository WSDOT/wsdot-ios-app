//
//  RouteDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit
import GoogleMobileAds

class RouteDeparturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let departuresSailingSpacesCellIdentifier = "RouteDeparturesSailingSpaces"
    let departureCellIdentifier = "RouteDeparture"
    let camerasCellIdentifier = "RouteCameras"

    var sailingSpaces : [SailingSpacesItem]?
    var cameras : [CameraItem]? = nil

    // set by previous view controller
    var currentSailing : (String, String) = ("", "")
    var sailingsByDate : [FerriesScheduleDateItem]? = nil
    
    var updatedAt: Int64 = 0
    var segment = 0
    var currentDay = 0
    
    var displayedSailing: SailingsItem? = nil
    var pickerData = [String]()
    
    let refreshControl = UIRefreshControl()
    let refreshControlA = UIRefreshControl()
    
    @IBOutlet weak var dateTextField: PickerTextField!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var departuresHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentSailing.0 + " to " + currentSailing.1

        setDisplayedSailing()

        tableView.rowHeight = UITableViewAutomaticDimension

        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteDeparturesViewController.refresh(_:)), forControlEvents: .ValueChanged)
        // TODO: add refresh cameras


        refreshControl.attributedTitle = NSAttributedString.init(string: "times")
        refreshControlA.attributedTitle = NSAttributedString.init(string: "Cameras")

        tableView.addSubview(refreshControl)
        //tableView.addSubview(refreshControlA)

        // Ad Banner
        bannerView.adUnitID = "ad_string"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
        // Set up day of week picker
        let picker: UIPickerView
        picker = UIPickerView()
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        pickerData = TimeUtils.nextSevenDaysStrings(TimeUtils.parseJSONDate((sailingsByDate![0].date)))
        pickerData = Array(pickerData[0...sailingsByDate!.count - 1])
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RouteDeparturesViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        dateTextField.text = pickerData[0]
        dateTextField.inputView = picker
        dateTextField.inputAccessoryView = toolBar
        
        refreshControlA.hidden = true
        refreshControlA.beginRefreshing()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            CamerasStore.getCameras("Ferries", completion:  { data, error in
                if (error == nil){
                    if let selfValue = self{
                        selfValue.cameras = data
                        selfValue.refreshControlA.endRefreshing()
                        selfValue.tableView.reloadData()
                        print("Cameras Loaded")
                    }
                }else{
                    print("RouteDepartureViewContorller: Error getting cameras")
                }
            })
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        refresh(self.refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        print("refeshing")
        if (currentDay == 0){
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
                SailingSpacesStore.getSailingSpacesForTerminal((self!.displayedSailing?.departingTerminalId)!, arrivingId: (self!.displayedSailing?.arrivingTerminalId)!, completion: { data, error in
                    if let validData = data {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            if let selfValue = self{
                                selfValue.sailingSpaces = validData
                                selfValue.tableView.reloadData()
                                refreshControl.endRefreshing()
                                selfValue.updatedAt = TimeUtils.currentTime
                                print("Done refreshing")
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            if let selfValue = self{
                                refreshControl.endRefreshing()
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
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        // TODO: Change Data Source for list and refesh
        switch sender.selectedSegmentIndex
        {
        case 0: // Departure times
            dateTextField.hidden = false
            departuresHeader.hidden = false
            
            refreshControl.addTarget(self, action: #selector(RouteDeparturesViewController.refresh(_:)), forControlEvents: .ValueChanged)
            
            refreshControlA.removeFromSuperview()
            tableView.addSubview(refreshControl)
            
            segment = 0
            tableView.reloadData()
            break;
        case 1: // Cameras
            dateTextField.hidden = true
            departuresHeader.hidden = true
            
            refreshControl.removeTarget(self, action: #selector(RouteDeparturesViewController.refresh(_:)), forControlEvents: .ValueChanged)
            
            refreshControl.removeFromSuperview()
            tableView.addSubview(refreshControlA)
            
            tableView.
            
            segment = 1
            tableView.reloadData()
            break;
        default:
            break;
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
        setDisplayedSailing()
        self.tableView.reloadData()
    }
    
    // MARK: -
    // MARK: Table View Delegate & data source methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segment{
        case 0: // Departure times
            return displayedSailing!.times.count
            
        case 1: // Cameras
            return cameras!.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch segment{
        case 0: // Departure times
            
            var cell = tableView.dequeueReusableCellWithIdentifier(departureCellIdentifier) as! DeparturesCustomCell
            
            
            // Check if sailing space informatino is avaliable. If so change prototype cell.
            let times = displayedSailing!.times
            if let sailingSpacesValue = sailingSpaces{
                for spaceItem: SailingSpacesItem in sailingSpacesValue {
                    if times[indexPath.row].departingTime == spaceItem.Date {
                        cell = tableView.dequeueReusableCellWithIdentifier(departuresSailingSpacesCellIdentifier) as! DeparturesCustomCell
                        cell.sailingSpaces.hidden = false
                        cell.sailingSpaces.text = String(spaceItem.remainingSpaces) + " Drive-up spaces"
                        cell.avaliableSpacesBar.hidden = false
                        cell.avaliableSpacesBar.progress = spaceItem.percentAvaliable
                        cell.spacesDisclaimer.hidden = false
                        cell.spacesDisclaimer.sizeToFit()
                        cell.updated.text = TimeUtils.timeSinceDate(updatedAt, numericDates: true)
                    }
                }
            }
            
            let departingTimeDate = NSDate(timeIntervalSince1970: Double(TimeUtils.parseJSONDate(times[indexPath.row].departingTime) / 1000))
            let displayDepartingTime = TimeUtils.getTimeOfDay(departingTimeDate)
            
            cell.departingTime.text = displayDepartingTime
            
            if let arrivingTime = times[indexPath.row].arrivingTime {
                let arrivingTimeDate = NSDate(timeIntervalSince1970: Double(TimeUtils.parseJSONDate(arrivingTime) / 1000))
                let displayArrivingTime = TimeUtils.getTimeOfDay(arrivingTimeDate)
                cell.arrivingTime.text = displayArrivingTime
            } else {
                cell.arrivingTime.text = ""
            }
            
            var annotaions = ""
            
            for index in times[indexPath.row].annotationIndexes{
                annotaions += (displayedSailing?.annotations[index])! + " "
            }
            
            if (annotaions != ""){
                
                let htmlStyleString = "<style>body{font-family: '\(cell.annotations.font.fontName)'; font-size:\(cell.annotations.font.pointSize)px;}</style>"
                let attrAnnotationsStr = try! NSMutableAttributedString(
                    data: (htmlStyleString + annotaions).dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!],
                    documentAttributes: nil)
                cell.annotations.hidden = false
                cell.annotations.attributedText = attrAnnotationsStr
                cell.annotations.sizeToFit()
                
            }else {
                cell.annotations.text = annotaions
            }
            
            return cell
            
        case 1: // Cameras
            let cell = tableView.dequeueReusableCellWithIdentifier(camerasCellIdentifier) as! CameraImageCustomCell
            
            if let url = NSURL(string: cameras![indexPath.row].url) {
                if let data = NSData(contentsOfURL: url) {
                    cell.CameraImage.image = UIImage(data: data)
                }
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(departuresSailingSpacesCellIdentifier) as! DeparturesCustomCell
            return cell
            
        }
    }
    
    // MARK: -
    // MARK: Helper functions
    private func setDisplayedSailing(){

        // get sailings for selected day
        let sailings = sailingsByDate![currentDay].sailings
        
        // get sailings for current route
        for sailing in sailings as [SailingsItem] {

            if ((sailing.departingTerminalName == currentSailing.0) && (sailing.arrivingTerminalName == currentSailing.1)) {
                displayedSailing = sailing
            }
        }
        
        // remove past sailings
        var trimmedTimes = [SailingTimeItem]()
        
        for time in displayedSailing!.times {
            if TimeUtils.parseJSONDate(time.departingTime) > TimeUtils.currentTime{
                trimmedTimes.append(time)
            }
        }
        displayedSailing!.times = trimmedTimes
    }
}
