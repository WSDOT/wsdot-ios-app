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

import UIKit

class TrafficMapSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let mapStyleCellIdentifier = "MapStyleCell"
    let cellIdentifier = "SettingCell"
    let legendCellIdentifier = "LegendCell"
    
    var my_parent: TrafficMapViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Show Highway Alerts",
                        "Show Rest Areas",
                        "Show JBLM",
                        "Cluster Camera Markers",
                        "Favorite Current Map Location"]

        self.view.backgroundColor = ThemeManager.currentTheme().mainColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TrafficMapOptions")
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count + 2 // for the legend and map style cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: mapStyleCellIdentifier) as! MapStyleCell
        
            let mapStylePref = UserDefaults.standard.string(forKey: UserDefaultsKeys.mapStyle)
            
            if let mapStyle = mapStylePref {
                if (mapStyle == "system") {
                    cell.mapSettingControl.selectedSegmentIndex = 0
                } else if (mapStyle == "light"){
                    cell.mapSettingControl.selectedSegmentIndex = 1
                } else if (mapStyle == "dark"){
                    cell.mapSettingControl.selectedSegmentIndex = 2
                }
            }
        
            cell.mapSettingControl.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeMapStylePref(_:)), for: .valueChanged)
        
            return cell
        
        } else if indexPath.row < 6 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SettingsCell
            
            // Configure Cell
            cell.settingLabel.text = menu_options[indexPath.row-1]
            
            switch(menu_options[indexPath.row-1]){
                
            case menu_options[0]:
                let alertsPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.alerts)
                if let alertsVisible = alertsPref {
                    if (alertsVisible == "on") {
                        cell.settingSwitch.isOn = true
                    } else {
                        cell.settingSwitch.isOn = false
                    }
                }
                
                cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeAlertsPref(_:)), for: .valueChanged)
                cell.settingSwitch.isHidden = false
                cell.selectionStyle = .none
                cell.favoriteImageView.isHidden = true
                cell.infoButton.isHidden = true
                break
            case menu_options[1]:
                let restAreaPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.restAreas)
                if let restAreaVisible = restAreaPref {
                    if (restAreaVisible == "on") {
                        cell.settingSwitch.isOn = true
                    } else {
                        cell.settingSwitch.isOn = false
                    }
                }
                
                cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeRestAreaPref(_:)), for: .valueChanged)
                cell.settingSwitch.isHidden = false
                cell.selectionStyle = .none
                cell.favoriteImageView.isHidden = true
                cell.infoButton.isHidden = true
                break
            case menu_options[2]:
                let jblmPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.jblmCallout)
                if let jblmVisible = jblmPref {
                    if (jblmVisible == "on") {
                        cell.settingSwitch.isOn = true
                    } else {
                        cell.settingSwitch.isOn = false
                    }
                }
                cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeJBLMPref(_:)), for: .valueChanged)
                cell.settingSwitch.isHidden = false
                cell.selectionStyle = .none
                cell.favoriteImageView.isHidden = true
                cell.infoButton.isHidden = true
                break
            case menu_options[3]:
                let clusterPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.shouldCluster)
                if let clusterVisible = clusterPref {
                    if (clusterVisible == "on") {
                        cell.settingSwitch.isOn = true
                    } else {
                        cell.settingSwitch.isOn = false
                    }
                }
                cell.settingSwitch.addTarget(self, action: #selector(TrafficMapSettingsViewController.changeClusterPref(_:)), for: .valueChanged)
                cell.settingSwitch.isHidden = false
                cell.selectionStyle = .none
                cell.favoriteImageView.isHidden = true
                cell.infoButton.isHidden = false
                cell.infoButton.addTarget(self, action: #selector(TrafficMapSettingsViewController.clusterInfoAlert(_:)), for: .touchUpInside)
                break
            case menu_options[4]:
                cell.selectionStyle = .blue
                cell.settingSwitch.isHidden = true
                cell.favoriteImageView.isHidden = false
                cell.infoButton.isHidden = true
                break
            default: break
            }
            return cell
        } else { // Legend Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: legendCellIdentifier) as! CameraImageCustomCell
            cell.CameraImage.image = UIImage(named: "trafficMapKey")
            cell.sizeToFit()
            return cell
        }
        
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case 5:
            favoriteLocationAction()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func favoriteLocationAction(){
        self.dismiss(animated: true) {
            self.my_parent!.saveCurrentLocation()
        }
    }
    
    // MARK: Prefrence functions
    
    @objc func changeMapStylePref(_ sender: UISegmentedControl){
    
        switch sender.selectedSegmentIndex {
            case 0:
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Map Style System")
                UserDefaults.standard.set("system", forKey: UserDefaultsKeys.mapStyle)
                break
            case 1:
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Map Style Light")
                 UserDefaults.standard.set("light", forKey: UserDefaultsKeys.mapStyle)
                break
            case 2:
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Map Style Dark")
                UserDefaults.standard.set("dark", forKey: UserDefaultsKeys.mapStyle)
                break
            default:
                break
        }
            
        my_parent!.resetMapStyle()

        
    }

    @objc func changeClusterPref(_ sender: UISwitch){
        let clusterPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.shouldCluster)
        if let clusterVisible = clusterPref {
            if (clusterVisible == "on") {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Camera Clustering Off")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.shouldCluster)
            } else {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Camera Clustering On")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.shouldCluster)
            }
            my_parent!.resetMapCamera()
        }
    }
    
    @objc func changeAlertsPref(_ sender: UISwitch){
        let alertsPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.alerts)
        if let alertsVisible = alertsPref {
            if (alertsVisible == "on") {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Hide Alerts")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.alerts)
                my_parent!.removeAlerts()
            } else {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Show Alerts")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.alerts)
                my_parent!.drawAlerts()
            }
        }
    }
    
    @objc func changeRestAreaPref(_ sender: UISwitch){
        let restAreaPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.restAreas)
        if let restAreaVisible = restAreaPref {
            if (restAreaVisible == "on") {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Hide Rest Areas")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.restAreas)
                my_parent!.removeRestAreas()
            } else {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Show Rest Areas")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.restAreas)
                my_parent!.drawRestArea()
            }
        }
    }
    
    @objc func changeJBLMPref(_ sender: UISwitch){
        let jblmPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.jblmCallout)
        if let jblmVisible = jblmPref {
            if (jblmVisible == "on") {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Hide JBLM")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.jblmCallout)
                my_parent!.removeJBLM()
            } else {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Show JBLM")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.jblmCallout)
                my_parent!.drawJBLM()
            }
        }
    }
    
    @objc func clusterInfoAlert(_ sender: UIButton){
        self.present(AlertMessages.getAlert("Camera Marker Clustering", message: "By turning clustering on, large numbers of camera markers will gather together in clusters at low zoom levels. When viewing the map at a high zoom level, individual camera markers will show on the map.", confirm: "OK"), animated: true, completion: nil)
    }

}
