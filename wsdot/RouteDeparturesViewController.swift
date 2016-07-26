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
    
    let cellIdentifier = "RouteDepartures"

    // set by previous view controller
    var currentSailing : (String, String) = ("", "")
    var sailingsByDate : [FerriesScheduleDateItem]? = nil
    
    var segment = 0
    var currentDay = 0

    var displayedSailing: SailingsItem? = nil
    var pickerData = [String]()
    
    @IBOutlet weak var dateTextField: PickerTextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentSailing.0 + " to " + currentSailing.1

        setDisplayedSailing()

        tableView.rowHeight = UITableViewAutomaticDimension

        // Ad Banner
        bannerView.adUnitID = "ad_string"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
        // Set up day of week picker
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
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
        
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        // TODO: Change Data Source for list and refesh
        switch sender.selectedSegmentIndex
        {
        case 0: // Departure times
            dateTextField.hidden = false

        
        
            break;
        case 1: // Cameras
            dateTextField.hidden = true
        
        
        
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
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        currentDay = row
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        dateTextField.text = pickerData[row]
    }
    
    func donePicker() {
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
            return 0
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! DeparturesCustomCell
        
        let times = displayedSailing!.times
        
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
        
        let htmlStyleString = "<style>body{font-family: '\(cell.annotations.font.fontName)'; font-size:\(cell.annotations.font.pointSize)px;}</style>"
        let attrAnnotationsStr = try! NSMutableAttributedString(
            data: (htmlStyleString + annotaions).dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!],
            documentAttributes: nil)
        
        cell.annotations.attributedText = attrAnnotationsStr
        cell.annotations.sizeToFit()



        // TODO: Sailing Spaces
        cell.sailingSpaces.text = "Sample Text"

        cell.avaliableSpacesBar.progress = 0.5
        
        return cell
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
