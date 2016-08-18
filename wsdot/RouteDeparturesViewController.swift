//
//  RouteDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit
import GoogleMobileAds
import RealmSwift

class RouteDeparturesViewController: UIViewController {
    
    let timesViewSegue = "timesViewSegue"
    let camerasViewSegue = "camerasViewSegue"

    @IBOutlet weak var timesContainerView: UIView!
    @IBOutlet weak var camerasContainerView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var adBackGroundView: UIView!
    
    // set by previous view controller
    var currentSailing = FerryTerminalPairItem()
    var sailingsByDate = List<FerryScheduleDateItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentSailing.aTerminalName + " to " + currentSailing.bTterminalName
        
        self.camerasContainerView.hidden = true
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
    }
    
    override func viewDidAppear(animated: Bool) {
        adBackGroundView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == timesViewSegue {
            let dest: RouteTimesViewController = segue.destinationViewController as! RouteTimesViewController
            dest.currentSailing = self.currentSailing
            dest.sailingsByDate = self.sailingsByDate
        }
        
        if segue.identifier == camerasViewSegue {
            let dest: RouteCamerasViewController = segue.destinationViewController as! RouteCamerasViewController
            dest.departingTerminalId = getDepartingId()
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animateWithDuration(0.3, animations: {
                self.timesContainerView.hidden = false
                self.camerasContainerView.hidden = true
            })
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.timesContainerView.hidden = true
                self.camerasContainerView.hidden = false
            })
        }
    }
    
    // MARK: -
    // MARK: Helper functions
    private func getDepartingId() -> Int{
        
        // get sailings for selected day
        let sailings = sailingsByDate[0].sailings
        
        // get sailings for current route
        for sailing in sailings {
            if ((sailing.departingTerminalId == currentSailing.aTerminalId)) {
                return sailing.departingTerminalId
            }
        }
        
        return -1
    }
    
}
