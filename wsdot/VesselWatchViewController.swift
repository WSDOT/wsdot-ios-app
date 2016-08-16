//
//  VesselWatchViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/15/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds

class VesselWatchViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate{
    
    let SegueCamerasViewController = "CamerasViewController"
    
    private var embeddedMapViewController: MapViewController!
    private var terminalCameraMarkers = Set<GMSMarker>()
    
    private let cameraIconImage = UIImage(named: "icMapCamera")
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
        // Set defualt value for camera display if there is none
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras) == nil){
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.vesselCameras)
        }
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
    
    }
    
    @IBAction func myLocationButtonPressed(sender: UIBarButtonItem) {
        embeddedMapViewController.goToUsersLocation()
    }
    
    @IBAction func cameraToggleButtonPressed(sender: UIBarButtonItem) {
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                hideCameras()
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.vesselCameras)
            } else {
                showCameras()
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.vesselCameras)
            }
        }
    }
    
    func refreshAction(refreshControl: UIRefreshControl) {
        setup(true)
    }
    
    func setup(force: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            selfValue.setupCameraMarkers()
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
    
    func drawCameras(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
            
            if (camerasPref! == "on") {
                for cameraMaker in terminalCameraMarkers{
                    
                    let camera = cameraMaker.userData as! CameraItem
                    
                    let cameraLocation = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
                    
                    let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                    if (bounds.containsCoordinate(cameraLocation)){
                        cameraMaker.map = mapView
                    } else {
                        cameraMaker.map = nil
                    }
                }
            }
        }
    }
    
    func hideCameras(){
        for camera in terminalCameraMarkers{
            camera.map = nil
        }
    }
    
    func showCameras(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            for camera in terminalCameraMarkers{
                camera.map = mapView
            }
        }
    }
    

    
    func setupCameraMarkers(){
        
        terminalCameraMarkers.removeAll()

        for camera in CamerasStore.getCamerasByRoadName("Ferries"){
            let cameraLocation = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            let marker = GMSMarker(position: cameraLocation)
            marker.icon = cameraIconImage
            marker.userData = camera
            terminalCameraMarkers.insert(marker)
        }
        
    }
    
    // MARK: MapSuperViewController protocol method
    func drawOverlays(){
        setup(false)
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        return true
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        drawCameras()
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
