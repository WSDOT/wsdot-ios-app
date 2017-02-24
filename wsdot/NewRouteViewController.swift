//
//  NewRouteViewController.swift
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
import CoreLocation
import HealthKit
import GoogleMaps
import SCLAlertView
/**
 * Handles creation of new MyRoutes
 */
class NewRouteViewController: UIViewController {

    var distance = 0.0

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .automotiveNavigation
        // Movement threshold for new events
        _locationManager.distanceFilter = 100.0
        return _locationManager
    }()
 
    var recordingAlertView = SCLAlertView()

    lazy var locations = [CLLocation]()

    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    @IBOutlet weak var accessibilityCurrentLocationLabel: UILabel!
    @IBOutlet weak var accessibilityMapLabel: UILabel!
    
    override func loadView() {
        super.loadView()
        
        // Prepare Google mapView
        mapView.layer.cornerRadius = 20
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: 47.5990, longitude: -122.3350, zoom: 12))
        if let myLocation = mapView.myLocation{
            mapView.animate(toLocation: myLocation.coordinate)
        }
        
        self.accessibilityCurrentLocationLabel.accessibilityLabel = "Finding location..."
        self.accessibilityMapLabel.isHidden = true
        
        GoogleAnalytics.screenView(screenName: "/Favorites/My Route/New Route")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
    }

    
    func showRecordingAlert(){

        let alertViewIcon = UIImage(named: "icCar")
        
        recordingAlertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true,
            shouldAutoDismiss: false)
        )

        let button = recordingAlertView.addButton("Finish") {
            self.stopRecordingPressed()
        }
        button.accessibilityHint = "Double Tap to stop tracking route."
        
        navigationItem.hidesBackButton = true
        self.view.accessibilityElementsHidden = true
        
        _ = recordingAlertView.showCustom("Let's Go!", subTitle: "\nTracking route...\n\n Please do not use the WSDOT app while you are driving.", color: Colors.tintColor, icon: alertViewIcon!)

        screenChange()

    }

    /**
     * Method name: startRoutePressed(_:)
     * Description: Action for when the start recording route button is pressed.
     *              Checks app permissions and starts process of recording users location if able.
     * Parameters: sender: UIButton
     */
    @IBAction func startRoutePressed(_ sender: UIButton) {
 
        GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Started Recording Route")
        accessibilityCurrentLocationLabel.isHidden = true
 
        if !CLLocationManager.locationServicesEnabled() {
        
            self.present(AlertMessages.getAlert("Location Services Are Disabled", message: "You can enable location services from Settings.", confirm: "OK"), animated: true, completion: nil)
        } else {
        
            switch CLLocationManager.authorizationStatus() {
            
                case .notDetermined:
                    print("notDetermined")
                    break
                case .authorizedWhenInUse:
                    print("auth when in use")
                    
                    locations.removeAll()
                    startLocationUpdates()
                    showRecordingAlert()
            
                    break
                case .authorizedAlways:

                    locations.removeAll()
                    startLocationUpdates()
                    showRecordingAlert()
                    
                    break
                case .restricted:
                    print("restricted")
                    // restricted by e.g. parental controls. User can't enable Location Services
                    self.present(AlertMessages.getAcessDeniedAlert("\"WSDOT\" Doesn't Have Permission To Use Your Location", message: "You can enable location services for this app in Settings"), animated: true, completion: nil)
                    break
                case .denied:
                    self.present(AlertMessages.getAcessDeniedAlert("\"WSDOT\" Doesn't Have Permission To Use Your Location", message: "You can enable location services for this app in Settings"), animated: true, completion: nil)
                    break
            
            }
        }
    }

    /**
     * Method name: stopRecordingPressed()
     * Description: Action for finish button while recording a route. DIsplays a comfirmation action sheet
     *              before recording is stopped. Shows & hides buttons to reflect curren state
     * Parameters: sender: UIButton
     */
    func stopRecordingPressed() {
    
        let alert = UIAlertController(title: "View Results?", message: nil, preferredStyle: .alert)
        
        alert.view.tintColor = Colors.tintColor
        
        let resultsAction = UIAlertAction(title: "Yes", style: .default, handler: {(_) -> Void in
            
            self.recordingAlertView.hideView()
            self.navigationItem.hidesBackButton = false
            self.view.accessibilityElementsHidden = false
            
            // TEST
             self.locations = MyRouteStore.getFakeData()
            
            if (self.displayRouteOnMap(locations: self.locations)){
            
                self.startButton.isHidden = true
                self.saveButton.isHidden = false
                self.discardButton.isHidden = false
            
                self.mapView.settings.scrollGestures = false
                self.mapView.settings.zoomGestures = false
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
            }else {
                self.present(AlertMessages.getAlert("Not Enough Location Data to Save a Route", message: "", confirm: "OK"), animated: true)
            }
        })
        
        alert.addAction(resultsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        recordingAlertView.present(alert, animated: true, completion: nil)
        
    }
    
    /**
     * Method name: saveButtonPressed(_:)
     * Description: Action for save button. Stops updating location and prompts user to name the newly created route.
     *              If route is correctly saves exits, dismisses this veiw controller.
     * Parameters: sender: UIButton
     */
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        stopLocationUpdates()
        
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        
        let alertController = UIAlertController(title: "Saving Route", message: "This name will display \n on your favorites list", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Name This Route"
        }
        alertController.view.tintColor = Colors.tintColor

        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
        
            let textf = alertController.textFields![0] as UITextField
            var name = textf.text!
            if name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
                name = "My Route"
            }
                
            GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Saved Route")

            let id =  MyRouteStore.save(route: self.locations, name: name,
                                        displayLat: self.mapView.projection.coordinate(for: self.mapView.center).latitude,
                                        displayLong: self.mapView.projection.coordinate(for: self.mapView.center).longitude,
                                        displayZoom: self.mapView.camera.zoom)
            
            
            
            let addFavoritesAlertController = UIAlertController(title: "Add Favorites?", message:"Traffic cameras, travel times, pass reports, and other content will be added to your favorites if they are on this route. \n\n You can do this later by tapping Edit on the My Routes screen.", preferredStyle: .alert)
            
            
            let addAction = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                self.navigationItem.hidesBackButton = false
                self.view.accessibilityElementsHidden = false
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            let noAction = UIAlertAction(title: "No", style: .cancel) { (_) -> Void in
                self.navigationItem.hidesBackButton = false
                self.view.accessibilityElementsHidden = false
                _ = MyRouteStore.updateFindNearby(forRoute: MyRouteStore.getRouteById(id)!, foundCameras: true, foundTimes: true, foundFerries: true, foundPasses: true)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            addFavoritesAlertController.addAction(addAction)
            addFavoritesAlertController.addAction(noAction)
            
            addFavoritesAlertController.view.tintColor = Colors.tintColor
            
            self.present(addFavoritesAlertController, animated: false, completion: nil)

        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
            
        self.present(alertController, animated: false, completion: nil)

        
    }

    
    /**
     * Method name: discardButtonPressed(_:)
     * Description: Displays confirmation alert controller before clearing out the locations array.
     * Parameters: sender: UIButton
     */
    @IBAction func discardButtonPressed(_ sender: UIButton) {

        self.accessibilityMapLabel.isHidden = true
        self.accessibilityCurrentLocationLabel.isHidden = false
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true

        let alertController = UIAlertController(title: "Discard this route?", message: "This cannot be undone.", preferredStyle: .alert)
        
        let discardAction = UIAlertAction(title: "Discard", style: .destructive, handler: {(_) -> Void in
            GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Discarded Route")
            self.mapView.clear()
            self.doneRecording()
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
        })
        
        alertController.addAction(discardAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = Colors.tintColor
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /**
     * Method name: doneRecording()
     * Description: hides/shows views/buttons to get view back to the start recording state.
     */
    func doneRecording(){
        discardButton.isHidden = true
        saveButton.isHidden = true
        startButton.isHidden = false
        locations.removeAll()
        if let location = self.locationManager.location?.coordinate {
            mapView.animate(toLocation: location)
            mapView.animate(toZoom: 12)
        }
        stopLocationUpdates()
    }

    /**
     * Method name: startLocationUpdates()
     * Description: sets locationManager to start recording updates. for <= iOS 9 needs to call addition method for background.
     */
    func startLocationUpdates() {
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        locationManager.startUpdatingLocation()
    }
    
    /**
     * Method name: stopLocationUpdates()
     * Description: sets locationManager to stop recording updates.
     */
    func stopLocationUpdates(){
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = false
        }
        locationManager.stopUpdatingLocation()
    }

    /**
     * Method name: styleButtons()
     * Description: programmatically styles button background, colors, etc...
     */
    func styleButtons() {
        startButton.layer.cornerRadius = 5
        startButton.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 5
        saveButton.clipsToBounds = true
        saveButton.accessibilityHint = "Double tap to save newly recorded route."
        
        discardButton.layer.cornerRadius = 5
        discardButton.clipsToBounds = true
        discardButton.accessibilityHint = "Double tap to delete newly recorded route."
    }
    
    
    /**
     * Method name: displayRouteOnMap()
     * Description: sets mapView camera to show all of the newly recording route if there is data.
     * Parameters: locations: Array of CLLocations that make up the route.
     */
    func displayRouteOnMap(locations: [CLLocation]) -> Bool {
        
        if let region = getRouteMapRegion(locations: self.locations) {
            
            // set Map Bounds
            let bounds = GMSCoordinateBounds(coordinate: region.nearLeft,coordinate: region.farRight)
            let camera = mapView.camera(for: bounds, insets:UIEdgeInsets.zero)
            mapView.camera = camera!
            
            let myPath = GMSMutablePath()
            
            for location in locations {
                myPath.add(location.coordinate)
            }
            
            let MyRoute = GMSPolyline(path: myPath)
            
            setRouteAccessibilityLabel(locations: locations)
            
            MyRoute.spans = [GMSStyleSpan(color: UIColor(red: 0, green: 0.6588, blue: 0.9176, alpha: 1.0))] /* #00a8ea */
            MyRoute.strokeWidth = 4
            MyRoute.map = mapView
            mapView.animate(toZoom: (camera?.zoom)! - 0.5)
        
            return true
        } else {
            return false
        }
    }
    
    /**
     * Method name: getRouteMapRegion
     * Description: returns a region that contains all locations in the input array.
     * Parameters: locations: Array of CLLocations that make up the route.
     */
    func getRouteMapRegion(locations: [CLLocation]) -> GMSVisibleRegion? {
        let initialLoc = locations.first
 
        if let initialLocValue = initialLoc {
 
            var minLat = initialLocValue.coordinate.latitude
            var minLng = initialLocValue.coordinate.longitude
            var maxLat = minLat
            var maxLng = minLng

            for location in locations {
                minLat = min(minLat, location.coordinate.latitude)
                minLng = min(minLng, location.coordinate.longitude)
                maxLat = max(maxLat, location.coordinate.latitude)
                maxLng = max(maxLng, location.coordinate.longitude)
            }
 
            var region: GMSVisibleRegion = GMSVisibleRegion()
            region.nearLeft = CLLocationCoordinate2DMake(maxLat, minLng)
            region.farRight = CLLocationCoordinate2DMake(minLat, maxLng)
            
            return region
        }
        return nil
    }
    
}

