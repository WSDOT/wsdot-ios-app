//
//  HomeViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "HomeCell"
    
    let itemsPerRow = 3
    
    let SegueTrafficMapViewController = "TrafficMapViewController"
    let SegueFerriesHomeViewController = "FerriesHomeViewController"
    let SegueTollRatesViewController = "TollRatesViewController"
    let SegueBorderWaitsViewController = "BorderWaitsViewController"
    let SegueInfoViewController = "InfoViewController"
    let SegueMountainPassesViewController = "MountainPassesViewController"
    
    var menu_options: [String] = []
    var menu_icon_names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "WSDOT"
        menu_options = ["Traffic Map", "Ferries", "Mountain Passes", "Social Media", "Toll Rates", "Border Waits", "Amtrak Cascades"]
        menu_icon_names = ["icHomeTraffic","icHomeFerries","icHomePasses","icHomeSocialMedia","icHomeTollRates","icHomeBorderWaits","icHomeAmtrakCascades"]
        
        self.tabBarController!.view.backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "ic-home"), tag: 0)
    }
    @IBAction func infoBarButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueInfoViewController, sender: self)
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! HomeCell
        
        cell.label?.text = menu_options[indexPath.row]
        cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegueWithIdentifier(SegueTrafficMapViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 1:
            performSegueWithIdentifier(SegueFerriesHomeViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 2:
            performSegueWithIdentifier(SegueMountainPassesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 4:
            performSegueWithIdentifier(SegueTollRatesViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 5:
            performSegueWithIdentifier(SegueBorderWaitsViewController, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        default:
            break
        }
    }
}
