//
//  VesselWatchViewController.swift
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
import GoogleMaps
import GoogleMobileAds

class VesselWatchViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate, GADBannerViewDelegate{
    
    let serviceGroup = DispatchGroup()
    
    let SegueCamerasViewController = "CamerasViewController"
    let SegueVesselDetailsViewController = "VesselDetailsViewController"
    let SegueGoToPopover = "GoToViewController"

    fileprivate weak var timer: Timer?

    fileprivate weak var embeddedMapViewController: MapViewController!
    
    fileprivate var terminalCameraMarkers = Set<GMSMarker>()
    fileprivate var vesselMarkers = Set<GMSMarker>()
    
    fileprivate let cameraIconImage = UIImage(named: "icMapCamera")
    
    fileprivate let cameraBarButtonImage = UIImage(named: "icCamera")
    fileprivate let cameraHighlightBarButtonImage = UIImage(named: "icCameraHighlight")
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myLocationBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
        // Set defualt value for camera display if there is none
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.cameras)
        }
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras) == "on"){
            cameraBarButton.image = cameraHighlightBarButtonImage
        }
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        if self.isBeingDismissed || self.isMovingFromParentViewController {
            print("invalidating timer")
            if timer != nil {
                self.timer?.invalidate()
            }
        }

    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Ferries/VesselWatch")
    }
    
    @IBAction func goToLocation(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueGoToPopover, sender: self)
    }
    
    func goTo(_ index: Int){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            switch(index){
            case 0:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 48.535868, longitude: -123.013808, zoom: 10)))
                break
            case 1:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.803096, longitude: -122.438718, zoom: 12)))
                break
            case 2:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.513625, longitude: -122.450820, zoom: 12)))
                break
            case 3:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.963857, longitude: -122.327721, zoom: 13)))
                break
            case 4:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.319040, longitude: -122.510890, zoom: 13)))
                break
            case 5:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 48.135562, longitude: -122.714449, zoom: 12)))
                break
            case 6:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 48.557233, longitude: -122.897078, zoom: 12)))
                break
            case 7:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.565125, longitude: -122.480508, zoom: 11)))
                break
            case 8:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.600325, longitude: -122.437249, zoom: 11)))
                break
            default:
                break
            }
        }
    }
    
    @IBAction func myLocationButtonPressed(_ sender: UIBarButtonItem) {
    
        GoogleAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "My Location")
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            embeddedMapViewController.goToUsersLocation()
        } else if !CLLocationManager.locationServicesEnabled() {
            self.present(AlertMessages.getAlert("Location Services Are Disabled", message: "You can enable location services from Settings."), animated: true, completion: nil)
        } else if CLLocationManager.authorizationStatus() == .denied {
            self.present(AlertMessages.getAlert("\"WSDOT\" Doesn't Have Permission To Use Your Location", message: "You can enable location services for this app in Settings"), animated: true, completion: nil)
        } else {
            CLLocationManager().requestWhenInUseAuthorization()
        }
 
    }
    
    @IBAction func cameraToggleButtonPressed(_ sender: UIBarButtonItem) {
        let camerasPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.cameras)
                sender.image = cameraBarButtonImage
                removeCameras()
                
            } else {
                sender.image = cameraHighlightBarButtonImage
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.cameras)
                drawCameras()
            }
        }
    }
    
    func removeCameras(){
        for camera in terminalCameraMarkers{
            camera.map = nil
        }
    }
    
    func fetchCameras(_ force: Bool) {
        serviceGroup.enter()
        DispatchQueue.global().async {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    DispatchQueue.main.async {[weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                            selfValue.loadCameraMarkers()
                            selfValue.drawCameras()
                            
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func loadCameraMarkers(){
        removeCameras()
        terminalCameraMarkers.removeAll()
        
        for camera in CamerasStore.getCamerasByRoadName("Ferries"){
            let cameraLocation = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            let marker = GMSMarker(position: cameraLocation)
            marker.snippet = "camera"
            marker.zIndex = 0
            marker.icon = cameraIconImage
            marker.userData = camera
            terminalCameraMarkers.insert(marker)
        }
    }
    
    func drawCameras(){
        if embeddedMapViewController != nil {
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                let camerasPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras)
            
                if (camerasPref! == "on") {
                    for cameraMarker in terminalCameraMarkers{
                        cameraMarker.map = mapView
                    }
                }
            }
        }
    }
    
    func fetchVessels(_ updateWithGroup: Bool){
        
        if updateWithGroup{
            serviceGroup.enter()
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            VesselWatchStore.getVessels({ data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.loadVesselMarkers(validData)
                            selfValue.drawVessels()
                            if updateWithGroup{
                                selfValue.serviceGroup.leave()

                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            if updateWithGroup{
                                selfValue.serviceGroup.leave()
                            }
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
                
            })
        }
    }
    
    func loadVesselMarkers(_ vesselItems: [VesselItem]){
        
        removeVessels()
        vesselMarkers.removeAll()
        
        for vessel in vesselItems {
            if (vessel.inService && vessel.route != "Not available"){
                let vesselLocation = CLLocationCoordinate2D(latitude: vessel.lat, longitude: vessel.lon)
                let marker = GMSMarker(position: vesselLocation)
                marker.snippet = "vessel"
                marker.zIndex = 1
                marker.icon = vessel.icon
                marker.userData = vessel
                vesselMarkers.insert(marker)
            }
        }
    }

    func removeVessels(){
        for vessel in vesselMarkers{
            vessel.map = nil
        }
    }

    func drawVessels(){
        if embeddedMapViewController != nil {
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                for vesselMarker in vesselMarkers{
                    vesselMarker.map = mapView
                }
            }
        }
    }
    
    func vesselUpdateTask(_ timer:Timer) {
        fetchVessels(false)
    }
    
    // MARK: MapMarkerViewController protocol method
    func drawOverlays(){
    
        activityIndicator.startAnimating()
        
        fetchVessels(true)
        fetchCameras(false)

        serviceGroup.notify(queue: DispatchQueue.main) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.timer = Timer.scheduledTimer(timeInterval: TimeUtils.vesselUpdateTime, target: self, selector: #selector(VesselWatchViewController.vesselUpdateTask(_:)), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker.snippet == "camera" {
            performSegue(withIdentifier: SegueCamerasViewController, sender: marker)
        }else if marker.snippet == "vessel" {
            performSegue(withIdentifier: SegueVesselDetailsViewController, sender: marker)
        }
        return true
    }
    
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
        serviceGroup.enter()
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        serviceGroup.leave()
    }
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapViewController, segue.identifier == "EmbedMapSegue" {
            vc.markerDelegate = self
            vc.mapDelegate = self
            self.embeddedMapViewController = vc
        }
        
        if segue.identifier == SegueCamerasViewController {
            let cameraItem = ((sender as! GMSMarker).userData as! CameraItem)
            let destinationViewController = segue.destination as! CameraViewController
            destinationViewController.cameraItem = cameraItem
        }
        
        if segue.identifier == SegueVesselDetailsViewController {
            let vesselItem = ((sender as! GMSMarker).userData as! VesselItem)
            let destinationViewController = segue.destination as! VesselDetailsViewController
            destinationViewController.vesselItem = vesselItem
        }
        
        if segue.identifier == SegueGoToPopover {
            let destinationViewController = segue.destination as! VesselWatchGoToViewController
            destinationViewController.my_parent = self
        }
    }
}
