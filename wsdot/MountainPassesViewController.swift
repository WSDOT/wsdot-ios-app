//
//  MountainPassesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import Foundation

class MountainPassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "PassCell"
    let segueMountainPassDetailsViewController = "MountainPassDetailsViewController"
    
    var passItems = [MountainPassItem]()

    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
    
        title = "Mountain Passes"
    
        // refresh controller
        refreshControl.addTarget(self, action: #selector(MountainPassesViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refresh(false)
        tableView.rowHeight = UITableViewAutomaticDimension
    
    }
    func refresh(force: Bool){
      dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            MountainPassStore.updatePasses(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.passItems = MountainPassStore.getPasses()
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func refreshAction(sender: UIRefreshControl) {
        refresh(true)
    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MountainPassCell
        
        let passItem = passItems[indexPath.row]
        
        cell.nameLabel.text = passItem.name
        
        if (passItem.forecast.count > 0){
            cell.forecastLabel.text = WeatherUtils.getForecastBriefDescription(passItem.forecast[0].forecastText)
            cell.weatherImage.image = UIImage(named: WeatherUtils.getIconName(passItem.forecast[0].forecastText, title: passItem.forecast[0].day))
        } else {
            cell.forecastLabel.text = ""
            cell.weatherImage.image = nil
        }
        
        cell.updatedLabel.text = TimeUtils.fullTimeStamp(passItem.dateUpdated)
     
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        performSegueWithIdentifier(segueMountainPassDetailsViewController, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueMountainPassDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let passItem = self.passItems[indexPath.row] as MountainPassItem
                let destinationViewController = segue.destinationViewController as! MountainPassTabBarViewController
                destinationViewController.passItem = passItem
            }
        }
    }
}
