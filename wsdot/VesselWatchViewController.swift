//
//  VesselWatchViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/15/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds

class VesselWatchViewController: UIViewController{
    
    
    private var embeddedViewController: MapViewController!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
    }
    
    
    @IBAction func myLocationButtonPressed(sender: UIBarButtonItem) {
        embeddedViewController.goToUsersLocation()
    }
    
    // Get refrence to child VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MapViewController
            where segue.identifier == "EmbedMapSegue" {
            self.embeddedViewController = vc
        }
    }
}
