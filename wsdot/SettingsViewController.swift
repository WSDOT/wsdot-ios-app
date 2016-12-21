//
//  SettingsViewController.swift
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
import FirebaseMessaging

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "NotificationCell"
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Emergency Notifications"]

        // Set defualt values
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.emergencyNotifications) == nil){
            UserDefaults.standard.set("off", forKey: UserDefaultsKeys.emergencyNotifications)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Settings")
    }
    

    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
            case 0:
                return "Notifications"
            default:
                return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row){
        
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NotificationCell
                let emergencyNotificationsPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.emergencyNotifications)
                if let switchValue = emergencyNotificationsPref {
                    if (switchValue == "on") {
                        cell.settingSwitch.isOn = true
                    } else {
                        cell.settingSwitch.isOn = false
                    }
                }
                
                cell.settingSwitch.addTarget(self, action: #selector(SettingsViewController.changeEmergencyNotificationPref(_:)), for: .valueChanged)
                cell.settingSwitch.isHidden = false
                cell.selectionStyle = .none
                
                cell.titleLabel.text = menu_options[0]
                cell.descriptionLabel.text = "Receive alerts about major road way closures and incidents"
                
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! NotificationCell
        
        }
        
    }
    
    // MARK: Prefrence functions
    func changeEmergencyNotificationPref(_ sender: UISwitch){
        let emergencyNotificationsPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.emergencyNotifications)
        if let value = emergencyNotificationsPref {
            if (value == "on") {
                GoogleAnalytics.event(category: "Settings", action: "UIAction", label: "Unsubscribe from Emergency Alerts")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.emergencyNotifications)
                FIRMessaging.messaging().unsubscribe(fromTopic: "/topics/test")
            } else {
                GoogleAnalytics.event(category: "Settings", action: "UIAction", label: "Subscribe to Emergency Alerts")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.emergencyNotifications)
                FIRMessaging.messaging().subscribe(toTopic: "/topics/test")
            }
        }
    }
    
}
