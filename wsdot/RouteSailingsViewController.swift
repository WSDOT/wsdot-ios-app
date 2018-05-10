//
//  RouteDepartureViewController.swift
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

class RouteSailingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteSailings"
    let SegueRouteDeparturesViewController = "RouteDeparturesViewController"
    
    @IBOutlet var tableView: UITableView!
    
    var routeItem : FerryScheduleItem = FerryScheduleItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Ferries/Schedules/Sailings")
    }
    
    func setRouteItemAndReload(_ routeItem: FerryScheduleItem){
        self.routeItem = routeItem
        if (tableView != nil){
            tableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeItem.terminalPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let sailing = routeItem.terminalPairs[indexPath.row]
        
        cell.textLabel?.text = sailing.aTerminalName + " to " + sailing.bTterminalName
        
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        performSegue(withIdentifier: SegueRouteDeparturesViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! RouteDeparturesViewController
                
                destinationViewController.sailingsByDate = routeItem.scheduleDates
                destinationViewController.currentSailing = routeItem.terminalPairs[indexPath.row]

                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                self.tabBarController!.navigationItem.backBarButtonItem = backItem
            }
        }
    }

}
