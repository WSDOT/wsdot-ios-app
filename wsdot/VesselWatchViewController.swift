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

class VesselWatchViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate {
    
    let serviceGroup = DispatchGroup()
    
    let SegueCamerasViewController = "CamerasViewController"
    let SegueVesselDetailsViewController = "VesselDetailsViewController"
    let SegueSettingsPopover = "VesselWatchSettingsViewController"

    var routeId: Int = -1

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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent {
            if timer != nil {
                self.timer?.invalidate()
            }
        }
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "VesselWatch")
    }
    
    @IBAction func myLocationButtonPressed(_ sender: UIBarButtonItem) {
        MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "My Location")
        embeddedMapViewController.goToUsersLocation()
    }
    
    @IBAction func mapSettingsButtonPressed(_ sender: UIBarButtonItem) {
        MyAnalytics.event(category: "Vessel Watch", action: "UIAction", label: "Map Settings")
        performSegue(withIdentifier: SegueSettingsPopover, sender: self)
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.vesselWatch, message: WSDOTErrorStrings.cameras)
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.vesselWatch, message: WSDOTErrorStrings.vessels)
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

    func removeVessels() {
        for vessel in vesselMarkers {
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
    
    @objc func vesselUpdateTask(_ timer:Timer) {
        fetchVessels(false)
    }
    
    // MARK: MapMarkerViewController protocol method
    func mapReady() {

        if embeddedMapViewController != nil {
        
            let location = VesselWatchStore.getRouteLocation(scheduleId: routeId)
            let zoom = VesselWatchStore.getRouteZoom(scheduleId: routeId)
            
            embeddedMapViewController.goToLocation(location: location, zoom: zoom)
  
        }
        
        activityIndicator.startAnimating()

        fetchVessels(true)
        fetchCameras(false)

        serviceGroup.notify(queue: DispatchQueue.main) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.timer = Timer.scheduledTimer(timeInterval: CachesStore.vesselUpdateTime, target: self, selector: #selector(VesselWatchViewController.vesselUpdateTask(_:)), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker.snippet == "camera" {
            performSegue(withIdentifier: SegueCamerasViewController, sender: marker)
        } else if marker.snippet == "vessel" {
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
    
    func resetMapStyle() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            MapThemeUtils.setMapStyle(mapView, traitCollection)
        }
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
            destinationViewController.adTarget = "ferries"
        }
        
        if segue.identifier == SegueVesselDetailsViewController {
            let vesselItem = ((sender as! GMSMarker).userData as! VesselItem)
            let destinationViewController = segue.destination as! VesselDetailsViewController
            destinationViewController.vesselItem = vesselItem
        }
        
        if segue.identifier == SegueSettingsPopover {
            let destinationViewController = segue.destination as! VesselWatchSettingsViewController
            destinationViewController.my_parent = self
        }
    
    }
}
