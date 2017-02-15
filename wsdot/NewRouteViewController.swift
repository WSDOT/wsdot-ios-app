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

        recordingAlertView.addButton("Finish") {
            self.stopRecordingPressed()
        }
        
        navigationItem.hidesBackButton = true
        self.view.accessibilityElementsHidden = true
        
        _ = recordingAlertView.showCustom("Let's Go!", subTitle: "\nTracking route...\n\n Please do not use the WSDOT app while you are driving.", color: Colors.tintColor, icon: alertViewIcon!)

        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);

    }

    /**
     * Method name: startRoutePressed(_:)
     * Description: Action for when the start recording route button is pressed.
     *              Checks app permissions and starts process of recording users location if able.
     * Parameters: sender: UIButton
     */
    @IBAction func startRoutePressed(_ sender: UIButton) {
 
        GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Started Recording Route")
 
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
            // self.locations = MyRouteStore.getFakeData()
            
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
        
        let nameRouteAlertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: false,
            shouldAutoDismiss: false)
        )
        
        let name = nameRouteAlertView.addTextField("My Route")
        
        nameRouteAlertView.addButton("OK") {
            
            nameRouteAlertView.hideView()
            
            GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Saved Route")
        
            if name.text!.trimmingCharacters(in: .whitespaces) == "" {
                name.text = "My Route"
            }
        
            let id =  MyRouteStore.save(route: self.locations, name: name.text!,
                                        displayLat: self.mapView.projection.coordinate(for: self.mapView.center).latitude,
                                        displayLong: self.mapView.projection.coordinate(for: self.mapView.center).longitude,
                                        displayZoom: self.mapView.camera.zoom)
            
            let addFavoritesAlertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                showCloseButton: false,
                showCircularIcon: true,
                shouldAutoDismiss: false)
            )
        
            addFavoritesAlertView.addButton("Yes") {
                addFavoritesAlertView.hideView()
                self.navigationItem.hidesBackButton = false
                self.view.accessibilityElementsHidden = false
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            addFavoritesAlertView.addButton("No"){
                addFavoritesAlertView.hideView()
                self.navigationItem.hidesBackButton = false
                self.view.accessibilityElementsHidden = false
                _ = MyRouteStore.updateFindNearby(forRoute: MyRouteStore.getRouteById(id)!, foundCameras: true, foundTimes: true, foundFerries: true, foundPasses: true)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            let alertViewIcon = UIImage(named: "icFavoritesTab")
            
            addFavoritesAlertView.iconTintColor = UIColor.white
            
            _ = addFavoritesAlertView.showCustom("Add Favorites?",
                    subTitle: "Traffic cameras, travel times, pass reports, and other content will be added to your favorites if they are on this route. \n\n You can do this later by tapping \"Edit\" on the My Routes screen.", color: Colors.tintColor, icon: alertViewIcon!)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
        }
        
        self.navigationItem.hidesBackButton = true
        self.view.accessibilityElementsHidden = true
        
        _ = nameRouteAlertView.showCustom("Name This Route", subTitle: "This name will display on your favorites lists", color: Colors.tintColor, icon: UIImage(named:"icFavoritesTab")!)
    
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
    
    /**
     * Method name: discardButtonPressed(_:)
     * Description: Displays confirmation alert controller before clearing out the locations array.
     * Parameters: sender: UIButton
     */
    @IBAction func discardButtonPressed(_ sender: UIButton) {

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
        
        discardButton.layer.cornerRadius = 5
        discardButton.clipsToBounds = true
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
        }
    }
    
}
