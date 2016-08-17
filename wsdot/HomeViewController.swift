//
//  HomeViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let TITLE = "Home"

    let cellIdentifier = "HomeCell"
    let SegueFerriesHomeViewController = "FerriesHomeViewController"
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = TITLE
        menu_options = ["Traffic Map", "Ferries", "Mountain Passes", "Social Media", "Toll Rates", "Border Waits", "Amtrak Cascades"]
        
        self.tabBarController!.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: TITLE, image: UIImage(named: "ic-home"), tag: 0)
    }

    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }

    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(menu_options[indexPath.row])
        // Perform Segue
        switch (indexPath.row) {
            case 1:
                performSegueWithIdentifier(SegueFerriesHomeViewController, sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            default:
                break
        }
    }
}
