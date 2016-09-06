//
//  VesselDetailsViewController.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
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
        super.viewDidLoad()
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
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Ferries/VesselWatch/Vessel Details/" + self.title!)
    }
    
    @IBAction func linkAction(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.wsdot.com/ferries/vesselwatch/VesselDetail.aspx?vessel_id=" + String((vesselItem?.vesselID)!))!)
    }
    
}