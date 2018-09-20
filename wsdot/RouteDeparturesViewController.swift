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
    
    @IBOutlet weak var sailingButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var routeItem: FerryScheduleItem?
    var routeId = 0
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    let favoriteBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // title = routeItem!.terminalPairs[0].aTerminalName + " to " + routeItem!.terminalPairs[0].bTterminalName
        self.camerasContainerView.isHidden = true
        self.vesselWatchContainerView.isHidden = true
        
        sailingButton.layer.cornerRadius = 6.0
        
        // Favorite button
        self.favoriteBarButton.action = #selector(RouteDeparturesViewController.updateFavorite(_:))
        self.favoriteBarButton.target = self
        self.favoriteBarButton.tintColor = Colors.yellow
        self.favoriteBarButton.image = UIImage(named: "icStarSmall")
        self.favoriteBarButton.accessibilityLabel = "add to favorites"

        self.navigationItem.rightBarButtonItem = self.favoriteBarButton
        
        loadSailings()
        
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
    
    func loadSailings(){
    
        self.showOverlay(self.view)
    
        FerryRealmStore.updateRouteSchedules(false, completion: { error in
            if (error == nil) {
                
                self.routeItem = FerryRealmStore.findSchedule(withId: self.routeId)

                if let routeItemValue = self.routeItem {
                    self.title = routeItemValue.routeDescription

                    if (routeItemValue.routeAlerts.count > 0){
                        //self.tabBar.items?[1].badgeValue = String(routeItemValue.routeAlerts.count)
                    } else {
                        //self.tabBar.items?[1].isEnabled = false
                    }
        
                    if (routeItemValue.selected){
                        self.favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
                        self.favoriteBarButton.accessibilityLabel = "remove from favorites"
                    } else {
                        self.favoriteBarButton.image = UIImage(named: "icStarSmall")
                        self.favoriteBarButton.accessibilityLabel = "add to favorites"
                    }
                
                   // let sailings = self.children[0] as! RouteSailingsViewController
                   // sailings.setRouteItemAndReload(routeItemValue)
                
                   // let alerts = self.children[1] as! RouteAlertsViewController
                   // alerts.setAlertsFromRouteItem(routeItemValue)
                
                   // self.pushAlertCheck(routeItemValue)
                    
                    self.hideOverlayView()
                } else {
        
                    self.navigationItem.rightBarButtonItem = nil
                    self.hideOverlayView()
                    
                    let alert = AlertMessages.getSingleActionAlert("Route Unavailable", message: "", confirm: "OK", comfirmHandler: { action in
                        self.navigationController!.popViewController(animated: true)
                    })
                
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else {
                self.hideOverlayView()
                self.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
            }
        })
    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == timesViewSegue {
            let dest: RouteTimesViewController = segue.destination as! RouteTimesViewController
            dest.currentSailing = self.routeItem!.terminalPairs[0]
            dest.sailingsByDate = self.routeItem!.scheduleDates
  
        }
        
        if segue.identifier == camerasViewSegue {
            let dest: RouteCamerasViewController = segue.destination as! RouteCamerasViewController
            dest.departingTerminalId = getDepartingId()
        }
        
        if segue.identifier == vesselWatchSegue {
            // Set map to route
            let location = VesselWatchStore.getRouteLocation(scheduleId: routeId)
            let zoom = VesselWatchStore.getRouteZoom(scheduleId: routeId)
            UserDefaults.standard.set(location.latitude, forKey: UserDefaultsKeys.mapLat)
            UserDefaults.standard.set(location.longitude, forKey: UserDefaultsKeys.mapLon)
            UserDefaults.standard.set(zoom, forKey: UserDefaultsKeys.mapZoom)
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
        let sailings = self.routeItem!.scheduleDates[0].sailings
        
        // get sailings for current route
        for sailing in sailings {
            if ((sailing.departingTerminalId == routeItem!.terminalPairs[0].aTerminalId)) {
                return sailing.departingTerminalId
            }
        }
        
        return -1
    }
    
    @objc func updateFavorite(_ sender: UIBarButtonItem) {
    
        let isFavorite = FerryRealmStore.toggleFavorite(routeId)
        
        if (isFavorite == 1){
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        } else if (isFavorite == 0){
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        } else {
            print("favorites write error")
        }
        
    }
}
