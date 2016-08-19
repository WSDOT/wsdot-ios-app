//
//  TrafficMapViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/19/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import UIKit
import GoogleMaps
import GoogleMobileAds

class TrafficMapViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var embeddedMapViewController: MapViewController!
    
    override func viewDidLoad() {
        
        title = "Traffic Map"
        
        activityIndicatorView.startAnimating()
        
        
        
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.hidden = true
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
    }
    
    @IBAction func myLocationButtonPressed(sender: UIBarButtonItem) {
        embeddedMapViewController.goToUsersLocation()
    }
    
    
    
    // MARK: MapMarkerViewController protocol method
    func drawOverlays(){
        /*
         activityIndicator.startAnimating()
         let serviceGroup = dispatch_group_create();
         
         fetchCameras(false, serviceGroup: serviceGroup)
         fetchVessels(serviceGroup)
         
         dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
         self.activityIndicator.stopAnimating()
         self.activityIndicator.hidden = true
         }
         */
    }
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MapViewController
            where segue.identifier == "EmbedMapSegue" {
            vc.markerDelegate = self
            vc.mapDelegate = self
            self.embeddedMapViewController = vc
        }
    }
}