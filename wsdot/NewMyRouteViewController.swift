//
//  NewMyRouteViewController.swift
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

class NewMyRouteViewController: UIViewController {

    var distance = 0.0

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
 
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
 

    lazy var locations = [CLLocation]()
    lazy var timer = Timer()

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stopButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestAlwaysAuthorization()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }


    @IBAction func startRoutePressed(_ sender: UIButton) {
        distance = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(updateDistance(_:)),
            userInfo: nil,
        repeats: true)
        startLocationUpdates()
        startButton.isHidden = true
        stopButton.isHidden = false
        
    }

    @IBAction func stopRecordingPressed(_ sender: UIButton) {
        stopLocationUpdates()
        startButton.isHidden = false
        stopButton.isHidden = true
        timer.invalidate()
    }

    func updateDistance(_ timer: Timer) {
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        distanceLabel.text = "Distance: " + distanceQuantity.description

    }

    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates(){
        locationManager.stopUpdatingLocation()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - CLLocationManagerDelegate
extension NewMyRouteViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print("new location information")
        for location in locations as! [CLLocation] {
            if location.horizontalAccuracy < 50 {
            
                //update distance
                if self.locations.count > 0 {
                    if let lastValue = self.locations.last {
                        distance += location.distance(from: lastValue)
                    }
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }



}
