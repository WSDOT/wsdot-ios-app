//
//  VesselWatchGoToViewController.swift
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

class VesselWatchGoToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "GoToCell"
    
    var my_parent: VesselWatchViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menu_options = ["Anacortes / San Juan Islands / Sidney BC",
                        "Edmonds / Kingston",
                        "Fauntleroy / Vashon / Southworth",
                        "Mukilteo / Clinton",
                        "Point Defiance / Tahlequah",
                        "Port Townsend / Coupeville",
                        "San Juan Islands Inter-Island",
                        "Seattle",
                        "Seattle / Bainbridge"]
    }

    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Ferries/VesselWatch/GoTo Location")
    }
    
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
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: {()->Void in});
        GoogleAnalytics.screenView(screenName: "/Ferries/VesselWatch/GoTo Location/" + menu_options[indexPath.row])
        my_parent?.goTo(indexPath.row)
    }
}
