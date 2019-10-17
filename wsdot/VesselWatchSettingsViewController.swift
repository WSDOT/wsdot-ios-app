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
    
    var my_parent: VesselWatchViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

}
