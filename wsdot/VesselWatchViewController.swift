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
    fileprivate var labelMarkers = Set<GMSMarker>()
    fileprivate var terminalMarkers = Set<GMSMarker>()

    fileprivate let cameraIconImage = UIImage(named: "icMapCamera")
    
    fileprivate let terminalImage = UIImage(named: "terminal")

    fileprivate let cameraBarButtonImage = UIImage(named: "icCamera")
    fileprivate let cameraHighlightBarButtonImage = UIImage(named: "icCameraHighlight")
    
    fileprivate let vesselNames = ["Cathlamet":"CAT", "Chelan":"CHE", "Chetzemoka":"CHZ", "Issaquah":"ISS", "Kaleetan":"KAL", "Kennewick":"KEN", "Kitsap":"KIS", "Kittitas":"KIT", "Puyallup":"PUY", "Salish":"SAL", "Samish":"SAM", "Sealth":"SEA", "Spokane":"SPO", "Suquamish":"SUQ", "Tacoma":"TAC", "Tillikum":"TIL", "Tokitae":"TOK", "Walla Walla":"WAL", "Yakima":"YAK"]

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myLocationBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vessel Watch"
        
        ferryTrafficLayer()
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryVesselLayer) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryVesselLayer)
        }
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryLabelLayer) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryLabelLayer)
        }
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTerminalLayer) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryTerminalLayer)
        }
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryCameraLayer) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryCameraLayer)
        }
                
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent {
            if timer != nil {
                self.timer?.invalidate()
            }
        }
    }

    func adViewDidReceiveAd(_ bannerView: BannerView) {
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
    
    
    func ferryTrafficLayer() {
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTrafficLayer) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryTrafficLayer)
        }
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let trafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTrafficLayer)
            if let trafficLayerVisible = trafficLayerPref {
                if (trafficLayerVisible == "on") {
                    UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryTrafficLayer)
                    mapView.isTrafficEnabled = true
                } else {
                    UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryTrafficLayer)
                    mapView.isTrafficEnabled = false
                }
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
            marker.zIndex = 2
            marker.icon = cameraIconImage
            marker.userData = camera
            terminalCameraMarkers.insert(marker)
        }
    }
    
    func drawCameras(){
        if embeddedMapViewController != nil {
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                let camerasPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryCameraLayer)
            
                if (camerasPref == "on") {
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
                            selfValue.loadLabelMarkers(validData)
                            selfValue.drawVessels()
                            selfValue.drawLabels()
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
            if (vessel.inService && vessel.route != "Not Available"){
                let vesselLocation = CLLocationCoordinate2D(latitude: vessel.lat, longitude: vessel.lon)
                let marker = GMSMarker(position: vesselLocation)
                marker.snippet = "vessel"
                marker.zIndex = 3
                marker.icon = vessel.icon
                marker.userData = vessel
                vesselMarkers.insert(marker)

            }
        }
    }
    
    func loadLabelMarkers(_ vesselItems: [VesselItem]){
        
        removeLabels()
        labelMarkers.removeAll()
        
        for vessel in vesselItems {
            if (vessel.inService && vessel.route != "Not Available"){
                let vesselLocation = CLLocationCoordinate2D(latitude: vessel.lat, longitude: vessel.lon)
                
                let labelMarker = GMSMarker(position: vesselLocation)
                let label = UILabel()
                
                if let vessel = vesselNames[vessel.vesselName] {
                    label.text = vessel
                    label.backgroundColor = .white
                    label.textColor = UIColor.black
                    label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
                    label.layer.cornerRadius = 1
                    label.layer.masksToBounds = true
                    label.sizeToFit()
                }
                
                labelMarker.iconView = label
                labelMarker.snippet = "vessel"
                labelMarker.zIndex = 3
                labelMarker.userData = vessel
                labelMarker.groundAnchor = CGPointMake(0.5, -0.5)

                labelMarkers.insert(labelMarker)

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
                let vesselPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryVesselLayer)
                if (vesselPref == "on") {
                    for vesselMarker in vesselMarkers{
                        vesselMarker.map = mapView
                    }
                }
            }
        }
    }
    
    func removeLabels() {
        for vessel in labelMarkers {
            vessel.map = nil
        }
    }

    func drawLabels(){
        if embeddedMapViewController != nil {
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                let labelPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryLabelLayer)
                if (labelPref == "on") {
                    for labelMarker in labelMarkers{
                        labelMarker.map = mapView
                    }
                }
            }
        }
    }
    
    
    @objc func vesselUpdateTask(_ timer:Timer) {
        fetchVessels(false)
    }
    
    func removeTerminals(){
            for terminal in terminalMarkers{
                terminal.map = nil
            }
        }
        
    func fetchTerminals(_ force: Bool) {
        loadTerminalMarkers()
        drawTerminals()
    }
        
        func loadTerminalMarkers(){
            removeTerminals()
            terminalMarkers.removeAll()
            
         // get map with terminal locations
            let terminalsMap = FerriesConsts.init().terminalMap
            for terminal in terminalsMap.values {
                let terminalLocation = CLLocationCoordinate2D(latitude: terminal.latitude, longitude: terminal.longitude)
                let marker = GMSMarker(position: terminalLocation)
                marker.snippet = "terminal"
                marker.zIndex = 1
                marker.icon = terminalImage
                marker.userData = terminal
                terminalMarkers.insert(marker)
            }
        }
        
        func drawTerminals(){
            if embeddedMapViewController != nil {
                if let mapView = embeddedMapViewController.view as? GMSMapView{
                    let terminalPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTerminalLayer)
                
                    if (terminalPref == "on") {
                        for terminalMarker in terminalMarkers{
                            terminalMarker.map = mapView
                        }
                    }
                }
            }
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
        fetchTerminals(true)

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
