//
//  BestTimesToTravelRoutesViewController.swift
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


class BestTimesToTravelRoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let SegueBestTimesToTravelDetailsViewController = "BestTimesToTravelDetailsViewController"
    let cellIdentifier = "bestTimesRouteCell"

    var bestTimesToTravel: BestTimesToTravelItem? = nil

    var menu_options = [String]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = bestTimesToTravel != nil ? bestTimesToTravel!.name : "Error"
        
        menu_options = bestTimesToTravel != nil ? getRoutes(bestTimes: bestTimesToTravel!) : [String]()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information/Best Times To Travel Routes")
    }

    // Builds table
    func getRoutes(bestTimes: BestTimesToTravelItem) -> [String]{
    
        var menu = [String]()
        
        for route in bestTimes.routes {
            menu.append(route.name)
        }
    
        return menu
    }

    // MARK: Table View Data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = menu_options[indexPath.row]
        return cell
    }
    
    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueBestTimesToTravelDetailsViewController, sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueBestTimesToTravelDetailsViewController {
            let destinationViewController = segue.destination as! BestTimesToTravelDetailsViewController
            if let rowIndex = sender as? Int {
                destinationViewController.routeItem = (bestTimesToTravel?.routes[rowIndex])!
            }
        }
    }
}
