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

    @IBOutlet weak var dateTextField: PickerTextField!
    var routeItem : FerriesRouteScheduleItem? = nil
    var departingTerminal : String? = nil
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var pickerData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = departingTerminal

        bannerView.adUnitID = "ad_string"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        pickerData = TimeUtils.nextSevenDaysStrings()
        
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
            
        
        
        
            break;
        case 1: // Camertas
        
        
        
        
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
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        dateTextField.text = pickerData[row]
    }
    
    func donePicker() {
        dateTextField.resignFirstResponder()
        
        // TODO: load new data for current date
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // TODO
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        return cell
    }
}
