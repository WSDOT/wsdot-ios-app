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
    
    // MapSuperViewController protocol method
    func drawOverlays(){
        drawCameras()
    }
    
    func drawCameras(){
        
        terminalCameraMarkers.removeAll()
        
        // Set defualt value for camera display if there is none
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras) == nil){
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.vesselCameras)
        }
        
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            for camera in CamerasStore.getCamerasByRoadName("Ferries"){
                let cameraLocation = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
                let marker = GMSMarker(position: cameraLocation)
                marker.icon = cameraIconImage
                marker.userData = camera
                if (camerasPref! == "on") {
                    marker.map = mapView
                }
                terminalCameraMarkers.insert(marker)
            }
        }
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        return true
    }
    
    
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
