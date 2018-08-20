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

class HighwayAlertViewController: UIViewController, INDLinkLabelDelegate, MapMarkerDelegate, GMSMapViewDelegate {


    var alertId = 0
    var alertItem = HighwayAlertItem()
    fileprivate let alertMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var descLinkLabel: INDLinkLabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activityIndicator = UIActivityIndicatorView()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Highway Alert")
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
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    func displayAlert() {
        title = alertItem.eventCategory
        
        let htmlStyleString = "<style>body{font-family: '\(descLinkLabel.font.fontName)'; font-size:\(descLinkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + alertItem.headlineDesc
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        descLinkLabel.attributedText = attrStr

        updateTimeLabel.text = TimeUtils.timeAgoSinceDate(date: alertItem.lastUpdatedTime, numericDates: false)
        
        alertMarker.position = CLLocationCoordinate2D(latitude: self.alertItem.startLatitude, longitude: self.alertItem.startLongitude)
        alertMarker.icon = UIHelpers.getAlertIcon(forAlert: self.alertItem)
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.alertItem.startLatitude, longitude: self.alertItem.startLongitude), zoom: 14))
        }

        self.embeddedMapViewController.view.isHidden = false

    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func drawMapOverlays() {
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            alertMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(false)
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.alertItem.startLatitude, longitude: self.alertItem.startLongitude), zoom: 14))
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
        let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
}
