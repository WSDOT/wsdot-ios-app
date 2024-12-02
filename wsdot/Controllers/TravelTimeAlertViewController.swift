//
//  TravelTimeAlertViewController.swift
//  WSDOT
//
//  Copyright (c) 2024 Washington State Department of Transportation
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
import Foundation
import SafariServices

class TravelTimeAlertViewController: RefreshViewController, INDLinkLabelDelegate, MapMarkerDelegate, GMSMapViewDelegate {

    var travelTimeId = 0
    var travelTimeItem = TravelTimeItem()
    
    var travelTimeGroups = [TravelTimeItemGroup]()
    var filtered = [TravelTimeItemGroup]()

    let favoriteBarButton = UIBarButtonItem()
    
    var favoriteButtonSelected: Bool = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var travelTimeStack: UIStackView!
    @IBOutlet weak var travelTimeImage: UIImageView!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var travelTimeName: UILabel!
    
    @IBOutlet weak var travelTimeVia: UILabel!
    @IBOutlet weak var travelTimeDistance: UILabel!
    @IBOutlet weak var travelTimeAverageTime: UILabel!
    @IBOutlet weak var travelTimeCurrentTime: UILabel!
    @IBOutlet weak var travelTimeHOVCurrentTime: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    
    fileprivate var startMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    fileprivate var endMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))

    var startLatitude = 0.0
    var startLongitude = 0.0
    
    var endLatitude = 0.0
    var endLongitude = 0.0

    weak fileprivate var embeddedMapViewController: SimpleMapViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAlert()
        
        favoriteBarButton.action = #selector(TravelTimeAlertViewController.favoriteAction(_:))
        favoriteBarButton.target = self
        favoriteBarButton.tintColor = Colors.yellow
        
        embeddedMapViewController.view.isHidden = true

    }
    
    func loadAlert(){
        
        showOverlay(self.view)
        
        startMarker.map = nil
        endMarker.map = nil

        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TravelTimesStore.updateTravelTimes(true, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            
                            if let alertItemValue = TravelTimesStore.findAlert(withId: selfValue.travelTimeId) {
                                selfValue.travelTimeItem = alertItemValue
                                selfValue.mapReady()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    selfValue.displayAlert()
                                    selfValue.hideOverlayView()
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in

                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.travelTimes)
                        }
                    }
                }
            })
        }
    }
    
    func displayAlert() {
        self.title = "Travel Time"
        
        travelTimeLabel.text = "Travel Time"
        travelTimeImage.image = UIImage(named: "icTravelTime")
        
        if #available(iOS 14.0, *) {
        self.travelTimeStack.backgroundColor = UIColor(red: 150/255, green: 53/255, blue: 159/255, alpha: 0.2)
        self.travelTimeStack.layer.borderColor = UIColor(red: 150/255, green: 53/255, blue: 159/255, alpha: 1.0).cgColor
        self.travelTimeStack.layer.borderWidth = 1
        self.travelTimeStack.layer.cornerRadius = 4.0
        } else {
            let subView = UIView()
            subView.backgroundColor = UIColor(red: 150/255, green: 53/255, blue: 159/255, alpha: 0.2)
            subView.layer.borderColor = UIColor(red: 150/255, green: 53/255, blue: 159/255, alpha: 1.0).cgColor
            subView.layer.borderWidth = 1
            subView.layer.cornerRadius = 4.0
            subView.translatesAutoresizingMaskIntoConstraints = false
            travelTimeStack.insertSubview(subView, at: 0)
            subView.topAnchor.constraint(equalTo: travelTimeStack.topAnchor).isActive = true
            subView.bottomAnchor.constraint(equalTo: travelTimeStack.bottomAnchor).isActive = true
            subView.leftAnchor.constraint(equalTo: travelTimeStack.leftAnchor).isActive = true
            subView.rightAnchor.constraint(equalTo: travelTimeStack.rightAnchor).isActive = true
            
        }
        
        
        travelTimeName.text = travelTimeItem.title
        travelTimeName.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        
        travelTimeVia.attributedText = travelTimeViaLabel(label: "Routes: ", description: travelTimeItem.viaText)
        travelTimeDistance.attributedText = travelTimeDistanceLabel(label: "Distance: ", description: travelTimeItem.distance.description, miles: " miles")
        
        if (travelTimeItem.currentTime == -1) {
            travelTimeAverageTime.attributedText = travelTimeAverageTimeLabel(label: "Average Time: ", description: "N/A", minutes: "")
            travelTimeCurrentTime.attributedText = travelTimeCurrentTimeLabel(label: "Current Time: ", description: "N/A", minutes: "")
        }
        else {
            travelTimeAverageTime.attributedText = travelTimeAverageTimeLabel(label: "Average Time: ", description: travelTimeItem.averageTime.description, minutes: " minutes")
            travelTimeCurrentTime.attributedText = travelTimeCurrentTimeLabel(label: "Current Time: ", description: travelTimeItem.currentTime.description, minutes: " minutes")
        }
                
        if (travelTimeItem.hovCurrentTime == 0) {
            travelTimeHOVCurrentTime.attributedText = travelTimeHOVTimeLabel(label: "HOV Lane Time: ", description: "N/A", minutes: "")
        }
        else {
            travelTimeHOVCurrentTime.attributedText = travelTimeHOVTimeLabel(label: "HOV Lane Time: ", description: travelTimeItem.hovCurrentTime.description, minutes: " minutes")
        }

        do {
            let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(travelTimeItem.updated), numericDates: true)
            updateTimeLabel.text = updated
        } catch {
            updateTimeLabel.text = "N/A"
        }
                        
        if #available(iOS 13, *){
            travelTimeName.textColor = UIColor.label
            travelTimeDistance.textColor = UIColor.label

        }
        
        travelTimeGroups = TravelTimesStore.getAllTravelTimeGroups()
        
        for routes in travelTimeGroups {
            if ((routes.selected) && (routes.title == travelTimeItem.title)) {
                favoriteButtonSelected = true
            }
        }
        
        if (favoriteButtonSelected) {
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }
        
        self.navigationItem.rightBarButtonItems = [favoriteBarButton]
        
        self.embeddedMapViewController.view.isHidden = false
        
    }
    
    func travelTimeViaLabel(label: String, description: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        label.append(description)
        
        return label
    }
    
    func travelTimeDistanceLabel(label: String, description: String, miles: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        let miles = NSMutableAttributedString(string: miles, attributes: contentAttributes)
        label.append(description)
        label.append(miles)

        return label
    }
    
    func travelTimeAverageTimeLabel(label: String, description: String, minutes: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        let minutes = NSMutableAttributedString(string: minutes, attributes: contentAttributes)
        label.append(description)
        label.append(minutes)
        return label
    }
    
    func travelTimeCurrentTimeLabel(label: String, description: String, minutes: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        let minutes = NSMutableAttributedString(string: minutes, attributes: contentAttributes)
        label.append(description)
        label.append(minutes)
        return label
    }
    
    func travelTimeHOVTimeLabel(label: String, description: String, minutes: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        let minutes = NSMutableAttributedString(string: minutes, attributes: contentAttributes)
        label.append(description)
        label.append(minutes)
        return label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TravelTime")
    }
    
    func mapReady() {

        self.embeddedMapViewController.view.isHidden = true
        self.embeddedMapViewController.view.layer.borderWidth = 0.5
            
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                
                mapView.settings.setAllGesturesEnabled(true)
                let travelTime = travelTimeItem
                    mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: travelTime.startLatitude, longitude: travelTime.startLongitude), zoom: 12))
                
                var locationArray = [[String: Double]]()
                locationArray = [["latitude": travelTime.startLatitude,"longitude": travelTime.startLongitude], ["latitude": travelTime.endLatitude, "longitude": travelTime.endLongitude]]

            var bounds = GMSCoordinateBounds()
            for location in locationArray
            {
                let latitude = location["latitude"]
                let longitude = location["longitude"]

                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude:latitude!, longitude:longitude!)
                bounds = bounds.includingCoordinate(marker.position)
            }

            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView.animate(with: update)
            CATransaction.commit()
            
            startMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: travelTime.startLatitude, longitude: travelTime.startLongitude))
            startMarker.icon = GMSMarker.markerImage(with: UIColor.green)
                            
            endMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: travelTime.endLatitude, longitude: travelTime.endLongitude))
            endMarker.icon = GMSMarker.markerImage(with: UIColor.red)

            startMarker.map = mapView
            endMarker.map = mapView
                          
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
    
    // MARK: Favorite action
    @objc func favoriteAction(_ sender: UIButton) {
        
        for routes in travelTimeGroups {
            if (!favoriteButtonSelected && routes.title == travelTimeItem.title) {
                
                filtered.append(routes)
                TravelTimesStore.updateFavorite(filtered[0], newValue: true)
                favoriteButtonSelected = true
                
                favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
                favoriteBarButton.accessibilityLabel = "add to favorites"
                
            }
            else if (favoriteButtonSelected && routes.title == travelTimeItem.title) {
                
                filtered.append(routes)
                TravelTimesStore.updateFavorite(filtered[0], newValue: false)
                favoriteButtonSelected = false
                
                favoriteBarButton.image = UIImage(named: "icStarSmall")
                favoriteBarButton.accessibilityLabel = "remove from favorites"
            }
        }
    }
}

extension GMSMutablePath {
    convenience init(coordinates: [CLLocationCoordinate2D]) {
        self.init()
        for coordinate in coordinates {
            add(coordinate)
        }
    }
}

extension GMSMapView {
    func addPath(_ path: GMSPath, strokeColor: UIColor? = nil, strokeWidth: CGFloat? = nil, geodesic: Bool? = nil, spans: [GMSStyleSpan]? = nil) {
        let line = GMSPolyline(path: path)
        line.strokeColor = strokeColor ?? line.strokeColor
        line.strokeWidth = strokeWidth ?? line.strokeWidth
        line.geodesic = geodesic ?? line.geodesic
        line.spans = spans ?? line.spans
        line.map = self
    }
}
