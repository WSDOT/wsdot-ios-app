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
    
    @IBOutlet weak var locationLabel: INDLinkLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var restAreaStack: UIStackView!
    @IBOutlet weak var restAreaImage: UIImageView!
    @IBOutlet weak var restAreaLabel: UILabel!

    weak fileprivate var embeddedMapViewController: SimpleMapViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rest Area"
        
        restAreaLabel.text = "Rest Area"
        restAreaImage.image = UIImage(named: "icMapRestArea")

        embeddedMapViewController.view.isHidden = true
        
        self.restAreaStack.backgroundColor = UIColor(red: 0/255, green: 174/255, blue: 199/255, alpha: 0.2)
        self.restAreaStack.layer.borderColor = UIColor(red: 0/255, green: 174/255, blue: 199/255, alpha: 1.0).cgColor
        self.restAreaStack.layer.borderWidth = 1
        self.restAreaStack.layer.cornerRadius = 4.0
        
        var amenities: String = ""
        
        for amenity in restAreaItem!.amenities {
            amenities.append("• " + amenity + "<br>")
        }
        
        let htmlStyleString = "<style>body{font-family: '\(locationLabel.font.familyName)'; font-size:\(locationLabel.font.pointSize)px;}</style>"
        
        let content = "<b>" + restAreaItem!.location + " " + restAreaItem!.direction + "</b><br><br>" + "<b>Location: </b>" + restAreaItem!.description + "<br><br>" + "<b>Amenities</b><br>" + amenities

        let htmlString = htmlStyleString + content
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        locationLabel.attributedText = attrStr
        
        restAreaMarker.position = CLLocationCoordinate2D(latitude: restAreaItem!.latitude, longitude: restAreaItem!.longitude)
        
        scrollView.contentMode = .scaleAspectFit
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            restAreaMarker.map = mapView
            restAreaMarker.icon = UIImage(named: "icMapRestArea")

            mapView.settings.setAllGesturesEnabled(false)
            if let restArea = restAreaItem {
                mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: restArea.latitude, longitude: restArea.longitude), zoom: 14))
                embeddedMapViewController.view.isHidden = false
            }
        }
        
        self.embeddedMapViewController.view.layer.borderWidth = 0.5

        
        if #available(iOS 13, *){
            locationLabel.textColor = UIColor.label

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
