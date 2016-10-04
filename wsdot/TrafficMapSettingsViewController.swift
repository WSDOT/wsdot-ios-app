//
//  TrafficMapLayersSettings.swift
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

class TrafficMapSettingsViewController: UIViewController {

    let cellIdentifier = "SettingCell"
    
    var parent: TrafficMapViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Show Highway Alerts",
                        "Show Rest Areas",
                        "Show JBLM",
                        "Cluster Camera Icons",
                        "Favorite Current Map Location"]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map/More")
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
    }
    
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
            }
            
            cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeAlertsPref(_:)), forControlEvents: .ValueChanged)
            cell.settingSwitch.hidden = false
            cell.selectionStyle = .None
            cell.favoriteImageView.hidden = true
            cell.infoButton.hidden = true
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
            cell.favoriteImageView.hidden = true
            cell.infoButton.hidden = true
            break
        case menu_options[2]:
            let jblmPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.jblmCallout)
            if let jblmVisible = jblmPref {
                if (jblmVisible == "on") {
                    cell.settingSwitch.on = true
                } else {
                    cell.settingSwitch.on = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeJBLMPref(_:)), forControlEvents: .ValueChanged)
            cell.settingSwitch.hidden = false
            cell.selectionStyle = .None
            cell.favoriteImageView.hidden = true
            cell.infoButton.hidden = true
            break
        case menu_options[3]:
            let clusterPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.shouldCluster)
            if let clusterVisible = clusterPref {
                if (clusterVisible == "on") {
                    cell.settingSwitch.on = true
                } else {
                    cell.settingSwitch.on = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeClusterPref(_:)), forControlEvents: .ValueChanged)
            cell.settingSwitch.hidden = false
            cell.selectionStyle = .None
            cell.favoriteImageView.hidden = true
            cell.infoButton.hidden = false
            cell.infoButton.addTarget(self, action: #selector(TrafficMapSettingsViewController.clusterInfoAlert(_:)), forControlEvents: .TouchUpInside)
            break
        case menu_options[4]:
            cell.selectionStyle = .Blue
            cell.settingSwitch.hidden = true
            cell.favoriteImageView.hidden = false
            cell.infoButton.hidden = true
            break
        default: break
            
        }
    
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 4:
            favoriteLocationAction()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func favoriteLocationAction(){
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
        parent!.saveCurrentLocation()
    }
    
    // MARK: Prefrence functions
    func changeClusterPref(sender: UISwitch){
        let clusterPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.shouldCluster)
        if let clusterVisible = clusterPref {
            if (clusterVisible == "on") {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Camera Clustering Off")
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.shouldCluster)
            } else {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Camera Clustering On")
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.shouldCluster)
            }
            parent!.resetMapCamera()
        }
    }
    
    func changeAlertsPref(sender: UISwitch){
        let alertsPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.alerts)
        if let alertsVisible = alertsPref {
            if (alertsVisible == "on") {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Hide Alerts")
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.alerts)
                parent!.removeAlerts()
            } else {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Show Alerts")
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.alerts)
                parent!.drawAlerts()
            }
        }
    }
    
    func changeRestAreaPref(sender: UISwitch){
        let restAreaPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.restAreas)
        if let restAreaVisible = restAreaPref {
            if (restAreaVisible == "on") {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Hide Rest Areas")
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.restAreas)
                parent!.removeRestAreas()
            } else {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Show Rest Areas")
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.restAreas)
                parent!.drawRestArea()
            }
        }
    }
    
    func changeJBLMPref(sender: UISwitch){
        let jblmPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.jblmCallout)
        if let jblmVisible = jblmPref {
            if (jblmVisible == "on") {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Hide JBLM")
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.jblmCallout)
                parent!.removeJBLM()
            } else {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Show JBLM")
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.jblmCallout)
                parent!.drawJBLM()
            }
        }
    }
    
    func clusterInfoAlert(sender: UIButton){
        self.presentViewController(AlertMessages.getAlert("Camera Icon Clustering", message: "Clustering camera icons can help remove clutter from the Traffic map and improve performace. Blue camera clusters can be tapped to zoom in on that cluster. When zoomed in enough clusters will turn green and can be tapped to view a list of all cameras in that cluster."), animated: true, completion: nil)
    }
}
