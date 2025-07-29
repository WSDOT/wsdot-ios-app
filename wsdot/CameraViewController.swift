//
//  CameraViewController.swift
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
import GoogleMobileAds

class CameraViewController: UIViewController, BannerViewDelegate, MapMarkerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var cameraImage: UIImageView!
    fileprivate let cameraMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bannerView: AdManagerBannerView!
    
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var cameraDirectionLabel: UILabel!
    @IBOutlet weak var cameraRefreshLabel: UILabel!

    @IBOutlet weak var cameraIconStack: UIStackView!
    @IBOutlet weak var cameraIconImage: UIImageView!
    @IBOutlet weak var cameraIconLabel: UILabel!
    
    fileprivate weak var timer: Timer?
    
    weak fileprivate var embeddedMapViewController: SimpleMapViewController!
    
    var cameraItem: CameraItem = CameraItem()
    var adTarget: String = "other"
    var adsEnabled = true
    var vesselWatchSegue = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (vesselWatchSegue) {
            self.navigationItem.title = "Cameras"
        }
        else {
            self.navigationItem.title = cameraItem.roadName
        }

        cameraIconLabel.text = "Camera"
        cameraIconImage.image = UIImage(named: "icMapCamera")
        
        if #available(iOS 14.0, *) {
        self.cameraIconStack.backgroundColor = UIColor(red: 0/255, green: 123/255, blue: 95/255, alpha: 0.2)
        self.cameraIconStack.layer.borderColor = UIColor(red: 0/255, green: 123/255, blue: 95/255, alpha: 1.0).cgColor
        self.cameraIconStack.layer.borderWidth = 1
        self.cameraIconStack.layer.cornerRadius = 4.0
        } else {
            let subView = UIView()
            subView.backgroundColor = UIColor(red: 0/255, green: 123/255, blue: 95/255, alpha: 0.2)
            subView.layer.borderColor = UIColor(red: 0/255, green: 123/255, blue: 95/255, alpha: 1.0).cgColor
            subView.layer.borderWidth = 1
            subView.layer.cornerRadius = 4.0
            subView.translatesAutoresizingMaskIntoConstraints = false
            
            cameraIconStack.insertSubview(subView, at: 0)

            subView.topAnchor.constraint(equalTo: cameraIconStack.topAnchor).isActive = true
            subView.bottomAnchor.constraint(equalTo: cameraIconStack.bottomAnchor).isActive = true
            subView.leftAnchor.constraint(equalTo: cameraIconStack.leftAnchor).isActive = true
            subView.rightAnchor.constraint(equalTo: cameraIconStack.rightAnchor).isActive = true
            
        }
        

        embeddedMapViewController.view.isHidden = false
        
        if (cameraItem.selected) {
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        } else {
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }
        
        favoriteBarButton.tintColor = Colors.yellow
        cameraTitleLabel.attributedText = titleLabel(description: cameraItem.title)

        if (cameraItem.direction != "") {
            cameraDirectionLabel.attributedText = directionLabel(label: "Camera Direction: ", description: getDirection(direction: cameraItem.direction))
        }
        else {
            cameraDirectionLabel.isHidden = true
        }
        
        cameraRefreshLabel.attributedText = refreshRateLabel(label: "Refresh Rate: ", description: "Approximately every 5 minutes.")

        // Set up map marker
        cameraMarker.position = CLLocationCoordinate2D(latitude: self.cameraItem.latitude, longitude: self.cameraItem.longitude)
        cameraMarker.icon = UIImage(named: "icMapCamera")
        
        self.embeddedMapViewController.view.isHidden = false
        self.embeddedMapViewController.view.layer.borderWidth = 0.5
        
        // Ad Banner
        if (adsEnabled) {
            bannerView.adUnitID = ApiKeys.getAdId()
            bannerView.rootViewController = self
            bannerView.adSize = getFullWidthAdaptiveAdSize()
            let request = AdManagerRequest()
            request.customTargeting = ["wsdotapp":adTarget]
        
            bannerView.load(request)
            bannerView.delegate = self
        } else {
            bannerView.isHidden = true
        }
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(CachesStore.cameraRefreshTime), target: self, selector: #selector(CameraViewController.updateCamera(_:)), userInfo: nil, repeats: true)
        
    }
    
    func adViewDidReceiveAd(_ bannerView: BannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    @objc func updateCamera(_ sender: Timer){
        self.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // This is incase the camera is in a pager view
        // and needs to add the marker again because it
        // isn't properly added when the pager sets up the
        // side page views.
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            cameraMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(true)
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.cameraItem.latitude, longitude: self.cameraItem.longitude), zoom: 12))
            
            // Check for traffic layer settings
            if (vesselWatchSegue) {
                    let trafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.ferryTrafficLayer)
                    if let trafficLayerVisible = trafficLayerPref {
                        if (trafficLayerVisible == "on") {
                            UserDefaults.standard.set("on", forKey: UserDefaultsKeys.ferryTrafficLayer)
                            mapView.isTrafficEnabled = true
                        } else {
                            UserDefaults.standard.set("off", forKey: UserDefaultsKeys.ferryTrafficLayer)
                            mapView.isTrafficEnabled = false
                        }
                    }
                }
            
            else {
                let trafficLayerPref = UserDefaults.standard.string(forKey: UserDefaultsKeys.trafficLayer)
                if let trafficLayerVisible = trafficLayerPref {
                    if (trafficLayerVisible == "on") {
                        mapView.isTrafficEnabled = true
                    } else {
                        mapView.isTrafficEnabled = false
                    }
                }
            }
        }
        
        let placeholder: UIImage? = UIImage(named: "imagePlaceholder")
                    
        // Add timestamp to help prevent caching
        let urlString = cameraItem.url + "?" + String(Int(Date().timeIntervalSince1970 / 60))
        
           
        cameraImage.sd_setImage(with: URL(string: urlString), placeholderImage: placeholder, options: .refreshCached, completed: { image, error, cacheType, imageURL in
                                         
                if (error != nil) {
                    self.cameraImage.image = UIImage(named: "cameraOffline")
                } else {
      
                    self.cameraImage.widthAnchor.constraint(equalTo: self.cameraImage.heightAnchor, multiplier: (self.cameraImage.image?.size.width)! / (self.cameraImage.image?.size.height)!).isActive = true
                      
                }
            }
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "CameraImage")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent {
            if timer != nil {
                self.timer?.invalidate()
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
    
    func mapReady() {
        
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            cameraMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(true)
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.cameraItem.latitude, longitude: self.cameraItem.longitude), zoom: 12))
        }
    
    }
    
    @IBAction func updateFavorite(_ sender: UIBarButtonItem) {
        if (cameraItem.selected){
            CamerasStore.updateFavorite(cameraItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }else {
            CamerasStore.updateFavorite(cameraItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }
    }
    
    func titleLabel(description: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)]
        let description = NSMutableAttributedString(string: description, attributes: titleAttributes)
        return description
    }
    
    func directionLabel(label: String, description: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize - 0.1, weight: .bold)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize - 0.1, weight: .regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        label.append(description)
        return label
    }
    
    func refreshRateLabel(label: String, description: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize - 0.1, weight: .bold)]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize - 0.1, weight: .regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let description = NSMutableAttributedString(string: description, attributes: contentAttributes)
        label.append(description)
        return label
    }
    
    
    // Changes direction names
     func getDirection(direction: String) -> String {
    
        var direction = cameraItem.direction
    
        if direction == "B" {
            direction = "This camera moves to point in more than one direction."
        }
        
        if direction == "N" {
            direction = "North"
        }

        if direction == "E" {
            direction = "East"
        }
        
        if direction == "S" {
            direction = "South"
        }
         
         if direction == "W" {
             direction = "West"
         }
        
        return direction
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
          
          cameraTitleLabel.attributedText = titleLabel(description: cameraItem.title)
         
          cameraDirectionLabel.attributedText = directionLabel(label: "Camera Direction: ", description: getDirection(direction: cameraItem.direction))
          
          cameraRefreshLabel.attributedText = refreshRateLabel(label: "Refresh Rate: ", description: "Approximately every 5 minutes.")

      }
    }
    
}
