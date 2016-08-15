//
//  VesselWatchViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/15/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import GoogleMaps

class VesselWatchViewController: UIViewController{
    
    
    private var embeddedViewController: MapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
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
