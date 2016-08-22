//
//  TrafficMapLayersSettings.swift
//  WSDOT
//
//  Created by Logan Sims on 8/19/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class TrafficMapSettingsViewController: UIViewController {

    let cellIdentifier = "SettingCell"
    
    var parent: TrafficMapViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Show Traffic Alert Markers",
                        "Show Rest Area Markers",
                        "Favorite Current Location"]
        
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! SettingsCell
        
        // Configure Cell
        cell.settingLabel.text = menu_options[indexPath.row]
        
        switch(menu_options[indexPath.row]){
            
        case menu_options[0]:
            let alertsPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.alerts)
            if let alertsVisible = alertsPref {
                if (alertsVisible == "on") {
                    cell.settingSwitch.on = true
                } else {
                    cell.settingSwitch.on = false
                }
            } else { // set default value
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.alerts)
                cell.settingSwitch.on = true
            }
            
            cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeAlertsPref(_:)), forControlEvents: .ValueChanged)
            cell.settingSwitch.hidden = false
            cell.selectionStyle = .None
            break
        case menu_options[1]:
            let restAreaPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.restAreas)
            if let restAreaVisible = restAreaPref {
                if (restAreaVisible == "on") {
                    cell.settingSwitch.on = true
                } else {
                    cell.settingSwitch.on = false
                }
            }
            
            cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeRestAreaPref(_:)), forControlEvents: .ValueChanged)
            cell.settingSwitch.hidden = false
            cell.selectionStyle = .None
            break
        case menu_options[2]:
            cell.selectionStyle = .Blue
            cell.settingSwitch.hidden = true
            break
        default: break
            
        }
    
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 2:
            favoriteLocation()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func favoriteLocation(){
        
        
        
    }
    
    func changeAlertsPref(sender: UISwitch){
        let alertsPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.alerts)
        if let alertsVisible = alertsPref {
            if (alertsVisible == "on") {
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.alerts)
                print("alert pref off")
                //parent!.removeCameras()
            } else {
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.alerts)
                print("alert pref on")
                //parent!.drawCameras()
            }
        }
    }
    
    func changeRestAreaPref(sender: UISwitch){
        let restAreaPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.restAreas)
        if let restAreaVisible = restAreaPref {
            if (restAreaVisible == "on") {
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.restAreas)
                parent!.removeRestAreas()
            } else {
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.restAreas)
                parent!.drawRestArea()
            }
        }
    }
}
