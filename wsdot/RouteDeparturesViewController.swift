//
//  RouteDetailsViewController.swift
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
import UIKit
import GoogleMobileAds
import RealmSwift

class RouteDeparturesViewController: UIViewController, GADBannerViewDelegate {
    
    let timesViewSegue = "timesViewSegue"
    let camerasViewSegue = "camerasViewSegue"
    let vesselWatchSegue = "vesselWatchSegue"

    @IBOutlet weak var timesContainerView: UIView!
    @IBOutlet weak var camerasContainerView: UIView!
    @IBOutlet weak var vesselWatchContainerView: UIView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    // set by previous view controller
    var currentSailing = FerryTerminalPairItem()
    var sailingsByDate = List<FerryScheduleDateItem>()
    var routeId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentSailing.aTerminalName + " to " + currentSailing.bTterminalName
        self.camerasContainerView.isHidden = true
        self.vesselWatchContainerView.isHidden = true
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":"ferries"]
        
        bannerView.load(request)
        bannerView.delegate = self
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == timesViewSegue {
            let dest: RouteTimesViewController = segue.destination as! RouteTimesViewController
            dest.currentSailing = self.currentSailing
            dest.sailingsByDate = self.sailingsByDate
        }
        
        if segue.identifier == camerasViewSegue {
            let dest: RouteCamerasViewController = segue.destination as! RouteCamerasViewController
            dest.departingTerminalId = getDepartingId()
        }
        
        if segue.identifier == vesselWatchSegue {
             let dest: VesselWatchViewController = segue.destination as! VesselWatchViewController
             dest.routeId = self.routeId
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.timesContainerView.isHidden = false
                self.camerasContainerView.isHidden = true
                self.vesselWatchContainerView.isHidden = true
            })
        } else if sender.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.timesContainerView.isHidden = true
                self.camerasContainerView.isHidden = false
                self.vesselWatchContainerView.isHidden = true
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.timesContainerView.isHidden = true
                self.camerasContainerView.isHidden = true
                self.vesselWatchContainerView.isHidden = false
            })
        }
    }
    
    // MARK: -
    // MARK: Helper functions
    fileprivate func getDepartingId() -> Int{
        
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
