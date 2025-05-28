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
import SwiftyJSON
import Alamofire


class VesselDetailsViewController: RefreshViewController {
        
    var vesselItem: VesselItem? = nil
    
    let vesselBaseUrlString = "https://www.wsdot.com/ferries/vesselwatch/VesselDetail.aspx?vessel_id="
    
    @IBOutlet weak var vesselLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var schedDepartLabel: UILabel!
    @IBOutlet weak var actualDepartLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var vesselImage: UIImageView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        vesselLabel.text = vesselItem?.vesselName
        
        if (vesselItem?.departingTerminal != "N/A") && (vesselItem?.arrivingTerminal != "N/A") {
            destinationLabel.text = String(vesselItem?.departingTerminal ?? "") + " to " + String(vesselItem?.arrivingTerminal ?? "")
        }
        else {
            destinationLabel.text = "Not Available"
        }
        
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
        
        if let updated = vesselItem?.updateTime {
              updatedLabel.text = TimeUtils.timeAgoSinceDate(date: updated, numericDates: true)
        } else {
            updatedLabel.text = ""
        }
        
        self.vesselImage.image = UIImage(named: vesselItem?.vesselName ?? "")
        self.vesselImage.layer.borderWidth = 0.5
        
        self.activityIndicatorView.isHidden = true
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "VesselDetails")
    }
    
    @IBAction func linkAction(_ sender: UIBarButtonItem) {
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL(string: vesselBaseUrlString + String((vesselItem?.vesselID)!))!, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
}
