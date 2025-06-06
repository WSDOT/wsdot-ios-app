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

    fileprivate weak var timer: Timer?
    
    @IBOutlet weak var vesselStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vesselStackView.isHidden = true
        
        refresh()

        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // refresh controller
        self.timer = Timer.scheduledTimer(timeInterval: CachesStore.ferryDetailUpdateTime, target: self, selector: #selector(self.alertsTimerTask), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "VesselDetails")
    }
    
    // timer to force refresh traffic alerts
    @objc func alertsTimerTask(_ timer:Timer) {
        refresh()
    }
    
    func refresh() {
                
        self.title = ""
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false

          AF.request("https://www.wsdot.wa.gov/ferries/api/vessels/rest/vessellocations?apiaccesscode=" + ApiKeys.getWSDOTKey()).validate().responseDecodable(of: VesselWatchStore.self) { response in
              switch response.result {
              case .success:
                  if let value = response.data {
                      let json = JSON(value)
                      let vessels = VesselWatchStore.parseVesselsJSON(json)
                      
                      for vessel in vessels {
                          
                          if (vessel.vesselID == self.vesselItem?.vesselID) {
                                                            
                              self.vesselLabel.text = vessel.vesselName
                              
                              if (self.vesselItem?.departingTerminal != "N/A") && (vessel.arrivingTerminal != "N/A") {
                                  self.destinationLabel.text = String(vessel.departingTerminal) + " to " + String(vessel.arrivingTerminal)
                              }
                              else {
                                  self.destinationLabel.text = "Not Available"
                              }
                              
                              if let departTime = vessel.nextDeparture {
                                  self.schedDepartLabel.text = TimeUtils.getTimeOfDay(departTime)
                              } else {
                                  self.schedDepartLabel.text = "--:--"
                              }
                              
                              if let actualDepartTime = vessel.leftDock {
                                  self.actualDepartLabel.text = TimeUtils.getTimeOfDay(actualDepartTime)
                              } else {
                                  self.actualDepartLabel.text = "--:--"
                              }
                              
                              if let eta = vessel.eta {
                                  self.etaLabel.text = TimeUtils.getTimeOfDay(eta)
                              } else {
                                  self.etaLabel.text = "--:--"
                              }
                      
                              self.updatedLabel.text = TimeUtils.timeAgoSinceDate(date: vessel.updateTime, numericDates: true)
                              
                              self.vesselImage.image = UIImage(named: self.vesselItem?.vesselName ?? "")
                              self.vesselImage.layer.borderWidth = 0.5
                          }
                      }
                      self.vesselStackView.isHidden = false
                  }
                  

              case .failure(let error):
                  print(error)
                  AlertMessages.getConnectionAlert(backupURL: WsdotURLS.ferries, message: WSDOTErrorStrings.ferriesSchedule)
                  
                  self.vesselStackView.isHidden = true
              }
              
              self.activityIndicatorView.stopAnimating()
              self.activityIndicatorView.isHidden = true
          }
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent {
            if timer != nil {
                self.timer?.invalidate()
            }
        }
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