extension NewRouteViewController: GMSMapViewDelegate {}

// MARK: - CLLocationManagerDelegate
extension NewRouteViewController: CLLocationManagerDelegate {
    
    /**
     * When new location information is available check it's timestamp and accuracy, if it meets
     * requirments, added it to locations array.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
        
            // only accept locations less than 15 seconds old
            if location.timestamp.timeIntervalSinceNow > -30 {
                if location.horizontalAccuracy < 500 {
                    if !self.locations.contains(location){
                        self.locations.append(location)
                        setLocationAccessibilityLabel(location)
                    }
                }
            }
        }
    }
    
    /**
     *  When authorization changes, set mapview to display users location if able.
     */
    // TODO: What if user cuts location services mid recording?
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if let location = locationManager.location?.coordinate {
            mapView.animate(toLocation: location)
            mapView.isMyLocationEnabled = true
            setLocationAccessibilityLabel(CLLocation(latitude:location.latitude, longitude: location.longitude))
        } else {
            self.accessibilityMapLabel.accessibilityLabel = "Unable to get current location"
        }
    }
}

// Accessibility
extension NewRouteViewController {

    func setLocationAccessibilityLabel(_ location: CLLocation) {
    
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location.coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines!
                let currentAddress = lines.joined(separator: "\n")
                
                print("meters: \(location.horizontalAccuracy)")
                print("feet: \(location.horizontalAccuracy * 3.28084)")
                
                self.accessibilityCurrentLocationLabel.accessibilityLabel = "Current location is \(currentAddress). Accuracy: \(location.horizontalAccuracy * 3.28084) feet."
            } else {
                self.accessibilityCurrentLocationLabel.accessibilityLabel = "Unable to get current location. Please try again later."
            }
            if (!self.accessibilityCurrentLocationLabel.isHidden){
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.accessibilityCurrentLocationLabel)
            }
        }
    }

    func setRouteAccessibilityLabel(locations: [CLLocation]) {
        
        self.accessibilityMapLabel.isHidden = false
        self.accessibilityMapLabel.accessibilityLabel = "Checking route start and end points..."
        
        if let firstLocation = locations.first {
            
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(firstLocation.coordinate) { response, error in
                if let address = response?.firstResult() {
 
                    let lines = address.lines!
                    let startAddress = lines.joined(separator: "\n")
                    
                    if let endLocation = locations.last {
                    
                        geocoder.reverseGeocodeCoordinate(endLocation.coordinate) { response, error in
                            if let address = response?.firstResult() {
 
                                let lines = address.lines!
                                let endAddress = lines.joined(separator: "\n")
 
                                self.accessibilityMapLabel.accessibilityLabel = "Route starts near " + startAddress + " and ends near " + endAddress

                            }
                        }
                    }else {
                        self.accessibilityMapLabel.accessibilityLabel = "Route starts near " + startAddress + " and ends at an unknown location"
                    }
                } else {
                    self.accessibilityMapLabel.accessibilityLabel = "Route recorded but unable to determine recorded route start and end points because of network issues. Double tap to try again."
                    print(error ?? "no error found")

                    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapResponse(_:)))
                    tapGesture.numberOfTapsRequired = 1
                    self.accessibilityMapLabel.isUserInteractionEnabled =  true
                    self.accessibilityMapLabel.addGestureRecognizer(tapGesture)

                }
            }
        }
    }
   
    func tapResponse(_ recognizer: UITapGestureRecognizer) {
        setRouteAccessibilityLabel(locations: locations)
    
    }
    
    func screenChange() {
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 1, target: self,
                                   selector: #selector(self.timerDidFire(timer:)), userInfo: nil, repeats: false)
        }
    }

    @objc private func timerDidFire(timer: Timer) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.titleView)
    }
}
