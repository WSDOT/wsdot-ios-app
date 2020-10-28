//
//  HighwayAlertViewController.swift
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
import Foundation
import SafariServices

class HighwayAlertViewController: RefreshViewController, INDLinkLabelDelegate, MapMarkerDelegate, GMSMapViewDelegate {


    var alertId = 0
    var alertItem = HighwayAlertItem()
    fileprivate let alertMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var descLinkLabel: INDLinkLabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fromPush: Bool = false
    var pushLat: Double = 0.0
    var pushLong: Double = 0.0
    
    weak fileprivate var embeddedMapViewController: SimpleMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        embeddedMapViewController.view.isHidden = true
        
        descLinkLabel.delegate = self
        loadAlert()
        
        if (fromPush){
            UserDefaults.standard.set(pushLat, forKey: UserDefaultsKeys.mapLat)
            UserDefaults.standard.set(pushLong, forKey: UserDefaultsKeys.mapLon)
            UserDefaults.standard.set(15, forKey: UserDefaultsKeys.mapZoom)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "HighwayAlert")
    }
    
    func loadAlert(){
        
        showOverlay(self.view)
        
        let force = self.fromPush
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            HighwayAlertsStore.updateAlerts(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            
                            if let alertItemValue = HighwayAlertsStore.findAlert(withId: selfValue.alertId) {
                            
                                selfValue.alertItem = alertItemValue
                                selfValue.displayAlert()
                                
                            } else {
                            
                                selfValue.title = "Unavailable"
                                selfValue.descLinkLabel.text = "Sorry, This incident has expired."
                                selfValue.updateTimeLabel.text = "Unavailable"
                            
                            }
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in

                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.highwayAlert)
                        }
                    }
                }
            })
        }
    }

    func displayAlert() {
        title = alertItem.eventCategory
        
        let htmlStyleString = "<style>body{font-family: '\(descLinkLabel.font.familyName)'; font-size:\(descLinkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + alertItem.headlineDesc
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        descLinkLabel.attributedText = attrStr

        updateTimeLabel.text = TimeUtils.timeAgoSinceDate(date: alertItem.lastUpdatedTime, numericDates: false)

        // if location is 0,0 set coordinates in center of WA so we can
        // show the whole state
        let lat = self.alertItem.startLatitude.isEqual(to: 0.0) ? 47.7511 : self.alertItem.startLatitude
        let long = self.alertItem.startLongitude.isEqual(to: 0.0) ? -120.7401 : self.alertItem.startLongitude
        
        let zoom = (self.alertItem.startLatitude.isEqual(to: 0.0) && self.alertItem.startLongitude.isEqual(to: 0.0)) ? 6 : 14
        
        alertMarker.position = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
        
        alertMarker.icon = UIHelpers.getAlertIcon(forAlert: self.alertItem)
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: lat, longitude: long), zoom: Float(zoom)))
        }

        self.embeddedMapViewController.view.isHidden = false

        if #available(iOS 13, *){
            descLinkLabel.textColor = UIColor.label
        }
    }
    
    func mapReady() {
        
        if (self.alertItem.startLatitude.isEqual(to: 0.0)
            && self.alertItem.startLongitude.isEqual(to: 0.0)) {
        
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                print("here 1")
                
                alertMarker.map = mapView
                mapView.settings.setAllGesturesEnabled(false)
                mapView.moveCamera(GMSCameraUpdate.setTarget(
                    CLLocationCoordinate2D(latitude: 47.7511,longitude: -120.7401),
                    zoom: 6))
                
            }
            
        } else {
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                print("here 2")
                alertMarker.map = mapView
                mapView.settings.setAllGesturesEnabled(false)
                mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.alertItem.startLatitude, longitude: self.alertItem.startLongitude), zoom: 14))
            }
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
    
    
    // MARK: INDLinkLabelDelegate
    
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let svc = SFSafariViewController(url: URL, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
}
