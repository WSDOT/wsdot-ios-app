//
//  VesselWatchSettings.swift
//  WSDOT
//
//  Copyright (c) 2019 Washington State Department of Transportation
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

class VesselWatchSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let mapStyleCellIdentifier = "MapStyleCell"
    let cellIdentifier = "SettingCell"
    let legendCellIdentifier = "LegendCell"
    
    var my_parent: VesselWatchViewController? = nil
        
    var menu_options: [String] = []
    var menu_icon_names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Traffic Layer", "Terminals", "Cameras", "Vessels", "Labels"]
        
        menu_icon_names = ["","icHomeTraffic", "terminal", "camera_icon", "ferry0", "label"]
        
        self.view.backgroundColor = ThemeManager.currentTheme().mainColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "VesselWatchMapOptions")
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
        return menu_options.count + 1 // for the legend and map style cell
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

        if menu_icon_names.indices.contains(indexPath.row) {
            cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        }
        
        switch(menu_options[indexPath.row-1]){
            
        case menu_options[0]:
            let ferryTrafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTrafficLayer)
            if let ferryTrafficLayerVisible = ferryTrafficLayerPref {
                if (ferryTrafficLayerVisible == "on") {
                    cell.settingSwitch.isOn = true
                } else {
                    cell.settingSwitch.isOn = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(VesselWatchSettingsViewController.changeFerryTrafficLayerPref(_:)), for: .valueChanged)
            cell.settingSwitch.isHidden = false
            cell.selectionStyle = .none
            cell.favoriteImageView.isHidden = true
            cell.infoButton.isHidden = true
            break
            
        case menu_options[1]:
            let ferryTerminalLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTerminalLayer)
            if let ferryTerminalLayerVisible = ferryTerminalLayerPref {
                if (ferryTerminalLayerVisible == "on") {
                    cell.settingSwitch.isOn = true
                } else {
                    cell.settingSwitch.isOn = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(VesselWatchSettingsViewController.changeFerryTerminalLayerPref(_:)), for: .valueChanged)
            cell.settingSwitch.isHidden = false
            cell.selectionStyle = .none
            cell.favoriteImageView.isHidden = true
            cell.infoButton.isHidden = true
            break
            
        case menu_options[2]:
            let ferryCameraLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryCameraLayer)
            if let ferryCameraLayerVisible = ferryCameraLayerPref {
                if (ferryCameraLayerVisible == "on") {
                    cell.settingSwitch.isOn = true
                } else {
                    cell.settingSwitch.isOn = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(VesselWatchSettingsViewController.changeFerryCameraLayerPref(_:)), for: .valueChanged)
            cell.settingSwitch.isHidden = false
            cell.selectionStyle = .none
            cell.favoriteImageView.isHidden = true
            cell.infoButton.isHidden = true
            break
        
        case menu_options[3]:
            let ferryVesselLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryVesselLayer)
            if let ferryVesselLayerVisible = ferryVesselLayerPref {
                if (ferryVesselLayerVisible == "on") {
                    cell.settingSwitch.isOn = true
                } else {
                    cell.settingSwitch.isOn = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(VesselWatchSettingsViewController.changeFerryVesselLayerPref(_:)), for: .valueChanged)
            cell.settingSwitch.isHidden = false
            cell.selectionStyle = .none
            cell.favoriteImageView.isHidden = true
            cell.infoButton.isHidden = true
            break
            
        case menu_options[4]:
            let ferryLabelLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryLabelLayer)
            if let ferryLabelLayerVisible = ferryLabelLayerPref {
                if (ferryLabelLayerVisible == "on") {
                    cell.settingSwitch.isOn = true
                } else {
                    cell.settingSwitch.isOn = false
                }
            }
            cell.settingSwitch.addTarget(self, action: #selector(VesselWatchSettingsViewController.changeFerryLabelLayerPref(_:)), for: .valueChanged)
            cell.settingSwitch.isHidden = false
            cell.selectionStyle = .none
            cell.favoriteImageView.isHidden = true
            cell.infoButton.isHidden = true
            break
            
        default: break
        }
        return cell
    } else { // Legend Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: legendCellIdentifier) as! CameraImageCustomCell
        cell.CameraImage.image = UIImage(named: "trafficMapKey")
        cell.sizeToFit()
        cell.isHidden = true
        return cell
        
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
    
    @objc func changeFerryTrafficLayerPref(_ sender: UISwitch){
        let trafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTrafficLayer)
        if let trafficLayerVisible = trafficLayerPref {
            if (trafficLayerVisible == "on") {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Hide Traffic Layer")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryTrafficLayer)
                my_parent?.ferryTrafficLayer()
                
            } else {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Show Traffic Layer")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryTrafficLayer)
                my_parent?.ferryTrafficLayer()

            }
        }
    }
    
    @objc func changeFerryVesselLayerPref(_ sender: UISwitch){
        let ferryVesselLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryVesselLayer)
        if let ferryVesselLayerVisible = ferryVesselLayerPref {
            if (ferryVesselLayerVisible == "on") {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Hide Vessel Layer")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryVesselLayer)
                my_parent!.removeVessels()
                
            } else {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Show Vessel Layer")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryVesselLayer)
                my_parent!.drawVessels()

            }
        }
    }
    
    @objc func changeFerryLabelLayerPref(_ sender: UISwitch){
        let ferryLabelLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryLabelLayer)
        if let ferryLabelLayerVisible = ferryLabelLayerPref {
            if (ferryLabelLayerVisible == "on") {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Hide Label Layer")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryLabelLayer)
                my_parent!.removeLabels()
                
            } else {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Show Label Layer")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryLabelLayer)
                my_parent!.drawLabels()

            }
        }
    }
    
    
    @objc func changeFerryTerminalLayerPref(_ sender: UISwitch){
        let ferryTerminalLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTerminalLayer)
        if let ferryTerminalLayerVisible = ferryTerminalLayerPref {
            if (ferryTerminalLayerVisible == "on") {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Hide Terminal Layer")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryTerminalLayer)
                my_parent!.removeTerminals()
                
            } else {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Show Terminal Layer")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryTerminalLayer)
                my_parent!.drawTerminals()

            }
        }
    }
    
    @objc func changeFerryCameraLayerPref(_ sender: UISwitch){
        let ferryCameraLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryCameraLayer)
        if let ferryCameraLayerVisible = ferryCameraLayerPref {
            if (ferryCameraLayerVisible == "on") {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Hide Camera Layer")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryCameraLayer)
                my_parent!.removeCameras()
                
            } else {
                MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Show Camera Layer")
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryCameraLayer)
                my_parent!.drawCameras()

            }
        }
    }
}
