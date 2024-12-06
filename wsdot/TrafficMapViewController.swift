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
import GoogleMaps
import GoogleMobileAds
import EasyTipView

class TrafficMapViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate, GMUClusterManagerDelegate, GADBannerViewDelegate {
    
    let serviceGroup = DispatchGroup()
    
    let SegueGoToPopover = "TrafficMapGoToViewController"
    let SegueAlertsInArea = "AlertsInAreaViewController"
    let SegueSettingsPopover = "TrafficMapSettingsViewController"
    let SegueTravlerInfoViewController = "TravelerInfoViewController"
    let SegueCameraClusterViewController = "CameraClusterViewController"
    let SegueMultipleTravelTimes = "AlertsInAreaViewController"

    
    // Marker Segues
    let SegueCamerasViewController = "CamerasViewController"
    let SegueRestAreaViewController = "RestAreaViewController"
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    let SegueMountainPassViewController = "MountainPassViewController"
    let SegueTravelTimesController = "TravelTimesController"
    let SegueCalloutViewController = "CalloutViewController"
    
    fileprivate var alertMarkers = Set<GMSMarker>()
    fileprivate var cameraMarkers = Set<CameraClusterItem>()
    fileprivate var restAreaMarkers = Set<GMSMarker>()
    fileprivate var mountainPassMarkers = Set<GMSMarker>()
    fileprivate var travelTimesMarkers = Set<GMSMarker>()
    
    // Mark: Map Icons
    fileprivate let restAreaIconImage = UIImage(named: "icMapRestArea")
    fileprivate let restAreaDumpIconImage = UIImage(named: "icMapRestAreaDump")
    
    fileprivate let cameraIconImage = UIImage(named: "icMapCamera")
    
    fileprivate let cameraBarButtonImage = UIImage(named: "icCamera")
    fileprivate let cameraHighlightBarButtonImage = UIImage(named: "icCameraHighlight")
    
    fileprivate let mountainPassIconImage = UIImage(named: "icMountainPass")

    fileprivate let travelTimesIconImage = UIImage(named: "icTravelTime")
    
    var tipView = EasyTipView(text: "")
    
    @IBOutlet weak var travelInformationButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bannerView: GAMBannerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    weak fileprivate var embeddedMapViewController: MapViewController!
    
