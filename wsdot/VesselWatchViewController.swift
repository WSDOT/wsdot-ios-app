//
//  VesselWatchViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/15/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GoogleMobileAds

class VesselWatchViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate{
    
    let SegueCamerasViewController = "CamerasViewController"

    private var timer: NSTimer?

    private var embeddedMapViewController: MapViewController!
    
    private var terminalCameraMarkers = Set<GMSMarker>()
    private var vesselMarkers = Set<GMSMarker>()
    
    private let cameraIconImage = UIImage(named: "icMapCamera")
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
        // Set defualt value for camera display if there is none
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras) == nil){
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.vesselCameras)
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(VesselWatchViewController.vesselUpdateTask(_:)), userInfo: nil, repeats: true)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer?.invalidate()
    }
    
    @IBAction func myLocationButtonPressed(sender: UIBarButtonItem) {
        embeddedMapViewController.goToUsersLocation()
    }
    
    @IBAction func cameraToggleButtonPressed(sender: UIBarButtonItem) {
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.vesselCameras)
                removeCameras()
                
            } else {
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.vesselCameras)
                drawCameras()
            }
        }
    }
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        setupCameras(true)
    }
    
    func removeCameras(){
        for camera in terminalCameraMarkers{
            camera.map = nil
        }
    }
    
    func setupCameras(force: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            selfValue.loadCameraMarkers()
                            selfValue.drawCameras()
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
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
            let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
            
            if (camerasPref! == "on") {
                for cameraMarker in terminalCameraMarkers{
                    /*
                    let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
            
                    if (bounds.containsCoordinate(cameraMarker.position)){
                        cameraMarker.map = mapView
                    } else {
                        cameraMarker.map = nil
                    }
                    */
                    cameraMarker.map = mapView
                }
            }
        }
    }
    
    func setupVessels(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            VesselWatchStore.getVessels({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.loadVesselMarkers(validData)
                            selfValue.drawVessels()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
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
            if (vessel.inService){
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
        setupVessels()
    }
    
    
    // MARK: MapSuperViewController protocol method
    func drawOverlays(){
        setupCameras(false)
        setupVessels()
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        return true
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        drawCameras()
        drawVessels()
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
    }
}
