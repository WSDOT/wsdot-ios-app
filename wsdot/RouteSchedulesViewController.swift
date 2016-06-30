//
//  RouteSchedulesViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteSchedulesViewController: UITableViewController {

    let cellIdentifier = "FerriesRouteSchedulesCell"
    var routes = [FerriesRouteScheduleItem]()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    // MARK: -
    // MARK: Initialization
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Route Schedules"
        
        //tableView.registerClass(RoutesCustomCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        
        activityIndicatorView.startAnimating()
    
        RouteSchedulesStore.getRouteSchedules { data, error in
            
            self.activityIndicatorView.stopAnimating()
            if let validData = data {
                self.routes = validData
                // Reload tableview on UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            } else {
                // TODO: Display error
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -
    // MARK: Table View Data Source Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! RoutesCustomCell
        
        cell.title.text = routes[indexPath.row].routeDescription
        cell.subTitle.text = "updated: "
        cell.alertButton = UIButton()
        
        if self.routes[indexPath.row].routeAlert.count == 0 {
            cell.alertButton.hidden = true
        }
        
        // Configure Cell
        // cell.textLabel?.text = routes[indexPath.row].routeDescription
     
        return cell
    }

    // MARK: -
    // MARK: Table View Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(routes[indexPath.row].routeDescription)
                        
        if self.routes[indexPath.row].routeAlert.count > 0 {
            print("this route has alerts!")
        }
        
    }
}
