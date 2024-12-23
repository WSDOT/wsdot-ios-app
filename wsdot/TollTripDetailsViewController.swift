//
//  TollTripDetailsViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

class TollTripDetailsViewController: RefreshViewController, MapMarkerDelegate, GMSMapViewDelegate {

    var text = ""
    
    fileprivate var startMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    fileprivate var endMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    
    var startLatitude = 0.0
    var startLongitude = 0.0
    
    var endLatitude = 0.0
    var endLongitude = 0.0

    weak fileprivate var embeddedMapViewController: SimpleMapViewController!

    @IBOutlet weak var infoLinkLabel: INDLinkLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showOverlay(self.view)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TollTripDetails")
        
        hideOverlayView()
        
        let htmlStyleString = "<style>body{font-family: '-apple-system'; font-size:\(infoLinkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + "Travel as far as " + text
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        infoLinkLabel.attributedText = attrStr
        
        if #available(iOS 13, *) {
            infoLinkLabel.textColor = UIColor.label
        }
        
        embeddedMapViewController.view.isHidden = false


    }
    
    func mapReady() {

        self.embeddedMapViewController.view.layer.borderWidth = 0.5
        self.embeddedMapViewController.view.isHidden = true

        if let mapView = embeddedMapViewController.view as? GMSMapView {
            
            mapView.settings.setAllGesturesEnabled(true)
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude), zoom: 12))
                
            var locationArray = [[String: Double]]()
            locationArray = [["latitude": startLatitude,"longitude": startLongitude], ["latitude": endLatitude, "longitude": endLongitude]]

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
            
            startMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude))
            startMarker.icon = GMSMarker.markerImage(with: UIColor.green)
                            
            endMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude))
            endMarker.icon = GMSMarker.markerImage(with: UIColor.red)

            startMarker.map = mapView
            endMarker.map = mapView
                
            mapView.setMinZoom(0, maxZoom: 14)
                          
        }
        
    }
    
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SimpleMapViewController, segue.identifier == "EmbedMapSegue" {
            vc.markerDelegate = self
            vc.mapDelegate = self
            self.embeddedMapViewController = vc
        }
    }
    
}
