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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var restAreaStack: UIStackView!
    @IBOutlet weak var restAreaImage: UIImageView!
    @IBOutlet weak var restAreaLabel: UILabel!
    @IBOutlet weak var restAreaName: UILabel!
    @IBOutlet weak var restAreaLocation: UILabel!
    @IBOutlet weak var restAreaDirection: UILabel!
    @IBOutlet weak var restAreaAmenities: UILabel!


    weak fileprivate var embeddedMapViewController: SimpleMapViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rest Area"
        
        restAreaLabel.text = "Rest Area"
        restAreaImage.image = UIImage(named: "icMapRestArea")

        embeddedMapViewController.view.isHidden = true
        
        if #available(iOS 14.0, *) {
        self.restAreaStack.backgroundColor = UIColor(red: 0/255, green: 174/255, blue: 199/255, alpha: 0.2)
        self.restAreaStack.layer.borderColor = UIColor(red: 0/255, green: 174/255, blue: 199/255, alpha: 1.0).cgColor
        self.restAreaStack.layer.borderWidth = 1
        self.restAreaStack.layer.cornerRadius = 4.0
        } else {
            let subView = UIView()
            subView.backgroundColor = UIColor(red: 0/255, green: 174/255, blue: 199/255, alpha: 0.2)
            subView.layer.borderColor = UIColor(red: 0/255, green: 174/255, blue: 199/255, alpha: 1.0).cgColor
            subView.layer.borderWidth = 1
            subView.layer.cornerRadius = 4.0
            subView.translatesAutoresizingMaskIntoConstraints = false
            restAreaStack.insertSubview(subView, at: 0)
            subView.topAnchor.constraint(equalTo: restAreaStack.topAnchor).isActive = true
            subView.bottomAnchor.constraint(equalTo: restAreaStack.bottomAnchor).isActive = true
            subView.leftAnchor.constraint(equalTo: restAreaStack.leftAnchor).isActive = true
            subView.rightAnchor.constraint(equalTo: restAreaStack.rightAnchor).isActive = true
            
        }
        
        
        var amenities: String = ""
        
        for amenity in restAreaItem!.amenities {
            amenities.append(amenity + ", ")
        }
        
        restAreaName.text = restAreaItem!.location
        restAreaName.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title3).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .title3).pointSize)

        restAreaLocation.attributedText = locationLabel(label: "Location: ", description: restAreaItem!.description)
        
        restAreaDirection.attributedText = locationLabel(label: "Direction: ", description: restAreaItem!.direction)
        
        restAreaAmenities.attributedText = amenitiesLabel(label: "Amenities: ", amenities: String(amenities.dropLast(2)))
                
        restAreaMarker.position = CLLocationCoordinate2D(latitude: restAreaItem!.latitude, longitude: restAreaItem!.longitude)
        
        scrollView.contentMode = .scaleAspectFit
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            restAreaMarker.map = mapView
            restAreaMarker.icon = UIImage(named: "icMapRestArea")

            mapView.settings.setAllGesturesEnabled(true)
            if let restArea = restAreaItem {
                mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: restArea.latitude, longitude: restArea.longitude), zoom: 14))
                embeddedMapViewController.view.isHidden = false
            }
        }
        
        self.embeddedMapViewController.view.layer.borderWidth = 0.5

        
        if #available(iOS 13, *){
            restAreaName.textColor = UIColor.label
            restAreaLocation.textColor = UIColor.label
            restAreaDirection.textColor = UIColor.label
            restAreaAmenities.textColor = UIColor.label

        }
        
    }
    
    func locationLabel(label: String, description: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        label.append(description)
        return label
    }
    
    func directionLabel(label: String, description: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        label.append(description)
        return label
    }
    
    func amenitiesLabel(label: String, amenities: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let amenities = NSMutableAttributedString(string: amenities, attributes: contentAttributes)
        label.append(amenities)
        return label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "RestArea")
    }
    
    func mapReady() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            restAreaMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(true)
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
