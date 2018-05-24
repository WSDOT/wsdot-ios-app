//
//  TrafficMapGoToViewController.swift
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

class TrafficMapGoToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "GoToCell"
    
    var my_parent: TrafficMapViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Bellingham",
                        "Chehalis",
                        "Hood Canal",
                        "Monroe",
                        "Mt Vernon",
                        "Olympia",
                        "Seattle",
                        "Snoqualmie Pass",
                        "Spokane",
                        "Stanwood",
                        "Sultan",
                        "Tacoma",
                        "Tri-Cities",
                        "Vancouver",
                        "Wenatchee",
                        "Yakima"]
    
        self.view.backgroundColor = ThemeManager.currentTheme().mainColor
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/GoTo Location")
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GoogleAnalytics.screenView(screenName: "/Traffic Map/GoTo Location/" + menu_options[indexPath.row])
        setGoToLocation(index: indexPath.row)
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
    func setGoToLocation(index: Int) {
        var lat = 0.0
        var long = 0.0
        var zoom = 0
        
        switch(index) {
        case 0:
            lat = 48.756302
            long = -122.46151
            zoom = 12 // Bellingham
            break
        case 1:
            lat = 46.635529
            long = -122.937698
            zoom = 11 // Chehalis
            break
        case 2:
            lat = 47.85268
            long = -122.628365
            zoom = 13 // Hood Canal
            break
        case 3:
            lat = 47.859476
            long = -121.972446
            zoom = 13 // Monroe
            break
        case 4:
            lat = 48.420657
            long = -122.334824
            zoom = 13 // Mt Vernon
            break
        case 5:
            lat = 47.021461
            long = -122.899933
            zoom = 13 // Olympia
            break
        case 6:
            lat = 47.5990
            long = -122.3350
            zoom = 12 // Seattle
            break
        case 7:
            lat = 47.404481
            long = -121.4232569
            zoom = 12 // Snoqualmie Pass
            break
        case 8:
            lat = 47.658566
            long = -117.425995
            zoom = 12 // Spokane
            break
        case 9:
            lat = 48.22959
            long = -122.34581
            zoom = 13 // Stanwood
            break
        case 10:
            lat = 47.86034
            long = -121.812286
            zoom = 13 // Sultan
            break
        case 11:
            lat = 47.206275
            long = -122.46254
            zoom = 12 // Tacoma
            break
        case 12:
            lat = 46.2503607
            long = -119.2063781
            zoom = 11 // Tri-Cities
            break
        case 13:
            lat = 45.639968
            long = -122.610512
            zoom = 11 // Vancouver
            break
        case 14:
            lat = 47.435867
            long = -120.309563
            zoom = 12 // Wenatchee
            break
        case 15:
            lat = 46.6063273
            long = -120.4886952
            zoom = 11 // Takima
            break
        default:
            break
        }
        
        UserDefaults.standard.set(lat, forKey: UserDefaultsKeys.mapLat)
        UserDefaults.standard.set(long, forKey: UserDefaultsKeys.mapLon)
        UserDefaults.standard.set(zoom, forKey: UserDefaultsKeys.mapZoom)
    
    }
}
