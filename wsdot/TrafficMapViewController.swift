//
//  TrafficMapViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/19/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import UIKit
import GoogleMaps
import GoogleMobileAds

class TrafficMapViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate {
    
    let SegueGoToPopover = "TrafficMapGoToViewController"
    let SegueSettingsPopover = "TrafficMapSettingsViewController"
    let SegueCamerasViewController = "CamerasViewController"
    
    private var cameraMarkers = Set<GMSMarker>()
    
    private let cameraIconImage = UIImage(named: "icMapCamera")
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var embeddedMapViewController: MapViewController!
    
    override func viewDidLoad() {
        
        title = "Traffic Map"
        
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
    
    @IBAction func goToLocation(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueGoToPopover, sender: self)
    }
    
    @IBAction func settingsAction(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueSettingsPopover, sender: self)
    }
    
    
    
    func goTo(index: Int){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            switch(index){
            case 0:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 48.756302, longitude: -122.46151)) // Bellingham
                mapView.animateToZoom(12)
                break
            case 1:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 46.635529, longitude: -122.937698)) // Chelalis
                mapView.animateToZoom(11)
                break
            case 2:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.85268, longitude: -122.628365)) // Hood Canal
                mapView.animateToZoom(13)
                break
            case 3:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.859476, longitude: -121.972446)) // Monroe
                mapView.animateToZoom(14)
                break
            case 4:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 48.420657, longitude: -122.334824)) // Mt Vernon
                mapView.animateToZoom(13)
                break
            case 5:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.021461, longitude: -122.899933)) // Olympia
                mapView.animateToZoom(13)
                break
            case 6:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.5990, longitude: -122.3350)) // Seattle
                mapView.animateToZoom(12)
                break
            case 7:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.404481, longitude: -121.4232569)) // Snoqualmie Pass
                mapView.animateToZoom(12)
                break
            case 8:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.658566, longitude: -117.425995)) // Spokane
                mapView.animateToZoom(12)
                break
            case 9:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 48.22959, longitude: -122.34581)) //Stanwood
                mapView.animateToZoom(13)
                break
            case 10:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.86034, longitude: -121.812286)) // Sultan
                mapView.animateToZoom(13)
                break
            case 11:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.206275, longitude: -122.46254)) // Tacoma
                mapView.animateToZoom(12)
                break
            case 12:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 46.2503607, longitude: -119.2063781)) // Tri-Cities
                mapView.animateToZoom(11)
                break
            case 13:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 45.639968, longitude: -122.610512)) // Vancouver
                mapView.animateToZoom(11)
                break
            case 14:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 47.435867, longitude: -120.309563)) // Wenatchee
                mapView.animateToZoom(12)
                break
            case 15:
                mapView.animateToLocation(CLLocationCoordinate2D(latitude: 46.6063273, longitude: -120.4886952)) // Takima
                mapView.animateToZoom(11)
                break
            default:
                break
            }
        }
    }
    
    func removeCameras(){
        for camera in cameraMarkers{
            camera.map = nil
        }
    }
    
    func fetchCameras(force: Bool, serviceGroup: dispatch_group_t) {
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            dispatch_group_leave(serviceGroup)
                            selfValue.loadCameraMarkers()
                            selfValue.drawCameras()
                            
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            dispatch_group_leave(serviceGroup)
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func loadCameraMarkers(){
        
        removeCameras()
        cameraMarkers.removeAll()
        
        for camera in CamerasStore.getAllCameras(){
            let cameraLocation = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            let marker = GMSMarker(position: cameraLocation)
            marker.snippet = "camera"
            marker.icon = cameraIconImage
            marker.userData = camera
            cameraMarkers.insert(marker)
        }
    }
    
    func drawCameras(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.vesselCameras)
            
            if (camerasPref! == "on") {
                for cameraMarker in cameraMarkers{
                    
                    let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                    
                    if (bounds.containsCoordinate(cameraMarker.position)){
                        cameraMarker.map = mapView
                    } else {
                        cameraMarker.map = nil
                    }
                }
            }
        }
    }
    
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        drawCameras()
    }
    
    // MARK: MapMarkerViewController protocol method
    func drawOverlays(){
        
        activityIndicatorView.startAnimating()
        let serviceGroup = dispatch_group_create();
        
        fetchCameras(false, serviceGroup: serviceGroup)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
        }
        
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        if marker.snippet == "camera" {
            performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        }
        return true
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
        
        if segue.identifier == SegueGoToPopover {
            let destinationViewController = segue.destinationViewController as! TrafficMapGoToViewController
            destinationViewController.parent = self
        }
        
        if segue.identifier == SegueSettingsPopover {
            let destinationViewController = segue.destinationViewController as! TrafficMapSettingsViewController
            destinationViewController.parent = self
        }
    }
}