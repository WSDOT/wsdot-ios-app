//
//  AmtrakCascadesScheduleViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import CoreLocation

class AmtrakCascadesScheduleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate  {

    let locationManager = CLLocationManager()

    let segueAmtrakCascadesScheduleDetailsViewController = "AmtrakCascadesScheduleDetailsViewController"

    let stationItems = AmtrakCascadesStore.getStations()

    var usersLocation: CLLocation? = nil

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    private enum AmtrakPickerTags: Int {
        case Day = 0
        case Origin = 1
        case Destination = 2
    }
    
    var dayPickerData = [String]()
    var originPickerData = AmtrakCascadesStore.getOriginData()
    var destinationPickerData = AmtrakCascadesStore.getDestinationData()
    
    
    let dayPicker = UIPickerView()
    let originPicker = UIPickerView()
    let destPicker = UIPickerView()
    
    var currentDayIndex = 0
    var currentOriginIndex = 0
    var currentDestIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Find Schedules"
        
        submitButton.layer.cornerRadius = 8
        
        // Set up day of week picker
        dayPicker.tag = AmtrakPickerTags.Day.rawValue
        dayPicker.backgroundColor = .whiteColor()
        
        dayPicker.showsSelectionIndicator = true
        dayPicker.delegate = self
        dayPicker.dataSource = self
        
        dayPickerData = TimeUtils.nextSevenDaysStrings(NSDate())

        let dayToolBar = UIToolbar()
        dayToolBar.barStyle = UIBarStyle.Default
        dayToolBar.translucent = true
        dayToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        dayToolBar.sizeToFit()
        dayToolBar.userInteractionEnabled = true
        
        let doneDayButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AmtrakCascadesScheduleViewController.doneDayPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        dayToolBar.setItems([spaceButton, spaceButton, doneDayButton], animated: false)
        
        dayTextField.text = dayPickerData[0]
        dayTextField.inputView = dayPicker
        dayTextField.inputAccessoryView = dayToolBar
        
        // Set up origin picker
        originPicker.tag = AmtrakPickerTags.Origin.rawValue
        originPicker.backgroundColor = .whiteColor()
        
        originPicker.showsSelectionIndicator = true
        originPicker.delegate = self
        originPicker.dataSource = self
                
        let originToolBar = UIToolbar()
        originToolBar.barStyle = UIBarStyle.Default
        originToolBar.translucent = true
        originToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        originToolBar.sizeToFit()
        
        let doneOriginButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AmtrakCascadesScheduleViewController.doneOriginPicker))
        
        originToolBar.setItems([spaceButton, spaceButton, doneOriginButton], animated: false)
        
        originTextField.text = originPickerData[0]
        originTextField.inputView = originPicker
        originTextField.inputAccessoryView = originToolBar

        // Set up destination picker
        destPicker.tag = AmtrakPickerTags.Destination.rawValue
        destPicker.backgroundColor = .whiteColor()
        
        destPicker.showsSelectionIndicator = true
        destPicker.delegate = self
        destPicker.dataSource = self
                
        let destToolBar = UIToolbar()
        destToolBar.barStyle = UIBarStyle.Default
        destToolBar.translucent = true
        destToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        destToolBar.sizeToFit()
        
        let doneDestButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AmtrakCascadesScheduleViewController.doneDestinationPicker))
        
        destToolBar.setItems([spaceButton, spaceButton, doneDestButton], animated: false)
        
        destinationTextField.text = destinationPickerData[0]
        destinationTextField.inputView = destPicker
        destinationTextField.inputAccessoryView = destToolBar
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Amtrak Cascades/Schedules")
    }
    
    @IBAction func submitAction(sender: UIButton) {
        
        if AmtrakCascadesStore.stationIdsMap[originPickerData[currentOriginIndex]]! == AmtrakCascadesStore.stationIdsMap[destinationPickerData[currentDestIndex]]! {
            currentDestIndex = 0
        }
        
        performSegueWithIdentifier(segueAmtrakCascadesScheduleDetailsViewController, sender: self)
        
    }
    
    // MARK: Picker View Delegate & data source methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag){
        case AmtrakPickerTags.Day.rawValue:
            return dayPickerData.count
        case AmtrakPickerTags.Origin.rawValue:
            return originPickerData.count
        case AmtrakPickerTags.Destination.rawValue:
            return destinationPickerData.count
        default: return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag){
        case AmtrakPickerTags.Day.rawValue:
            return dayPickerData[row]
        case AmtrakPickerTags.Origin.rawValue:
            return originPickerData[row]
        case AmtrakPickerTags.Destination.rawValue:
            return destinationPickerData[row]
        default: return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(pickerView.tag){
        case AmtrakPickerTags.Day.rawValue:
            currentDayIndex = row
            dayTextField.text = dayPickerData[row]
            break
        case AmtrakPickerTags.Origin.rawValue:
            currentOriginIndex = row
            originTextField.text = originPickerData[row]
            break
        case AmtrakPickerTags.Destination.rawValue:
            currentDestIndex = row
            destinationTextField.text = destinationPickerData[row]
            break
        default: break
        }
    }
    
    func doneDayPicker() {
        dayTextField.resignFirstResponder()
        currentDayIndex = dayPicker.selectedRowInComponent(0)
        dayTextField.text = dayPickerData[currentDayIndex]
    }
    
    func doneOriginPicker() {
        originTextField.resignFirstResponder()
        currentOriginIndex = originPicker.selectedRowInComponent(0)
        originTextField.text = originPickerData[currentOriginIndex]
    }
    
    func doneDestinationPicker() {
        destinationTextField.resignFirstResponder()
        currentDestIndex = destPicker.selectedRowInComponent(0)
        destinationTextField.text = destinationPickerData[currentDestIndex]
    }
    
    // MARK: CLLocationManagerDelegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        usersLocation = manager.location
        
        let userLat: Double = usersLocation!.coordinate.latitude
        let userLon: Double = usersLocation!.coordinate.longitude
    
        var closest = (station: AmtrakCascadesStationItem(id: "", name: "", lat: 0.0, lon: 0.0), distance: Int.max)
        
        for station in stationItems {
    
            let distance = LatLonUtils.haversine(userLat, lonA: userLon, latB: station.lat, lonB: station.lon)
    
            if closest.1 > distance{
                closest.station = station
                closest.distance = distance
            }
        
        }
        
        let index = originPickerData.indexOf(closest.station.name)
        
        originTextField.text = originPickerData[index!]
        currentOriginIndex = index!
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //print("failed to get location")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    
    // MARK: Naviagtion
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueAmtrakCascadesScheduleDetailsViewController {
            let destinationViewController = segue.destinationViewController as! AmtrakCascadesScheduleDetailsViewController
            
            let interval = NSTimeInterval(60 * 60 * 24 * currentDayIndex)
        
            destinationViewController.date = NSDate().dateByAddingTimeInterval(interval)
            
            destinationViewController.originId = AmtrakCascadesStore.stationIdsMap[originPickerData[currentOriginIndex]]!
            
            destinationViewController.destId = AmtrakCascadesStore.stationIdsMap[destinationPickerData[currentDestIndex]]!
        
            if destinationViewController.destId == "N/A" {
                destinationViewController.title = "Departing " + originPickerData[currentOriginIndex]
            } else {
                destinationViewController.title = originPickerData[currentOriginIndex] + " to " + destinationPickerData[currentDestIndex]
            }
        
        }
    }
}