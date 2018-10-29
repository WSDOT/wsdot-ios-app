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

    let locationManager = CLLocationManager()
    
    let segueDepartureDaySelectionViewController = "DepartureDaySelectionViewController"
    let segueTerminalSelectionViewController = "TerminalSelectionViewController"

    @IBOutlet weak var timesContainerView: UIView!
    @IBOutlet weak var camerasContainerView: UIView!
    @IBOutlet weak var vesselWatchContainerView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var routeTimesVC: RouteTimesViewController!
    var routeCamerasVC: RouteCamerasViewController!
    
    @IBOutlet weak var sailingButton: IconButton!
    @IBOutlet weak var dayButton: IconButton!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var routeItem: FerryScheduleItem?
    var routeId = 0
    
    var selectedTerminal = 0
    
    var overlayView = UIView()
    
    let favoriteBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.camerasContainerView.isHidden = true
        self.vesselWatchContainerView.isHidden = true
        
        sailingButton.setTitleColor(UIColor.lightText, for: .highlighted)
        sailingButton.layer.cornerRadius = 6.0
        sailingButton.contentHorizontalAlignment = .left
        sailingButton.titleLabel?.minimumScaleFactor = 0.5
        sailingButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        dayButton.setTitleColor(UIColor.lightText, for: .highlighted)
        dayButton.layer.cornerRadius = 6.0
        dayButton.contentHorizontalAlignment = .left
        dayButton.titleLabel?.minimumScaleFactor = 0.5
        dayButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
    
    @IBAction func sailingsButtonTap(_ sender: IconButton) {
        performSegue(withIdentifier: segueTerminalSelectionViewController, sender: self)
    }
    
    @IBAction func dayButtonTap(_ sender: Any) {
        performSegue(withIdentifier: segueDepartureDaySelectionViewController, sender: self)
    }
    
    func loadSailings() {
    
        FerryRealmStore.updateRouteSchedules(false, completion: { error in
            if (error == nil) {
                
                self.routeItem = FerryRealmStore.findSchedule(withId: self.routeId)
                
                if let routeItemValue = self.routeItem {

                    self.title = routeItemValue.routeDescription

                    self.sailingButton.setTitle("\(routeItemValue.terminalPairs[0].aTerminalName) to \(routeItemValue.terminalPairs[0].bTterminalName)", for: UIControl.State())
                
                    if (routeItemValue.selected){
                        self.favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
                        self.favoriteBarButton.accessibilityLabel = "remove from favorites"
                    } else {
                        self.favoriteBarButton.image = UIImage(named: "icStarSmall")
                        self.favoriteBarButton.accessibilityLabel = "add to favorites"
                    }
                    
                    self.locationManager.delegate = self
                    self.locationManager.requestWhenInUseAuthorization()
                    self.locationManager.startUpdatingLocation()
                    
                } else {

                    self.navigationItem.rightBarButtonItem = nil
          
                    let alert = AlertMessages.getSingleActionAlert("Route Unavailable", message: "", confirm: "OK", comfirmHandler: { action in
                        self.navigationController!.popViewController(animated: true)
                    })

                    self.present(alert, animated: true, completion: nil)
                }

            } else {
                self.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
            }
        })
    }
    
    // Method called by DepartureDaySelctionVC
    // Pass the selected day index from DepartureDaySelectionVC to the RouteTimesVC
    func daySelected(_ index: Int) {
        routeTimesVC.changeDay(index)
        dayButton.setTitle(routeTimesVC.dayData[routeTimesVC.currentDay], for: UIControl.State())
    }
    
    func terminalSelected(_ index: Int) {
        selectedTerminal = index
        let terminal = self.routeItem!.terminalPairs[index]
        routeTimesVC.changeTerminal(terminal)
        sailingButton.setTitle("\(terminal.aTerminalName) to \(terminal.bTterminalName)", for: UIControl.State())
        routeTimesVC.refresh(scrollToCurrentSailing: true)
        
        routeCamerasVC.departingTerminalId = terminal.aTerminalId
        routeCamerasVC.refresh(false)
    }
    
    // MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Save a reference to this VC for passing it days and sailings
        if segue.identifier == timesViewSegue {
            routeTimesVC = segue.destination as? RouteTimesViewController
            routeTimesVC.currentSailing = routeItem!.terminalPairs[0]
            routeTimesVC.sailingsByDate = routeItem!.scheduleDates

            // get the day title from container vc after set up
            dayButton.setTitle(routeTimesVC.dayData[routeTimesVC.currentDay], for: UIControl.State())
        }

        if segue.identifier == vesselWatchSegue {
            let dest: VesselWatchViewController = segue.destination as! VesselWatchViewController
            dest.routeId = routeId
        }

        if segue.identifier == camerasViewSegue {
            routeCamerasVC = segue.destination as? RouteCamerasViewController
            routeCamerasVC.departingTerminalId = getDepartingId()

        }

        if segue.identifier == segueDepartureDaySelectionViewController {
            let destinationViewController = segue.destination as! DepartureDaySelectionViewController
            destinationViewController.my_parent = self
            destinationViewController.menu_options = routeTimesVC.dayData
            destinationViewController.selectedIndex = routeTimesVC.currentDay
        }
    
        if segue.identifier == segueTerminalSelectionViewController {
            let destinationViewController = segue.destination as! TerminalSelectionViewController
            destinationViewController.my_parent = self
            let sailingsArray: Array = self.routeItem!.terminalPairs.map { return "\($0.aTerminalName) to \($0.bTterminalName)" }
            destinationViewController.menu_options = sailingsArray
            destinationViewController.selectedIndex = selectedTerminal
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
        } else if sender.selectedSegmentIndex == 2 {
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
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        } else if (isFavorite == 0) {
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        } else {
            print("favorites write error")
        }
    }
}

extension RouteDeparturesViewController: CLLocationManagerDelegate {
    
    // MARK: CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we can't get a location right away bail out of opertaion
        guard let usersLocation = manager.location else {
            manager.stopUpdatingLocation()
            return
        }
        
        let userLat: Double = usersLocation.coordinate.latitude
        let userLon: Double = usersLocation.coordinate.longitude
        
        // bail out if we don't have a route item set for some reason
        guard let route = routeItem else {
            manager.stopUpdatingLocation()
            return
        }

        // get map with terminal locations
        let terminalsMap = FerriesConsts.init().terminalMap
        
        // assume first terminal is closest
        var closetTerminalIndex = 0
        var nearestDistance = -1
        
        for (index, terminalPair) in route.terminalPairs.enumerated() {
            
            // check how close user is to terminal A in each pair
            let terminal = terminalsMap[terminalPair.aTerminalId]
            if let terminalAValue = terminal {
                
                let distanceA = LatLonUtils.haversine(userLat, lonA: userLon, latB: terminalAValue.latitude, lonB:terminalAValue.longitude)
                
                if distanceA < nearestDistance || nearestDistance < 0 {
                    nearestDistance = distanceA
                    closetTerminalIndex = index
                }
            }
        }

        terminalSelected(closetTerminalIndex)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
}