    fileprivate var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set default value for mountain passes if there is none
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.mountainPasses) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.mountainPasses)
        }
        
        // Set default value for travel times display if there is none
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.travelTimes) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.travelTimes)
        }
        
        // Set default value for camera display if there is none
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras) == nil){
            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.cameras)
        }
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras) == "on"){
            cameraBarButton.image = cameraHighlightBarButtonImage
        }
        
        self.loadCameraMarkers()
        self.drawCameras()
        self.loadAlertMarkers()
        self.drawAlerts()
        self.loadMountainPassesMarkers()
        self.drawMountainPasses()
        self.loadTravelTimesMarkers()
        self.drawTravelTimes()

        
        embeddedMapViewController.clusterManager.setDelegate(self, mapDelegate: self)
        
        checkForTravelCharts()
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.adSize = getFullWidthAdaptiveAdSize()
        bannerView.rootViewController = self
        let request = GAMRequest()
        request.customTargeting = ["wsdotapp":"traffic"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    // add notification observers & set timer
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        self.timer = Timer.scheduledTimer(timeInterval: CachesStore.alertsUpdateTime, target: self, selector: #selector(self.alertsTimerTask), userInfo: nil, repeats: true)
    }
    
    // check traffic alert data cache & set timer
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        fetchAlerts(force: false, group: serviceGroup)
        self.timer = Timer.scheduledTimer(timeInterval: CachesStore.alertsUpdateTime, target: self, selector: #selector(self.alertsTimerTask), userInfo: nil, repeats: true)
    }
    
    // invalidated timer
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        timer?.invalidate()
    }
    
    // timer to force refresh traffic alerts
    @objc func alertsTimerTask(_ timer:Timer) {
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        let serviceGroup = DispatchGroup()
        
        fetchAlerts(force: true, group: serviceGroup)
        
        serviceGroup.notify(queue: DispatchQueue.main) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GAMBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
 
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
    
        MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Refresh")
    
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        let serviceGroup = DispatchGroup();
        
        fetchCameras(force: true, group: serviceGroup)
        fetchAlerts(force: true, group: serviceGroup)
        checkForTravelCharts()
        
        serviceGroup.notify(queue: DispatchQueue.main) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    
    @IBAction func myLocationButtonPressed(_ sender: UIBarButtonItem) {
        MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "My Location")
        embeddedMapViewController.goToUsersLocation()
    }
    
    @IBAction func alertsInAreaButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueAlertsInArea, sender: sender)
    }
    
    @IBAction func goToLocation(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: SegueGoToPopover, sender: self)
    }
    
    @IBAction func cameraToggleButtonPressed(_ sender: UIBarButtonItem) {
        let camerasPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.cameras)
        if let camerasVisible = camerasPref {
            if (camerasVisible == "on") {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Hide Cameras")
                UserDefaults.standard.set("off", forKey: UserDefaultsKeys.cameras)
                sender.image = cameraBarButtonImage
                removeCameras()
            } else {
                MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Show Cameras")
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
        tipView.dismiss()
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
    
    func resetMapStyle() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            MapThemeUtils.setMapStyle(mapView, traitCollection)
        }
    }
    
    func goTo(_ lat: Double, _ long: Double, _ zoom: Float){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: zoom)))
        }
    }
        
    /*
        Checks if "best times to travel charts" are available from the data server,
        if they are, display an alert badge on the Traveler information menu
    */
    
    func checkForTravelCharts(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            BestTimesToTravelStore.isBestTimesToTravelAvailable({ available, error in
                DispatchQueue.main.async { [weak self] in
                    if let selfValue = self{
                       
                        // show badge on travel information icon
                        let travelInfoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
                        let menuImage = UIImage(named: "icMenu")
                        let templateImage = menuImage?.withRenderingMode(.alwaysTemplate)
        
                        travelInfoButton.setBackgroundImage(templateImage, for: .normal)
                        travelInfoButton.addTarget(selfValue, action: #selector(selfValue.travelerInfoAction), for: .touchUpInside)
                        
                        if (available){
                            travelInfoButton.addSubview(UIHelpers.getAlertLabel())
                            selfValue.travelInformationButton.customView = travelInfoButton
                        }
                        
                    }
                }
            })
        }
    }
    
    func fetchCameras(force: Bool, group: DispatchGroup) {
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.trafficCameras, message: WSDOTErrorStrings.cameras)
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
    
    func fetchAlerts(force: Bool, group: DispatchGroup) {
        group.enter()
        HighwayAlertsStore.updateAlerts(force, completion: { error in
            if (error == nil){
                DispatchQueue.main.async {[weak self] in
                    if let selfValue = self{
                        group.leave()
                        selfValue.loadAlertMarkers()
                        selfValue.drawAlerts()
                    }
                }
            }else{
                DispatchQueue.main.async {  
                    group.leave()
                    AlertMessages.getConnectionAlert(backupURL: WsdotURLS.trafficAlerts, message: WSDOTErrorStrings.highwayAlerts)
                }
            }
        })
        
    }
    
    func loadAlertMarkers(){
        
        removeAlerts()
        alertMarkers.removeAll()
        
        for alert in HighwayAlertsStore.getAllAlerts(){
            
            if (alert.displayLatitude != 0
                && alert.displayLongitude != 0) {
                
                let alertLocation = CLLocationCoordinate2D(latitude: alert.displayLatitude, longitude: alert.displayLongitude)
                let marker = GMSMarker(position: alertLocation)
                marker.snippet = "alert"
                
                marker.icon = UIHelpers.getAlertIcon(forAlert: alert)
                
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
    
    func trafficLayer() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let trafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.trafficLayer)
            if let trafficLayerVisible = trafficLayerPref {
                if (trafficLayerVisible == "on") {
                    UserDefaults.standard.set("on", forKey: UserDefaultsKeys.trafficLayer)
                    mapView.isTrafficEnabled = true
                } else {
                    UserDefaults.standard.set("off", forKey: UserDefaultsKeys.trafficLayer)
                    mapView.isTrafficEnabled = false
                }
            }
        }
    }
    
    func convertAlertMarkersToHighwayAlertItems(markers: [GMSMarker]) -> [HighwayAlertItem] {
        var alerts = [HighwayAlertItem]()
        for alertMarker in markers{
           alerts.append(alertMarker.userData as! HighwayAlertItem)
        }
        return alerts
    }
    
    func convertAlertMarkersToTravelTimesItems(markers: [GMSMarker]) -> [TravelTimeItem] {
        var alerts = [TravelTimeItem]()
        for alertMarker in markers{
           alerts.append(alertMarker.userData as! TravelTimeItem)
        }
        return alerts
    }
    
    // MARK: Rest area marker logic
    func removeRestAreas(){
        for restarea in restAreaMarkers{
            restarea.map = nil
        }
    }
    
    func fetchRestAreas(group: DispatchGroup) {
        group.enter()
        loadRestAreaMarkers()
        drawRestArea()
        group.leave()
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
            } else {
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.restAreas)
                for restAreaMarker in restAreaMarkers{
                    restAreaMarker.map = mapView
                }
            }
        }
    }
    
    // MARK: Mountain Pass marker logic
    func removeMountainPasses(){
        for mountainpasses in mountainPassMarkers{
            mountainpasses.map = nil
        }
    }
    
    func fetchMountainPasses(force: Bool, group: DispatchGroup) {
        serviceGroup.enter()
        DispatchQueue.global().async {[weak self] in
            MountainPassStore.updatePasses(force, completion: { error in
                if (error == nil){
                    DispatchQueue.main.async {[weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                            selfValue.loadMountainPassesMarkers()
                            selfValue.drawMountainPasses()
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                        }
                    }
                }
            })
        }
    }

    func loadMountainPassesMarkers(){
        removeMountainPasses()
        mountainPassMarkers.removeAll()
        for mountainpass in MountainPassStore.getPasses(){
            let mountainpassLocation = CLLocationCoordinate2D(latitude: mountainpass.latitude, longitude: mountainpass.longitude)
            let marker = GMSMarker(position: mountainpassLocation)
            marker.snippet = "mountainpass"
            marker.icon = mountainPassIconImage
            marker.userData = mountainpass
            mountainPassMarkers.insert(marker)
        }
    }

    func drawMountainPasses(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let mountainPassesPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.mountainPasses)
            if let mountainPassesPrefValue = mountainPassesPref{
                if (mountainPassesPrefValue == "on") {
                    for mountainPassesMarker in mountainPassMarkers{
                        mountainPassesMarker.map = mapView
                    }
                }
            } else {
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.mountainPasses)
                for mountainPassesMarker in mountainPassMarkers{
                    mountainPassesMarker.map = mapView
                }
            }
        }
    }
    
    // MARK: Travel Time marker logic
    func removeTravelTimes(){
        for travelTimes in travelTimesMarkers{
            travelTimes.map = nil
        }
    }
    
    func fetchTravelTimes(force: Bool, group: DispatchGroup) {
        serviceGroup.enter()
        DispatchQueue.global().async {[weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil){
                    DispatchQueue.main.async {[weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                            selfValue.loadTravelTimesMarkers()
                            selfValue.drawTravelTimes()
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.serviceGroup.leave()
                        }
                    }
                }
            })
        }
    }

    func loadTravelTimesMarkers(){
        removeTravelTimes()
        travelTimesMarkers.removeAll()
        for travelTimes in TravelTimesStore.getTravelTimes(){
            
            if (travelTimes.routeid != 36 && travelTimes.routeid != 37 && travelTimes.routeid != 68 && travelTimes.routeid != 69) {
                
                if ((travelTimes.startLatitude != 0 && travelTimes.startLongitude != 0) && (travelTimes.endLatitude != 0 && travelTimes.endLongitude != 0)) {
                    
                    let travelTimeLocation = CLLocationCoordinate2D(latitude: travelTimes.startLatitude, longitude: travelTimes.startLongitude)
                    let marker = GMSMarker(position: travelTimeLocation)
                    marker.snippet = "traveltimes"
                    marker.icon = travelTimesIconImage
                    marker.userData = travelTimes
                    travelTimesMarkers.insert(marker)
                }
            }
        }
    }

    func drawTravelTimes(){
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            let travelTimesPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.travelTimes)
            if let travelTimesPrefValue = travelTimesPref{
                if (travelTimesPrefValue == "on") {
                    for travelTimesMarker in travelTimesMarkers{
                        travelTimesMarker.map = mapView
                    }
                }
            } else {
                UserDefaults.standard.set("on", forKey: UserDefaultsKeys.travelTimes)
                for travelTimesMarker in travelTimesMarkers{
                    travelTimesMarker.map = mapView
                }
            }
        }
    }

    // MARK: favorite location
    func saveCurrentLocation(){
        
        let alertController = UIAlertController(title: "New Favorite Location", message:nil, preferredStyle: .alert)
        
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Name"
        }
        
        alertController.view.tintColor = Colors.tintColor

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
            MyAnalytics.event(category: "Traffic Map", action: "UIAction", label: "Favorite Location Saved")
            let textf = alertController.textFields![0] as UITextField
            if let mapView = self.embeddedMapViewController.view as? GMSMapView{
                let favoriteLocation = FavoriteLocationItem()
                favoriteLocation.name = textf.text!
                favoriteLocation.latitude = mapView.camera.target.latitude
                favoriteLocation.longitude = mapView.camera.target.longitude
                favoriteLocation.zoom = mapView.camera.zoom
                FavoriteLocationStore.saveFavorite(favoriteLocation)
            }
        }
        alertController.addAction(okAction)

        present(alertController, animated: false, completion: nil)
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        drawAlerts()
    }
    
    // MARK: MapMarkerViewController protocol method
    func mapReady(){
    
        self.activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        let serviceGroup = DispatchGroup();
        
        fetchCameras(force: false, group: serviceGroup)
        fetchAlerts(force: false, group: serviceGroup)
        fetchMountainPasses(force: false, group: serviceGroup)
        fetchTravelTimes(force: false, group: serviceGroup)
        fetchRestAreas(group: serviceGroup)

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
        
            // Check for overlapping markers.
            var markers = alertMarkers
            markers.remove(marker)
            if markers.contains(where: {($0.position.latitude == marker.position.latitude) && ($0.position.latitude == marker.position.latitude)}) {
                performSegue(withIdentifier: SegueAlertsInArea, sender: marker)
            } else {
                performSegue(withIdentifier: SegueHighwayAlertViewController, sender: marker)
            }
        }
        
        if marker.snippet == "restarea" {
            performSegue(withIdentifier: SegueRestAreaViewController, sender: marker)
        }
        
        if marker.snippet == "mountainpass" {
            performSegue(withIdentifier: SegueMountainPassViewController, sender: marker)
        }
        
        if marker.snippet == "traveltimes" {
            
            // Check for overlapping markers.
            var markers = travelTimesMarkers
            markers.remove(marker)
            if markers.contains(where: {($0.position.latitude == marker.position.latitude) && ($0.position.latitude == marker.position.latitude)}) {
                performSegue(withIdentifier: SegueMultipleTravelTimes, sender: marker)
            } else {
                performSegue(withIdentifier: SegueTravelTimesController, sender: marker)
            }
        }

        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if let mapView = embeddedMapViewController.view as? GMSMapView {
            UserDefaults.standard.set(mapView.camera.target.latitude, forKey: UserDefaultsKeys.mapLat)
            UserDefaults.standard.set(mapView.camera.target.longitude, forKey: UserDefaultsKeys.mapLon)
            UserDefaults.standard.set(mapView.camera.zoom, forKey: UserDefaultsKeys.mapZoom)
        }
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
            destinationViewController.my_parent = self
        }
        
        if segue.identifier == SegueAlertsInArea {
        
            //Check sender - could be alertsInArea button or a marker with overlap.
            if let marker = sender as? GMSMarker {
                // Get the overlapping markers
                let alerts = convertAlertMarkersToHighwayAlertItems(markers: alertMarkers.filter({($0.position.latitude == marker.position.latitude) && ($0.position.latitude == marker.position.latitude)}))
                let destinationViewController = segue.destination as! AlertsInAreaViewController
                destinationViewController.alerts = alerts
                destinationViewController.title = "Alert"
            
            } else {
                let alerts = getAlertsOnScreen()
                let destinationViewController = segue.destination as! AlertsInAreaViewController
                destinationViewController.alerts = alerts
                destinationViewController.title = "Alerts In This Area"
            }
        }
        
        if segue.identifier == SegueMultipleTravelTimes {
        
            //Check sender - could be alertsInArea button or a marker with overlap.
            if let marker = sender as? GMSMarker {
                // Get the overlapping markers
                let alerts = convertAlertMarkersToTravelTimesItems(markers: travelTimesMarkers.filter({($0.position.latitude == marker.position.latitude) && ($0.position.latitude == marker.position.latitude)}))
                let destinationViewController = segue.destination as! AlertsInAreaViewController
                destinationViewController.travelTimes = alerts
                destinationViewController.title = "Travel Times"
                
                
            
            } else {
                let alerts = getAlertsOnScreen()
                let destinationViewController = segue.destination as! AlertsInAreaViewController
                destinationViewController.alerts = alerts
                destinationViewController.title = "Alerts In This Area"
            }
        }
        
        if segue.identifier == SegueSettingsPopover {
            let destinationViewController = segue.destination as! TrafficMapSettingsViewController
            destinationViewController.my_parent = self
        }
        
        if segue.identifier == SegueHighwayAlertViewController {
            let alertItem = ((sender as! GMSMarker).userData as! HighwayAlertItem)
            let destinationViewController = segue.destination as! HighwayAlertViewController
            destinationViewController.alertId = alertItem.alertId
        }
        
        if segue.identifier == SegueCamerasViewController {
            let poiItem = ((sender as! GMSMarker).userData as! CameraClusterItem)
            let cameraItem = poiItem.camera
            let destinationViewController = segue.destination as! CameraViewController
            destinationViewController.adTarget = "traffic"
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
        
        if segue.identifier == SegueMountainPassViewController {
            let passItem = ((sender as! GMSMarker).userData as! MountainPassItem)
            let destinationViewController = segue.destination as! MountainPassTabBarViewController
            destinationViewController.passItem = passItem
        }
        
        if segue.identifier == SegueTravelTimesController {
            let travelTimeItem = ((sender as! GMSMarker).userData as! TravelTimeItem)
            let destinationViewController = segue.destination as! TravelTimeAlertViewController
            destinationViewController.travelTimeId = travelTimeItem.routeid
        }
        
    }
}

extension TrafficMapViewController: EasyTipViewDelegate {
    
    public func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("\(tipView) did tap!")
    }
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
         UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenTravelerInfoTipView)
    }
    
    // invalidate timer and remove observers
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tipView.dismiss()
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TrafficMap")
        if (!UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenTravelerInfoTipView) && !UIAccessibility.isVoiceOverRunning){
            tipView = EasyTipView(text: "Tap here for live traffic updates, travel times and more.", delegate: self)
            tipView.show(forItem: self.travelInformationButton)
        }
    }
}
