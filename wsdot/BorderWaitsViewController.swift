//
//  BorderWaitViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BorderWaitsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let cellIdentifier = "borderwaitcell"
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var segmentedControlView: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var displayedWaits = [BorderWaitItem]()
    var northboundWaits = [BorderWaitItem]()
    var southboundWaits = [BorderWaitItem]()
    
    let i5Icon = UIImage(named:"icListI5")
    let sr9Icon = UIImage(named: "icListSR9")
    let sr539Icon = UIImage(named: "icListSR539")
    let sr543Icon = UIImage(named: "icListSR543")
    let us97Icon = UIImage(named: "icListUS97")
    
    let bc11Icon = UIImage(named: "icListBC11")
    let bc13Icon = UIImage(named: "icListBC13")
    let bc15Icon = UIImage(named: "icListBC15")
    let bc97Icon = UIImage(named: "icListBC97")
    let bc99Icon = UIImage(named: "icListBC99")
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        title = "Border Waits"
        
        displayedWaits = northboundWaits
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BorderWaitsViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refresh(false)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
    }
    
    func refreshAction(refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(force: Bool){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            BorderWaitStore.updateWaits(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.northboundWaits = BorderWaitStore.getNorthboundWaits()
                            selfValue.southboundWaits = BorderWaitStore.getSouthboundWaits()
                            if (selfValue.segmentedControlView.selectedSegmentIndex == 0){
                                selfValue.displayedWaits = selfValue.northboundWaits
                            } else {
                                selfValue.displayedWaits = selfValue.southboundWaits
                            }
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
        
        cell.nameLabel.text = wait.name + " (" + wait.lane + ")"
        
        do {
            let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(wait.updated), numericDates: false)
            cell.updatedLabel.text = updated
        } catch TimeUtils.TimeUtilsError.InvalidTimeString {
            cell.updatedLabel.text = "N/A"
        } catch {
            cell.updatedLabel.text = "N/A"
        }
        
        if wait.waitTime == -1 {
            cell.waitTimeLabel.text = "N/A"
        }else if wait.waitTime < 5 {
            cell.waitTimeLabel.text = "< 5 min"
        }else{
            cell.waitTimeLabel.text = String(wait.waitTime) + " min"
        }
        
        cell.RouteImage.image = getIcon(wait.route)
        
        return cell
    }
    
    func getIcon(route: Int) -> UIImage?{
        
        if (segmentedControlView.selectedSegmentIndex == 0){
            switch(route){
            case 5: return i5Icon
            case 9: return sr9Icon
            case 97: return us97Icon
            case 539: return sr539Icon
            case 543: return sr543Icon
            default: return nil
            }
        }else{
            switch(route){
            case 5: return bc99Icon
            case 9: return bc11Icon
            case 539: return bc13Icon
            case 543: return bc15Icon
            default: return nil
            }
        }
    }
    
    // Remove and add hairline for nav bar
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Border Waits")
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
