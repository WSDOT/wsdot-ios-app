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
    

    
    var tipView = EasyTipView(text: "")
    
    @IBOutlet weak var travelInformationButton: UIBarButtonItem!
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
        JBLMMarker.userData = "https://images.wsdot.wa.gov/traffic/flowmaps/jblm.png"
        
        self.loadCameraMarkers()
        self.drawCameras()
        self.loadAlertMarkers()
        self.drawAlerts()
        
        embeddedMapViewController.clusterManager.setDelegate(self, mapDelegate: self)
        
        checkForTravelCharts()
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":"traffic"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
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
                        }
                        
                        selfValue.travelInformationButton.customView = travelInfoButton
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.trafficCameras)
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
                    AlertMessages.getConnectionAlert(backupURL: WsdotURLS.trafficAlerts)
                }
            }
        })
        
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
    
    func convertAlertMarkersToHighwayAlertItems(markers: [GMSMarker]) -> [HighwayAlertItem] {
        var alerts = [HighwayAlertItem]()
        for alertMarker in markers{
           alerts.append(alertMarker.userData as! HighwayAlertItem)
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
        
        drawJBLM()
        fetchCameras(force: false, group: serviceGroup)
        fetchAlerts(force: false, group: serviceGroup)
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
        
        if segue.identifier == SegueCalloutViewController {
            let calloutURL = ((sender as! GMSMarker).userData as! String)
            let destinationViewController = segue.destination as! CalloutViewController
            destinationViewController.calloutURL = calloutURL
            destinationViewController.title = "JBLM"
        }
    }
}

extension TrafficMapViewController: EasyTipViewDelegate {
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
         UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenTravelerInfoTipView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tipView.dismiss()
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
