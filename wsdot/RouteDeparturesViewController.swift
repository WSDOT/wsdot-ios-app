//
//  RouteDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit
import GoogleMobileAds

class RouteDeparturesViewController: UIViewController {
    
    let timesViewSegue = "timesViewSegue"
    let camerasViewSegue = "camerasViewSegue"

    @IBOutlet weak var timesContainerView: UIView!
    @IBOutlet weak var camerasContainerView: UIView!

    // set by previous view controller
    var currentSailing : (String, String) = ("", "")
    var sailingsByDate : [FerriesScheduleDateItem]? = nil
    

    var segment = 0

    @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentSailing.0 + " to " + currentSailing.1

        self.timesContainerView.alpha = 1
        self.camerasContainerView.alpha = 0

        // Ad Banner
        bannerView.adUnitID = "ad_string"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())


    }
    
    /*
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
     refresh(self.refreshControl)
     }
     
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == timesViewSegue {
            let dest: RouteTimesViewController = segue.destinationViewController as! RouteTimesViewController
            dest.currentSailing = self.currentSailing
            dest.sailingsByDate = self.sailingsByDate
        }
        
    }
    
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animateWithDuration(0.5, animations: {
                self.timesContainerView.alpha = 1
                self.camerasContainerView.alpha = 0
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.timesContainerView.alpha = 0
                self.camerasContainerView.alpha = 1
            })
        }
    }
    
}
