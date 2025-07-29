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

    fileprivate weak var timer: Timer?
        
    @IBOutlet weak var vesselLabel: UILabel!
    @IBOutlet weak var destinationLabel1: UILabel!
    @IBOutlet weak var destinationLabel2: UILabel!
    @IBOutlet weak var schedDepartLabel1: UILabel!
    @IBOutlet weak var schedDepartLabel2: UILabel!
    @IBOutlet weak var actualDepartLabel1: UILabel!
    @IBOutlet weak var actualDepartLabel2: UILabel!
    @IBOutlet weak var etaLabel1: UILabel!
    @IBOutlet weak var etaLabel2: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var vesselImage: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var vesselStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        
        self.vesselStackView.isHidden = true

        let backButton = UIBarButtonItem()
        backButton.title = "Vessel Watch"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        self.timer = Timer.scheduledTimer(timeInterval: CachesStore.ferryDetailUpdateTime, target: self, selector: #selector(self.vesselDetailTimerTask), userInfo: nil, repeats: true)
        
        self.loadVessel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "VesselDetails")
    }
    
    @objc func vesselDetailTimerTask(_ timer:Timer) {
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        
        self.loadVessel()
        
    }
    
    func loadVessel() {
                
          AF.request("https://www.wsdot.wa.gov/ferries/api/vessels/rest/vessellocations?apiaccesscode=" + ApiKeys.getWSDOTKey()).validate().responseDecodable(of: VesselWatchStore.self) { response in
              switch response.result {
              case .success:
                  if let value = response.data {
                      let json = JSON(value)
                      let vessels = VesselWatchStore.parseVesselsJSON(json)
                      
                      for vessel in vessels {
                          
                          if (vessel.vesselID == self.vesselItem?.vesselID) {
                                                            
                              self.vesselLabel.text = vessel.vesselName
                              self.vesselLabel.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)

                              
                              self.destinationLabel1.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
                              
                              if (self.vesselItem?.departingTerminal != "N/A") && (vessel.arrivingTerminal != "N/A") {
                                  self.destinationLabel2.text = String(vessel.departingTerminal) + " to " + String(vessel.arrivingTerminal)
                              }
                              else {
                                  self.destinationLabel2.text = "Not Available"
                              }
                              
                              self.schedDepartLabel1.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .body).pointSize)
                              
                              if let departTime = vessel.nextDeparture {
                                  self.schedDepartLabel2.text = TimeUtils.getTimeOfDay(departTime)
                              } else {
                                  self.schedDepartLabel2.text = "--:--"
                              }
                              
                              self.actualDepartLabel1.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .body).pointSize)

                              
                              if let actualDepartTime = vessel.leftDock {
                                  self.actualDepartLabel2.text = TimeUtils.getTimeOfDay(actualDepartTime)
                              } else {
                                  self.actualDepartLabel2.text = "--:--"
                              }
                              
                              self.etaLabel1.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .body).pointSize)

                              if let eta = vessel.eta {
                                  self.etaLabel2.text = TimeUtils.getTimeOfDay(eta)
                              } else {
                                  self.etaLabel2.text = "--:--"
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
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.loadVessel()
        
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        MyAnalytics.event(category: "VesselDetails", action: "UIAction", label: "Refresh")
                
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        self.loadVessel()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent {
            if timer != nil {
                self.timer?.invalidate()
            }
        }
    }
    
}
