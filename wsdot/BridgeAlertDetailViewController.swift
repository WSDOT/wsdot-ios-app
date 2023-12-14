//
//  BridgeAlertDetailViewController.swift
//  WSDOT
//
//  Copyright (c) 2022 Washington State Department of Transportation
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

class BridgeAlertDetailViewController: RefreshViewController, INDLinkLabelDelegate, MapMarkerDelegate, GMSMapViewDelegate {

    var alertId = 0
    var bridgeAlertItem = BridgeAlertItem()

    fileprivate let alertMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var descLinkLabel: INDLinkLabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryStack: UIStackView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryStackTopConstraint: NSLayoutConstraint!

    var hasAlert: Bool = true
    var fromPush: Bool = false
    var pushLat: Double = 0.0
    var pushLong: Double = 0.0
    var pushMessage: String = ""
    var location: String = ""

    
    weak fileprivate var embeddedMapViewController: SimpleMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        embeddedMapViewController.view.isHidden = true
        descLinkLabel.delegate = self
        
        if (hasAlert) {
            loadBridgeAlert()
            
        } else {
            descLinkLabel.text = pushMessage
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "BridgeAlert")
    }
    
    func loadBridgeAlert(){
        
        showOverlay(self.view)
        let force = self.fromPush
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            BridgeAlertsStore.updateBridgeAlerts(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            
                            if let alertItemValue = BridgeAlertsStore.findBridgeAlert(withId: selfValue.alertId) {
                                selfValue.bridgeAlertItem = alertItemValue
                                selfValue.displayBridgeAlert()
                                
                            } else {
                                selfValue.title = "Unavailable"
                                selfValue.descLinkLabel.text = "Sorry, This incident has expired."
                                selfValue.updateTimeLabel.text = "Unavailable"
                                selfValue.categoryStackTopConstraint.constant = 0

                            }
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in

                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.bridgeAlerts)
                        }
                    }
                }
            })
        }
    }

   
    func displayBridgeAlert() {
        
        title = "Alert"
        
        categoryImage.image = UIHelpers.getBridgeAlertIcon(forAlert: self.bridgeAlertItem)
        categoryLabel.text = bridgeAlertItem.bridge
        
        self.categoryStack.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 0.3)
        self.categoryStack.layer.borderColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0).cgColor
        self.categoryStack.layer.borderWidth = 1
        self.categoryStack.layer.cornerRadius = 4.0

        let htmlStyleString = "<style>*{font-family:-apple-system}h1{font: -apple-system-title2; font-weight:bold}body{font: -apple-system-body}b{font: -apple-system-headline}</style>"
        
        if (bridgeAlertItem.roadName != "" && bridgeAlertItem.direction != "") {
            location = "<h1>" + bridgeAlertItem.roadName + " " + bridgeAlertItem.direction + "</h1>"
        }

        
        let description = location + "<b>Description: </b>" + bridgeAlertItem.descText
        let htmlString = htmlStyleString + description
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        descLinkLabel.attributedText = attrStr

        updateTimeLabel.text = TimeUtils.timeAgoSinceDate(date: bridgeAlertItem.localCacheDate, numericDates: false)

        // if location is 0,0 set coordinates in center of WA so we can
        // show the whole state
        let lat = self.bridgeAlertItem.latitude.isEqual(to: 0.0) ? 47.7511 : self.bridgeAlertItem.latitude
        let long = self.bridgeAlertItem.longitude.isEqual(to: 0.0) ? -120.7401 : self.bridgeAlertItem.longitude
        
        let zoom = (self.bridgeAlertItem.latitude.isEqual(to: 0.0) && self.bridgeAlertItem.latitude.isEqual(to: 0.0)) ? 6 : 14
        
        alertMarker.position = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
        
        alertMarker.icon = UIHelpers.getBridgeAlertIcon(forAlert: self.bridgeAlertItem)
        
        categoryImage.image = UIHelpers.getBridgeAlertIcon(forAlert: self.bridgeAlertItem)

        if let mapView = embeddedMapViewController.view as? GMSMapView{
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: lat, longitude: long), zoom: Float(zoom)))
        }

        self.embeddedMapViewController.view.isHidden = false
        self.embeddedMapViewController.view.layer.borderWidth = 0.5

        if #available(iOS 13, *){
            descLinkLabel.textColor = UIColor.label
        }
    }
    
    func mapReady() {
        
        if (self.bridgeAlertItem.latitude.isEqual(to: 0.0)
            && self.bridgeAlertItem.longitude.isEqual(to: 0.0)) {
        
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                print("here 1")
                
                alertMarker.map = mapView
                mapView.settings.setAllGesturesEnabled(true)
                mapView.moveCamera(GMSCameraUpdate.setTarget(
                    CLLocationCoordinate2D(latitude: 47.7511,longitude: -120.7401),
                    zoom: 6))
                
            }
            
        } else {
            if let mapView = embeddedMapViewController.view as? GMSMapView{
                print("here 2")
                alertMarker.map = mapView
                mapView.settings.setAllGesturesEnabled(true)
                mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.bridgeAlertItem.latitude, longitude: self.bridgeAlertItem.longitude), zoom: 14))
            }
        }
    }
    
    // MARK: Navigation
    // Get reference to child VC
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
        config.entersReaderIfAvailable = false
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
