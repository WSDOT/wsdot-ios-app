//
//  TravelerInfoViewController.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the Licensevarr
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

class TravelerInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let cellIdentifier = "TravelerInfoCell"
    
    let SegueTravelTimesViewController = "TravelTimesViewController"
    let SegueExpressLanesViewController = "ExpressLanesViewController"
    let SegueBestTimesToTravelRoutesViewController = "BestTimesToTravelRoutesViewController"
    let SegueNewsViewController = "NewsViewController"
    let SegueHappeningNowViewController = "HappeningNowTabViewController"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var menu_options: [String] = []
    
    var bestTimesToTravel: BestTimesToTravelItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "Traveler Information"
        menu_options = ["Happening Now", "Travel Times", "Express Lanes", "News Releases"]
        
        checkForTravelCharts()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information")
    }
    
    /*
        Checks if "best time to travel charts" are available from the data server,
        if they are, add a new menu option to display the chart information
    */
    func checkForTravelCharts() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            BestTimesToTravelStore.getBestTimesToTravel({ data, error in
                
                if let selfValue = self{
                    selfValue.activityIndicator.isHidden = true
                    selfValue.activityIndicator.stopAnimating()
                }
                
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.bestTimesToTravel = validData
                            
                            if (validData.available){
                                self?.menu_options.append(validData.name)
                                selfValue.tableView.reloadData()
                            }
                        }
                    }
                } else {
                     DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }

    }

    
    // MARK: TableView methods
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = menu_options[indexPath.row]
        
        

        switch (indexPath.row) {
        case 0: // Happening Now
            cell.imageView?.image = UIImage(named: "icBolt")
            break
        case 1: // Travel Times
            cell.imageView?.image = UIImage(named: "icClock")
            break
        case 2: // Express Lanes
            cell.imageView?.image = UIImage(named: "icRocket")
            break
        case 3: // News Releases
            cell.imageView?.image = UIImage(named: "icNews")
            break
        case 4: // Travel Charts
            cell.imageView?.image = UIImage(named: "icNotice")
        default:
            break
        }

        
        return cell
    }

    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0: // Happening Now
            performSegue(withIdentifier: SegueHappeningNowViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 1: // Travel Times
            performSegue(withIdentifier: SegueTravelTimesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 2: // Express Lanes
            performSegue(withIdentifier: SegueExpressLanesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 3: // News Releases
            performSegue(withIdentifier: SegueNewsViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 4: // Travel Charts
            performSegue(withIdentifier: SegueBestTimesToTravelRoutesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // If travel charts are available, pass them downloaded data on
        if segue.identifier ==  SegueBestTimesToTravelRoutesViewController {
            let destinationViewController = segue.destination as! BestTimesToTravelRoutesViewController
            destinationViewController.bestTimesToTravel = self.bestTimesToTravel
        }
    
    
    }
}
