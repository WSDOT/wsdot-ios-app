//
//  MountainPassesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel!.text = passItems[indexPath.row].name
     
        return cell
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
                let destinationViewController = segue.destinationViewController as! MountainPassDetailsViewController
                destinationViewController.passItem = passItem
            }
        }
    }
}
