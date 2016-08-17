//
//  VesselDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/16/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class VesselDetailsViewController: UIViewController{
    
    var vesselItem: VesselItem? = nil
    
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var arrLabel: UILabel!
    @IBOutlet weak var schedDepartLabel: UILabel!
    @IBOutlet weak var actualDepartLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var headinglabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    override func viewDidLoad() {
        
        title = vesselItem?.vesselName
        
        routeLabel.text = vesselItem?.route
        departLabel.text = vesselItem?.departingTerminal
        arrLabel.text = vesselItem?.arrivingTerminal
        
        if let departTime = vesselItem?.nextDeparture {
            schedDepartLabel.text = TimeUtils.getTimeOfDay(departTime)
        } else {
            schedDepartLabel.text = "--:--"
        }
        
        if let actualDepartTime = vesselItem?.leftDock {
            actualDepartLabel.text = TimeUtils.getTimeOfDay(actualDepartTime)
        } else {
            actualDepartLabel.text = "--:--"
        }
 
        if let eta = vesselItem?.eta {
            etaLabel.text = TimeUtils.getTimeOfDay(eta)
        } else {
            etaLabel.text = "--:--"
        }
        
        if let speed = vesselItem?.speed {
            speedLabel.text = String(speed)
        } else {
            speedLabel.text = ""
        }
        
        headinglabel.text = vesselItem?.headText

        
    }
    
    @IBAction func linkAction(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.wsdot.com/ferries/vesselwatch/VesselDetail.aspx?vessel_id=" + String((vesselItem?.vesselID)!))!)
    }
    
}