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
    
    let serviceGroup = dispatch_group_create()
    
    let SegueCamerasViewController = "CamerasViewController"
    let SegueVesselDetailsViewController = "VesselDetailsViewController"
    let SegueGoToPopover = "GoToViewController"

    private var timer: NSTimer?

    private var embeddedMapViewController: MapViewController!
    
    private var terminalCameraMarkers = Set<GMSMarker>()
    private var vesselMarkers = Set<GMSMarker>()
    
    private let cameraIconImage = UIImage(named: "icMapCamera")
    
    private let cameraBarButtonImage = UIImage(named: "icCamera")
    private let cameraHighlightBarButtonImage = UIImage(named: "icCameraHighlight")
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myLocationBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
        // Set defualt value for camera display if there is none
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras) == nil){
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.cameras)
        }
        
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras) == "on"){
            cameraBarButton.image = cameraHighlightBarButtonImage
        }
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        bannerView.delegate = self
        
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Ferries/VesselWatch")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @IBAction func goToLocation(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueGoToPopover, sender: self)
    }
    
    func goTo(index: Int){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            switch(index){
            case 0:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(48.535868, longitude: -123.013808, zoom: 10)))
                break
            case 1:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.803096, longitude: -122.438718, zoom: 12)))
                break
            case 2:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.513625, longitude: -122.450820, zoom: 12)))
                break
            case 3:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.963857, longitude: -122.327721, zoom: 13)))
                break
            case 4:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.319040, longitude: -122.510890, zoom: 13)))
                break
            case 5:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(48.135562, longitude: -122.714449, zoom: 12)))
                break
            case 6:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(48.557233, longitude: -122.897078, zoom: 12)))
                break
            case 7:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.565125, longitude: -122.480508, zoom: 11)))
                break
            case 8:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.600325, longitude: -122.437249, zoom: 11)))
                break
            default:
                break
            }
        }
    }
    
    @IBAction func myLocationButtonPressed(sender: UIBarButtonItem) {
    
        GoogleAnalytics.event("Vessel Watch", action: "UIAction", label: "My Location")
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse{
            embeddedMapViewController.goToUsersLocation()
        } else if !CLLocationManager.locationServicesEnabled() {
            self.presentViewController(AlertMessages.getAlert("Location Services Are Disabled", message: "You can enable location services from Settings."), animated: true, completion: nil)
        } else if CLLocationManager.authorizationStatus() == .Denied {
            self.presentViewController(AlertMessages.getAlert("\"WSDOT\" Doesn't Have Permission To Use Your Location", message: "You can enable location services for this app in Settings"), animated: true, completion: nil)
        } else {
            CLLocationManager().requestWhenInUseAuthorization()
        }
 
    }
    
    @IBAction func cameraToggleButtonPressed(sender: UIBarButtonItem) {
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.cameras)
                sender.image = cameraBarButtonImage
                removeCameras()
                
            } else {
                sender.image = cameraHighlightBarButtonImage
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.cameras)
                drawCameras()
            }
        }
    }
    
    func removeCameras(){
        for camera in terminalCameraMarkers{
            camera.map = nil
        }
    }
    
    func fetchCameras(force: Bool) {
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            dispatch_group_leave(selfValue.serviceGroup)
                            selfValue.loadCameraMarkers()
                            selfValue.drawCameras()
                            
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            dispatch_group_leave(selfValue.serviceGroup)
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
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
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras)
            
            if (camerasPref! == "on") {
                for cameraMarker in terminalCameraMarkers{
                    cameraMarker.map = mapView
                }
            }
        }
    }
    
    func fetchVessels(updateWithGroup: Bool){
        
        if updateWithGroup{
            dispatch_group_enter(serviceGroup)
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            VesselWatchStore.getVessels({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.loadVesselMarkers(validData)
                            selfValue.drawVessels()
                            if updateWithGroup{
                                dispatch_group_leave(selfValue.serviceGroup)

                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            if updateWithGroup{
                                dispatch_group_leave(selfValue.serviceGroup)
                            }
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
                
            })
        }
    }
    
    func loadVesselMarkers(vesselItems: [VesselItem]){
        
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
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            for vesselMarker in vesselMarkers{
                vesselMarker.map = mapView
            }
        }
    }
    
    func vesselUpdateTask(timer:NSTimer) {
        fetchVessels(false)
    }
    
    // MARK: MapMarkerViewController protocol method
    func drawOverlays(){
    
        activityIndicator.startAnimating()
        
        fetchVessels(true)
        fetchCameras(false)

        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            self.timer = NSTimer.scheduledTimerWithTimeInterval(TimeUtils.vesselUpdateTime, target: self, selector: #selector(VesselWatchViewController.vesselUpdateTask(_:)), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        if marker.snippet == "camera" {
            performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        }else if marker.snippet == "vessel" {
            performSegueWithIdentifier(SegueVesselDetailsViewController, sender: marker)
        }
        return true
    }
    
    func mapViewDidStartTileRendering(mapView: GMSMapView) {
        dispatch_group_enter(serviceGroup)
    }
    
    func mapViewDidFinishTileRendering(mapView: GMSMapView) {
        dispatch_group_leave(serviceGroup)
    }
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MapViewController
            where segue.identifier == "EmbedMapSegue" {
            vc.markerDelegate = self
            vc.mapDelegate = self
            self.embeddedMapViewController = vc
        }
        
        if segue.identifier == SegueCamerasViewController {
            let cameraItem = ((sender as! GMSMarker).userData as! CameraItem)
            let destinationViewController = segue.destinationViewController as! CameraViewController
            destinationViewController.cameraItem = cameraItem
        }
        
        if segue.identifier == SegueVesselDetailsViewController {
            let vesselItem = ((sender as! GMSMarker).userData as! VesselItem)
            let destinationViewController = segue.destinationViewController as! VesselDetailsViewController
            destinationViewController.vesselItem = vesselItem
        }
        
        if segue.identifier == SegueGoToPopover {
            let destinationViewController = segue.destinationViewController as! VesselWatchGoToViewController
            destinationViewController.parent = self
        }
    }
}
