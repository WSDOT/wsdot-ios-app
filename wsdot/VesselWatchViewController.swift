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
    let SegueVesselDetailsViewController = "VesselDetailsViewController"
    let SegueGoToPopover = "GoToViewController"

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
    
    @IBAction func goToLocation(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier(SegueGoToPopover, sender: self)
    }
    
    func goTo(index: Int){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            switch(index){
            case 0:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 48.535868, longitude: -123.013808))
                mapView.animateToZoom(10)
                break
            case 1:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.803096, longitude: -122.438718))
                mapView.animateToZoom(12)
                break
            case 2:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.513625, longitude: -122.450820))
                mapView.animateToZoom(12)
                break
            case 3:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.963857, longitude: -122.327721))
                mapView.animateToZoom(13)
                break
            case 4:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.319040, longitude: -122.510890))
                mapView.animateToZoom(13)
                break
            case 5:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 48.135562, longitude: -122.714449))
                mapView.animateToZoom(12)
                break
            case 6:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 48.557233, longitude: -122.897078))
                mapView.animateToZoom(12)
                break
            case 7:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.565125, longitude: -122.480508))
                mapView.animateToZoom(11)
                break
            case 8:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.600325, longitude: -122.437249))
                mapView.animateToZoom(11)
                break
            default:
                break
            }
        }
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
    
        if marker.snippet == "camera" {
            performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        }else if marker.snippet == "vessel" {
            performSegueWithIdentifier(SegueVesselDetailsViewController, sender: marker)
        }
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
        
        if segue.identifier == SegueVesselDetailsViewController {
            let vesselItem = ((sender as! GMSMarker).userData as! VesselItem)
            let destinationViewController = segue.destinationViewController as! VesselDetailsViewController
            destinationViewController.vesselItem = vesselItem
        }
        
        if segue.identifier == SegueGoToPopover {
            let destinationViewController = segue.destinationViewController as! GoToViewController
            destinationViewController.parent = self
        }
    }
}
