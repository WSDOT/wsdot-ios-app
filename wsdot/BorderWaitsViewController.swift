//
//  BorderWaitViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class BorderWaitsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let cellIdentifier = "borderwaitcell"

    @IBOutlet weak var tableView: UITableView!
    var displayedWaits = [BorderWaitItem]()
    var northboundWaits = [BorderWaitItem]()
    var southboundWaits = [BorderWaitItem]()
    
    override func viewDidLoad() {
        title = "Border Waits"
        
        let testWait = BorderWaitItem()
        
        testWait.id = 0
        testWait.name = "Lynden/Aldergrove"
        testWait.route = 5
        testWait.lane = "car"
        testWait.waitTime = 10
        testWait.updated = "2016-08-24 09:05 AM"
    
        northboundWaits.append(testWait)
        
        displayedWaits = northboundWaits
    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedWaits.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! BorderWaitCell
        
        let wait = displayedWaits[indexPath.row]

        cell.nameLabel.text = wait.name
        cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(wait.updated), numericDates: false)
        cell.waitTimeLabel.text = String(wait.waitTime) + " min"
        cell.RouteImage.image = UIImage(named: "icListI5")
                
        return cell
    }
    
    // Remove and add hairline for nav bar
    override func viewWillAppear(animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
        case 0:
            displayedWaits = northboundWaits
            tableView.reloadData()
            break
        case 1:
            displayedWaits = southboundWaits
            tableView.reloadData()
            break
        default:
            break
        }
    }
}
