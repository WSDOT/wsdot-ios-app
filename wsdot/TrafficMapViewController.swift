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

class TrafficMapViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate, GMUClusterManagerDelegate {
    
    let serviceGroup = dispatch_group_create()
    
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
    
    private var alertMarkers = Set<GMSMarker>()
    private var cameraMarkers = Set<CameraClusterItem>()
    private var restAreaMarkers = Set<GMSMarker>()
    
    private let JBLMMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 47.103033, longitude: -122.584394))
    
    // Mark: Map Icons
    private let restAreaIconImage = UIImage(named: "icMapRestArea")
    private let restAreaDumpIconImage = UIImage(named: "icMapRestAreaDump")
    
    private let cameraIconImage = UIImage(named: "icMapCamera")
    
    private let cameraBarButtonImage = UIImage(named: "icCamera")
    private let cameraHighlightBarButtonImage = UIImage(named: "icCameraHighlight")
    
    private let alertHighIconImage = UIImage(named: "icMapAlertHigh")
    private let alertHighestIconImage = UIImage(named: "icMapAlertHighest")
    private let alertModerateIconImage = UIImage(named: "icMapAlertModerate")
    
    private let constructionHighIconImage = UIImage(named: "icMapConstructionHigh")
    private let constructionHighestIconImage = UIImage(named: "icMapConstructionHighest")
    private let constructionModerateIconImage = UIImage(named: "icMapConstructionModerate")
    
    private let closedIconImage = UIImage(named: "icMapClosed")
    
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    weak private var embeddedMapViewController: MapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set defualt value for camera display if there is none
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras) == nil){
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.cameras)
        }
        
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras) == "on"){
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
        bannerView.loadRequest(GADRequest())
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map")
    }
    
    @IBAction func refreshPressed(sender: UIBarButtonItem) {
    
        GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Refresh")
    
        self.activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        let serviceGroup = dispatch_group_create();
        
        fetchCameras(true)
        fetchAlerts(true)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
        }
    }
    
    @IBAction func myLocationButtonPressed(sender: UIBarButtonItem) {
        GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "My Location")
        embeddedMapViewController.goToUsersLocation()
    }
    
    @IBAction func alertsInAreaButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueAlertsInArea, sender: self)
    }
    
    @IBAction func goToLocation(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueGoToPopover, sender: self)
    }
    
    @IBAction func cameraToggleButtonPressed(sender: UIBarButtonItem) {
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Hide Cameras")
                NSUserDefaults.standardUserDefaults().setObject("off", forKey: UserDefaultsKeys.cameras)
                sender.image = cameraBarButtonImage
                removeCameras()
            } else {
                GoogleAnalytics.event("Traffic Map", action: "UIAction", label: "Show Cameras")
                sender.image = cameraHighlightBarButtonImage
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.cameras)
                drawCameras()
            }
        }
    }
    
    @IBAction func travelerInfoAction(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueTravlerInfoViewController, sender: self)
    }

    @IBAction func settingsAction(sender: UIBarButtonItem) {
        performSegueWithIdentifier(SegueSettingsPopover, sender: self)
    }
    
    // zoom in and out to reload icons for when clustering is toggled
    func resetMapCamera() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let camera = mapView.camera
            let camera2 = GMSCameraPosition.cameraWithLatitude(camera.target.latitude, longitude: camera.target.longitude, zoom: camera.zoom - 1.0)
            mapView.moveCamera(GMSCameraUpdate.setCamera(camera2))
            mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
        }
    }
    
    func goTo(index: Int){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            switch(index){
            case 0:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(48.756302, longitude: -122.46151, zoom: 12))) // Bellingham
                break
            case 1:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(46.635529, longitude: -122.937698, zoom: 11))) // Chehalis
                break
            case 2:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.85268, longitude: -122.628365, zoom: 13))) // Hood Canal
                break
            case 3:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.859476, longitude: -121.972446, zoom: 13))) // Monroe
                break
            case 4:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(48.420657, longitude: -122.334824, zoom: 13))) // Mt Vernon
                break
            case 5:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.021461, longitude: -122.899933, zoom: 13))) // Olympia
                break
            case 6:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.5990, longitude: -122.3350, zoom: 12))) // Seattle
                break
            case 7:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.404481, longitude: -121.4232569, zoom: 12))) // Snoqualmie Pass
                break
            case 8:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.658566, longitude: -117.425995, zoom: 12))) // Spokane
                break
            case 9:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(48.22959, longitude: -122.34581, zoom: 13))) // Stanwood
                break
            case 10:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.86034, longitude: -121.812286, zoom: 13))) // Sultan
                break
            case 11:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.206275, longitude: -122.46254, zoom: 12))) // Tacoma
                break
            case 12:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(46.2503607, longitude: -119.2063781, zoom: 11))) // Tri-Cities
                break
            case 13:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(45.639968, longitude: -122.610512, zoom: 11))) // Vancouver
                break
            case 14:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(47.435867, longitude: -120.309563, zoom: 12))) // Wenatchee
                break
            case 15:
                mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithLatitude(46.6063273, longitude: -120.4886952, zoom: 11))) // Takima
                break
            default:
                break
            }
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
        let camerasPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.cameras)

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
    
    func fetchAlerts(force: Bool) {
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            HighwayAlertsStore.updateAlerts(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            dispatch_group_leave(selfValue.serviceGroup)
                            selfValue.loadAlertMarkers()
                            selfValue.drawAlerts()
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
    
    func loadAlertMarkers(){
        
        removeAlerts()
        alertMarkers.removeAll()
        
        for alert in HighwayAlertsStore.getAllAlerts(){
            
            var alertEnded = false
            
            if let alertEndTimeValue = alert.endTime{
                if alertEndTimeValue.timeIntervalSince1970 < NSDate().timeIntervalSince1970{
                    alertEnded = true
                }
            }
            
            if (alert.startTime.timeIntervalSince1970 < NSDate().timeIntervalSince1970 && !alertEnded) {
                
                let alertLocation = CLLocationCoordinate2D(latitude: alert.startLatitude, longitude: alert.startLongitude)
                let marker = GMSMarker(position: alertLocation)
                marker.snippet = "alert"
                
                if alert.headlineDesc.containsString("construction") || alert.eventCategory == "Construction"{
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
                    
                }else if alert.headlineDesc.containsString("road closure") || alert.eventCategory.containsString("Road Closure"){
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
            let alertsPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.alerts)
            
            if let alertsPrefValue = alertsPref {
                
                if (alertsPrefValue == "on") {
                    for alertMarker in alertMarkers{
                        
                        let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                        
                        if (bounds.containsCoordinate(alertMarker.position)){
                            alertMarker.map = mapView
                        } else {
                            alertMarker.map = nil
                        }
                    }
                }
            }else{
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.alerts)
                for alertMarker in alertMarkers{
                    
                    let bounds = GMSCoordinateBounds(coordinate: mapView.projection.visibleRegion().farLeft, coordinate: mapView.projection.visibleRegion().nearRight)
                    
                    if (bounds.containsCoordinate(alertMarker.position)){
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
                
                if (bounds.containsCoordinate(alertMarker.position)){
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
        dispatch_group_enter(serviceGroup)
        loadRestAreaMarkers()
        drawRestArea()
        dispatch_group_leave(serviceGroup)
    }
    
    
    func loadRestAreaMarkers(){
        
        removeRestAreas()
        restAreaMarkers.removeAll()

        for restarea in RestAreaStore.readRestAreas(){
            let restareaLocation = CLLocationCoordinate2D(latitude: restarea.latitude, longitude: restarea.longitude)
            let marker = GMSMarker(position: restareaLocation)
            marker.snippet = "restarea"
          
            if (restarea.hasDump){
                marker.icon = restAreaIconImage
            }else{
                marker.icon = restAreaDumpIconImage
            }
            
            marker.userData = restarea
            restAreaMarkers.insert(marker)
        }
    }
    
    func drawRestArea(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let restAreaPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.restAreas)
            
            if let restAreaPrefValue = restAreaPref{
                if (restAreaPrefValue == "on") {
                    for restAreaMarker in restAreaMarkers{
                        restAreaMarker.map = mapView
                    }
                }
                
            }else{
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.restAreas)
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
            let jblmPref = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.jblmCallout)
            if let jblmPrefValue = jblmPref{
                if (jblmPrefValue == "on") {
                    JBLMMarker.map = mapView
                }
            }else{
                NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.jblmCallout)
                JBLMMarker.map = mapView
            }
        }
    }
    
    // MARK: favorite location
    func saveCurrentLocation(){
        
        let alert = UIAlertController(title: "New Favorite Location", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.view.tintColor = Colors.tintColor
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name"
            textField.secureTextEntry = false
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
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
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        drawAlerts()
    }
    
    // MARK: MapMarkerViewController protocol method
    func drawOverlays(){
        self.activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        
        drawJBLM()
        fetchCameras(false)
        fetchAlerts(false)
        fetchRestAreas()
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
        }
    }
    
    // MARK: GMUClusterManagerDelegate
    // If a cluster has less then 11 cameras go to a list view will all cameras, otherwise zoom in.
    func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            if mapView.camera.zoom > Utils.maxClusterOpenZoom {
                performSegueWithIdentifier(SegueCameraClusterViewController, sender: cluster)
            } else {
                let newCamera = GMSCameraPosition.cameraWithTarget(cluster.position, zoom: mapView.camera.zoom + 1)
                mapView.animateToCameraPosition(newCamera)
            }
        }
    }
    
    // MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if (marker.userData as? CameraClusterItem) != nil {
            performSegueWithIdentifier(SegueCamerasViewController, sender: marker)
        }
        if marker.snippet == "alert" {
            performSegueWithIdentifier(SegueHighwayAlertViewController, sender: marker)
        }
        if marker.snippet == "restarea" {
            performSegueWithIdentifier(SegueRestAreaViewController, sender: marker)
        }
        if marker.snippet == "jblm" {
            performSegueWithIdentifier(SegueCalloutViewController, sender: marker)
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
        if let vc = segue.destinationViewController as? MapViewController where segue.identifier == "EmbedMapSegue" {
            vc.markerDelegate = self
            vc.mapDelegate = self
            self.embeddedMapViewController = vc
        }

        if segue.identifier == SegueGoToPopover {
            let destinationViewController = segue.destinationViewController as! TrafficMapGoToViewController
            destinationViewController.parent = self
        }
        
        if segue.identifier == SegueAlertsInArea {
            let alerts = getAlertsOnScreen()
            let destinationViewController = segue.destinationViewController as! AlertsInAreaViewController
            destinationViewController.alerts = alerts
        }
        
        if segue.identifier == SegueSettingsPopover {
            let destinationViewController = segue.destinationViewController as! TrafficMapSettingsViewController
            destinationViewController.parent = self
        }
        
        if segue.identifier == SegueHighwayAlertViewController {
            let alertItem = ((sender as! GMSMarker).userData as! HighwayAlertItem)
            let destinationViewController = segue.destinationViewController as! HighwayAlertViewController
            destinationViewController.alertItem = alertItem
        }
        
        if segue.identifier == SegueCamerasViewController {
            let poiItem = ((sender as! GMSMarker).userData as! CameraClusterItem)
            let cameraItem = poiItem.camera
            let destinationViewController = segue.destinationViewController as! CameraViewController
            destinationViewController.cameraItem = cameraItem
        }
        
        if segue.identifier == SegueCameraClusterViewController {
            let cameraCluster = ((sender as! GMUCluster)).items
            var cameras = [CameraItem]()
            for clusterItem in cameraCluster {
                let camera = (clusterItem as! CameraClusterItem).camera
                cameras.append(camera)
            }
            let destinationViewController = segue.destinationViewController as! CameraClusterViewController
            destinationViewController.cameraItems = cameras
        }
        
        if segue.identifier == SegueRestAreaViewController {
            let restAreaItem = ((sender as! GMSMarker).userData as! RestAreaItem)
            let destinationViewController = segue.destinationViewController as! RestAreaViewController
            destinationViewController.restAreaItem = restAreaItem
        }
        
        if segue.identifier == SegueCalloutViewController {
            let calloutURL = ((sender as! GMSMarker).userData as! String)
            let destinationViewController = segue.destinationViewController as! CalloutViewController
            destinationViewController.calloutURL = calloutURL
            destinationViewController.title = "JBLM"
        }
    }
}
