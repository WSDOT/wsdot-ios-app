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
        
        menu_options = ["Show Camera Icons"]
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
        
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                cell.settingSwitch.on = true
            } else {
                cell.settingSwitch.on = false
            }
        }
        
        cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeCameraPref(_:)), forControlEvents: .ValueChanged)

        return cell
    }
    
    func changeCameraPref(sender: UISwitch){
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.vesselCameras)
                parent!.removeCameras()
            } else {
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.vesselCameras)
                parent!.drawCameras()
            }
        }
    }

}
