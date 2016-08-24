//
//  BorderWaitsNorthbound.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class BorderWaitsNorthboundViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "borderwaitcell"

    var waits = [BorderWaitItem]()
    
    override func viewDidLoad(){
    
        let testWait = BorderWaitItem()
        
        testWait.id = 0
        testWait.name = "Lynden/Aldergrove"
        testWait.route = 5
        testWait.lane = "car"
        testWait.waitTime = 10
        testWait.updated = "2016-08-24 09:05 AM"
    
        waits.append(testWait)
    
    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waits.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! BorderWaitCell
        
        let wait = waits[indexPath.row]

        cell.nameLabel.text = wait.name
        cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(wait.updated), numericDates: false)
        cell.waitTimeLabel.text = String(wait.waitTime) + " min"
        cell.RouteImage.image = UIImage(named: "icListI5")

                
        return cell
    }
}