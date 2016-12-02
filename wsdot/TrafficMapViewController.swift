//
//  TrafficMapViewController.swift
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
import UIKit
import GoogleMaps
import GoogleMobileAds

class TrafficMapViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate, GMUClusterManagerDelegate, GADBannerViewDelegate {
    
    let serviceGroup = DispatchGroup()
    
    let SegueGoToPopover = "TrafficMapGoToViewController"
    let SegueAlertsInArea = "AlertsInAreaViewController"
    let SegueSettingsPopover = "TrafficMapSettingsViewController"
    let SegueTravlerInfoViewController = "TravelerInfoViewController"
    let SegueCameraClusterViewController = "CameraClusterViewController"
    
    // Marker Segues
    let SegueCamerasViewController = "CamerasViewController"
    let SegueRestAreaViewController = "RestAreaViewController"
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    let SegueCalloutViewController = "CalloutViewController"
    
    fileprivate var alertMarkers = Set<GMSMarker>()
    fileprivate var cameraMarkers = Set<CameraClusterItem>()
    fileprivate var restAreaMarkers = Set<GMSMarker>()
    
    fileprivate let JBLMMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 47.103033, longitude: -122.584394))
    
    // Mark: Map Icons
    fileprivate let restAreaIconImage = UIImage(named: "icMapRestArea")
    fileprivate let restAreaDumpIconImage = UIImage(named: "icMapRestAreaDump")
    
    fileprivate let cameraIconImage = UIImage(named: "icMapCamera")
    
    fileprivate let cameraBarButtonImage = UIImage(named: "icCamera")
    fileprivate let cameraHighlightBarButtonImage = UIImage(named: "icCameraHighlight")
    
    fileprivate let alertHighIconImage = UIImage(named: "icMapAlertHigh")
    fileprivate let alertHighestIconImage = UIImage(named: "icMapAlertHighest")
    fileprivate let alertModerateIconImage = UIImage(named: "icMapAlertModerate")
    
    fileprivate let constructionHighIconImage = UIImage(named: "icMapConstructionHigh")
    fileprivate let constructionHighestIconImage = UIImage(named: "icMapConstructionHighest")
    fileprivate let constructionModerateIconImage = UIImage(named: "icMapConstructionModerate")
    
    fileprivate let closedIconImage = UIImage(named: "icMapClosed")
    
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    weak fileprivate var embeddedMapViewController: MapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set defualt value for camera display if there is none
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.cameras)
        }
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras) == "on"){
            cameraBarButton.image = cameraHighlightBarButtonImage
        }
        
        JBLMMarker.icon = UIImage(named: "icMapJBLM")
        JBLMMarker.snippet = "jblm"
        JBLMMarker.userData = "http://images.wsdot.wa.gov/traffic/flowmaps/jblm.png"
        
        self.loadCameraMarkers()
        self.drawCameras()
        self.loadAlertMarkers()
        self.drawAlerts()
        
        embeddedMapViewController.clusterManager.setDelegate(self, mapDelegate: self)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map")
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
    
        GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Refresh")
    
        self.activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        let serviceGroup = DispatchGroup();
        
        fetchCameras(true)
        fetchAlerts(true)
        
        serviceGroup.notify(queue: DispatchQueue.main) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    
    @IBAction func myLocationButtonPressed(_ sender: UIBarButtonItem) {
        GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "My Location")
        embeddedMapViewController.goToUsersLocation()
    }
    
    @IBAction func alertsInAreaButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueAlertsInArea, sender: self)
    }
    
    @IBAction func goToLocation(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueGoToPopover, sender: self)
    }
    
    @IBAction func cameraToggleButtonPressed(_ sender: UIBarButtonItem) {
        let camerasPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Hide Cameras")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.cameras)
                sender.image = cameraBarButtonImage
                removeCameras()
            } else {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Show Cameras")
                sender.image = cameraHighlightBarButtonImage
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.cameras)
                drawCameras()
            }
        }
    }
    
    @IBAction func travelerInfoAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueTravlerInfoViewController, sender: self)
    }

    @IBAction func settingsAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueSettingsPopover, sender: self)
    }
    
    // zoom in and out to reload icons for when clustering is toggled
    func resetMapCamera() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let camera = mapView.camera
            let camera2 = GMSCameraPosition.camera(withLatitude: camera.target.latitude, longitude: camera.target.longitude, zoom: camera.zoom - 1.0)
            mapView.moveCamera(GMSCameraUpdate.setCamera(camera2))
            mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
        }
    }
    
    func goTo(_ index: Int){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            switch(index){
            case 0:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 48.756302, longitude: -122.46151, zoom: 12))) // Bellingham
                break
            case 1:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 46.635529, longitude: -122.937698, zoom: 11))) // Chehalis
                break
            case 2:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.85268, longitude: -122.628365, zoom: 13))) // Hood Canal
                break
            case 3:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.859476, longitude: -121.972446, zoom: 13))) // Monroe
                break
            case 4:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 48.420657, longitude: -122.334824, zoom: 13))) // Mt Vernon
                break
            case 5:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.021461, longitude: -122.899933, zoom: 13))) // Olympia
                break
            case 6:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.5990, longitude: -122.3350, zoom: 12))) // Seattle
                break
            case 7:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.404481, longitude: -121.4232569, zoom: 12))) // Snoqualmie Pass
                break
            case 8:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.658566, longitude: -117.425995, zoom: 12))) // Spokane
                break
            case 9:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 48.22959, longitude: -122.34581, zoom: 13))) // Stanwood
                break
            case 10:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.86034, longitude: -121.812286, zoom: 13))) // Sultan
                break
            case 11:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.206275, longitude: -122.46254, zoom: 12))) // Tacoma
                break
            case 12:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 46.2503607, longitude: -119.2063781, zoom: 11))) // Tri-Cities
                break
            case 13:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 45.639968, longitude: -122.610512, zoom: 11))) // Vancouver
                break
            case 14:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 47.435867, longitude: -120.309563, zoom: 12))) // Wenatchee
                break
            case 15:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: 46.6063273, longitude: -120.4886952, zoom: 11))) // Takima
                break
            default:
                break
            }
        }
    }
    
    func fetchCameras(_ force: Bool) {
        serviceGroup.enter()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {[weak self] in
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
    
    // MARK: Camera marker logic
    func loadCameraMarkers(){
        
        removeCameras()
        cameraMarkers.removeAll()
        
        let cameras = CamerasStore.getAllCameras()
        for camera in cameras{
            let position = CLLocationCoordinate2D(latitude: camera.latitude, longitude: camera.longitude)
            cameraMarkers.insert(CameraClusterItem(position: position, name: "camera", camera: camera))
        }
        
    }
    
    func drawCameras(){
        let camerasPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras)

        if (camerasPref! == "on") {
            for camera in cameraMarkers {
                embeddedMapViewController.addClusterableMarker(camera)
            }
            embeddedMapViewController.clusterReady()
        }
    }
    
    func removeCameras(){
        embeddedMapViewController.removeClusterItems()
    }
    
    // MARK: Alerts marker logic
    func removeAlerts(){
        for alert in alertMarkers{
           alert.map = nil
        }
    }
    
    func fetchAlerts(_ force: Bool) {
        serviceGroup.enter()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {[weak self] in
            HighwayAlertsStore.updateAlerts(force, completion: { error in
                if (error == nil){
                    DispatchQueue.main.async {[weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                            selfValue.loadAlertMarkers()
                            selfValue.drawAlerts()
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
    
    func loadAlertMarkers(){
        
        removeAlerts()
        alertMarkers.removeAll()
        
        for alert in HighwayAlertsStore.getAllAlerts(){
            
            var alertEnded = false
            
            if let alertEndTimeValue = alert.endTime{
                if alertEndTimeValue.timeIntervalSince1970 < Date().timeIntervalSince1970{
                    alertEnded = true
                }
            }
            
            if (alert.startTime.timeIntervalSince1970 < Date().timeIntervalSince1970 && !alertEnded) {
                
                let alertLocation = CLLocationCoordinate2D(latitude: alert.startLatitude, longitude: alert.startLongitude)
                let marker = GMSMarker(position: alertLocation)
                marker.snippet = "alert"
                
                if alert.headlineDesc.contains("construction") || alert.eventCategory == "Construction"{
                    switch alert.priority {
                    case "Moderate":
                        marker.icon = constructionModerateIconImage
                        break
                    case "High":
                        marker.icon = constructionHighIconImage
                        break
                    case "Highest":
                        marker.icon = constructionHighestIconImage
                        break
                    default:
                        marker.icon = constructionModerateIconImage
                        break
                    }
                    
                }else if alert.headlineDesc.contains("road closure") || alert.eventCategory.contains("Road Closure"){
                    marker.icon = closedIconImage
                }else {
                    switch alert.priority {
                    case "Moderate":
                        marker.icon = alertModerateIconImage
                        break
                    case "High":
                        marker.icon = alertHighIconImage
                        break
                    case "Highest":
                        marker.icon = alertHighestIconImage
                        break
                    default:
                        marker.icon = alertModerateIconImage
                        break
                    }
                }
                
                marker.userData = alert
                alertMarkers.insert(marker)
                
            }
        }
    }
    
    func drawAlerts(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let alertsPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.alerts)
            
            if let alertsPrefValue = alertsPref {
                
                if (alertsPrefValue == "on") {
                    for alertMarker in alertMarkers{
                        
                        let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                        
                        if (bounds.contains(alertMarker.position)){
                            alertMarker.map = mapView
                        } else {
                            alertMarker.map = nil
                        }
                    }
                }
            }else{
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.alerts)
                for alertMarker in alertMarkers{
                    
                    let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                    
                    if (bounds.contains(alertMarker.position)){
                        alertMarker.map = mapView
                    } else {
                        alertMarker.map = nil
                    }
                }
            }
            
        }
    }
    
    func getAlertsOnScreen() -> [HighwayAlertItem] {
        var alerts = [HighwayAlertItem]()
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            for alertMarker in alertMarkers{
                
                let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                
                if (bounds.contains(alertMarker.position)){
                    alerts.append(alertMarker.userData as! HighwayAlertItem)
                }
            }
        }
        return alerts
    }
    
    // MARK: Rest area marker logic
    func removeRestAreas(){
        for restarea in restAreaMarkers{
            restarea.map = nil
        }
    }
    
    func fetchRestAreas() {
        serviceGroup.enter()
        loadRestAreaMarkers()
        drawRestArea()
        serviceGroup.leave()
    }
    
    
    func loadRestAreaMarkers(){
        
        removeRestAreas()
        restAreaMarkers.removeAll()

        for restarea in RestAreaStore.readRestAreas(){
            let restareaLocation = CLLocationCoordinate2D(latitude: restarea.latitude, longitude: restarea.longitude)
            let marker = GMSMarker(position: restareaLocation)
            marker.snippet = "restarea"
          
            if (restarea.hasDump){
                marker.icon = restAreaDumpIconImage
            }else{
                marker.icon = restAreaIconImage
            }
            
            marker.userData = restarea
            restAreaMarkers.insert(marker)
        }
    }
    
    func drawRestArea(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let restAreaPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.restAreas)
            
            if let restAreaPrefValue = restAreaPref{
                if (restAreaPrefValue == "on") {
                    for restAreaMarker in restAreaMarkers{
                        restAreaMarker.map = mapView
                    }
                }
                
            }else{
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.restAreas)
                for restAreaMarker in restAreaMarkers{
                    restAreaMarker.map = mapView
                }
            }
        }
    }
    
    // MARK: JBLM Marker logic
    func removeJBLM(){
        JBLMMarker.map = nil
    }
    
    func drawJBLM(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let jblmPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.jblmCallout)
            if let jblmPrefValue = jblmPref{
                if (jblmPrefValue == "on") {
                    JBLMMarker.map = mapView
                }
            }else{
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.jblmCallout)
                JBLMMarker.map = mapView
            }
        }
    }
    
    // MARK: favorite location
    func saveCurrentLocation(){
        
        let alert = UIAlertController(title: "New Favorite Location", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.view.tintColor = Colors.tintColor
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
            textField.isSecureTextEntry = false
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (alertAction:UIAlertAction!) in
            GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Favorite Location Saved")
            let textf = alert.textFields![0] as UITextField
            if let mapView = self.embeddedMapViewController.view as? GMSMapView{
                let favoriteLocation = FavoriteLocationItem()
                favoriteLocation.name = textf.text!
                favoriteLocation.latitude = mapView.camera.target.latitude
                favoriteLocation.longitude = mapView.camera.target.longitude
                favoriteLocation.zoom = mapView.camera.zoom
                FavoriteLocationStore.saveFavorite(favoriteLocation)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        drawAlerts()
    }
    
    // MARK: MapMarkerViewController protocol method
    func drawOverlays(){
        self.activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        drawJBLM()
        fetchCameras(false)
        fetchAlerts(false)
        fetchRestAreas()
        
        serviceGroup.notify(queue: DispatchQueue.main) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    
    // MARK: GMUClusterManagerDelegate
    // If a cluster has less then 11 cameras go to a list view will all cameras, otherwise zoom in.
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            if mapView.camera.zoom > Utils.maxClusterOpenZoom {
                performSegue(withIdentifier: SegueCameraClusterViewController, sender: cluster)
            } else {
                let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
                mapView.animate(to: newCamera)
            }
        }
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if (marker.userData as? CameraClusterItem) != nil {
            performSegue(withIdentifier: SegueCamerasViewController, sender: marker)
        }
        if marker.snippet == "alert" {
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: marker)
        }
        if marker.snippet == "restarea" {
            performSegue(withIdentifier: SegueRestAreaViewController, sender: marker)
        }
        if marker.snippet == "jblm" {
            performSegue(withIdentifier: SegueCalloutViewController, sender: marker)
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

        if segue.identifier == SegueGoToPopover {
            let destinationViewController = segue.destination as! TrafficMapGoToViewController
            destinationViewController.parent = self
        }
        
        if segue.identifier == SegueAlertsInArea {
            let alerts = getAlertsOnScreen()
            let destinationViewController = segue.destination as! AlertsInAreaViewController
            destinationViewController.alerts = alerts
        }
        
        if segue.identifier == SegueSettingsPopover {
            let destinationViewController = segue.destination as! TrafficMapSettingsViewController
            destinationViewController.parent = self
        }
        
        if segue.identifier == SegueHighwayAlertViewController {
            let alertItem = ((sender as! GMSMarker).userData as! HighwayAlertItem)
            let destinationViewController = segue.destination as! HighwayAlertViewController
            destinationViewController.alertItem = alertItem
        }
        
        if segue.identifier == SegueCamerasViewController {
            let poiItem = ((sender as! GMSMarker).userData as! CameraClusterItem)
            let cameraItem = poiItem.camera
            let destinationViewController = segue.destination as! CameraViewController
            destinationViewController.cameraItem = cameraItem
        }
        
        if segue.identifier == SegueCameraClusterViewController {
            let cameraCluster = ((sender as! GMUCluster)).items
            var cameras = [CameraItem]()
            for clusterItem in cameraCluster {
                let camera = (clusterItem as! CameraClusterItem).camera
                cameras.append(camera)
            }
            let destinationViewController = segue.destination as! CameraClusterViewController
            destinationViewController.cameraItems = cameras
        }
        
        if segue.identifier == SegueRestAreaViewController {
            let restAreaItem = ((sender as! GMSMarker).userData as! RestAreaItem)
            let destinationViewController = segue.destination as! RestAreaViewController
            destinationViewController.restAreaItem = restAreaItem
        }
        
        if segue.identifier == SegueCalloutViewController {
            let calloutURL = ((sender as! GMSMarker).userData as! String)
            let destinationViewController = segue.destination as! CalloutViewController
            destinationViewController.calloutURL = calloutURL
            destinationViewController.title = "JBLM"
        }
    }
}
