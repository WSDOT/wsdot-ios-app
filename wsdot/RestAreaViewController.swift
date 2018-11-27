//
//  RestAreaViewController.swift
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

class RestAreaViewController: UIViewController, MapMarkerDelegate, GMSMapViewDelegate {

    var restAreaItem: RestAreaItem?
    fileprivate let restAreaMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var milepostLabel: UILabel!
    @IBOutlet weak var amenities: UILabel!

    weak fileprivate var embeddedMapViewController: SimpleMapViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rest Area"
    
        embeddedMapViewController.view.isHidden = true
    
        locationLabel.text = restAreaItem!.route + " - " + restAreaItem!.location
        directionLabel.text = restAreaItem!.direction
        milepostLabel.text = String(restAreaItem!.milepost)
        
        amenities.text? = ""
        
        restAreaMarker.position = CLLocationCoordinate2D(latitude: restAreaItem!.latitude, longitude: restAreaItem!.longitude)
        
        for amenity in restAreaItem!.amenities {
            amenities.text?.append("• " + amenity + "\n")
        }
        
        scrollView.contentMode = .scaleAspectFit
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            restAreaMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(false)
            if let restArea = restAreaItem {
                mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: restArea.latitude, longitude: restArea.longitude), zoom: 14))
                embeddedMapViewController.view.isHidden = false
            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "RestArea")
    }
    
    func mapReady() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            restAreaMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(false)
            if let restArea = restAreaItem {
                mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: restArea.latitude, longitude: restArea.longitude), zoom: 14))
                embeddedMapViewController.view.isHidden = false
            }
        }
    }
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        print("here 1")
        
        if let vc = segue.destination as? SimpleMapViewController, segue.identifier == "EmbedMapSegue" {
            
            print("here 2")
            
            vc.markerDelegate = self
            vc.mapDelegate = self
            self.embeddedMapViewController = vc
        }
    }
    

}
