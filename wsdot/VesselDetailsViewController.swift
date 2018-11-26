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
import SafariServices

class VesselDetailsViewController: UIViewController{
    
    let vesselBaseUrlString = "http://www.wsdot.com/ferries/vesselwatch/VesselDetail.aspx?vessel_id="
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MyAnalytics.screenView(screenName: "Vessel Details" + self.title!)
    }
    
    @IBAction func linkAction(_ sender: UIBarButtonItem) {
        let svc = SFSafariViewController(url: URL(string: vesselBaseUrlString + String((vesselItem?.vesselID)!))!, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
}
