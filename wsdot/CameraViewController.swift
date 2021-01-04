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

class CameraViewController: UIViewController, GADBannerViewDelegate, MapMarkerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var cameraImage: UIImageView!
    fileprivate let cameraMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    @IBOutlet weak var bannerView: DFPBannerView!
    
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var milepostLabel: UILabel!
    
    @IBOutlet weak var cameraImageHeightConstraint: NSLayoutConstraint!
    weak fileprivate var embeddedMapViewController: SimpleMapViewController!
    
    var cameraItem: CameraItem = CameraItem()
    var adTarget: String = "other"
    var adsEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = cameraItem.title;
        
        embeddedMapViewController.view.isHidden = false
        
        if (cameraItem.selected) {
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        } else {
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }
        

        switch (cameraItem.direction) {
            case "N":
                directionLabel.text = "This camera faces north"
                break
            case "S":
                directionLabel.text = "This camera faces south"
                break
            case "E":
                directionLabel.text = "This camera faces east"
                break
            case "W":
                directionLabel.text = "This camera faces west"
                break
            case "B":
                directionLabel.text = "This camera could be pointing in a number of directions for operational reasons."
                break
            default:
                directionLabel.isHidden = true
                break
        }
        
        
        if (cameraItem.milepost == -1) {
            milepostLabel.isHidden = true
        } else {
            milepostLabel.isHidden = false
            milepostLabel.text = "near milepost \(cameraItem.milepost)"
        }
        
        favoriteBarButton.tintColor = Colors.yellow
        
        // Set up map marker
        cameraMarker.position = CLLocationCoordinate2D(latitude: self.cameraItem.latitude, longitude: self.cameraItem.longitude)
        cameraMarker.icon = UIImage(named: "icMapCamera")
        
        self.embeddedMapViewController.view.isHidden = false
        
        // Ad Banner
        if (adsEnabled) {
            bannerView.adUnitID = ApiKeys.getAdId()
            bannerView.rootViewController = self
            bannerView.adSize = getFullWidthAdaptiveAdSize()
            let request = DFPRequest()
            request.customTargeting = ["wsdotapp":adTarget]
        
            bannerView.load(request)
            bannerView.delegate = self
        } else {
            bannerView.isHidden = true
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // This is incase the camera is in a pager view
        // and needs to add the marker again because it
        // isn't properly added when the pager sets up the
        // side page views.
        if let mapView = embeddedMapViewController.view as? GMSMapView{
            cameraMarker.map = mapView
            mapView.settings.setAllGesturesEnabled(false)
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.cameraItem.latitude, longitude: self.cameraItem.longitude), zoom: 14))
            
        }
        
        let placeholder: UIImage? = UIImage(named: "imagePlaceholder")
                    
        // Add timestamp to help prevent caching
        let urlString = cameraItem.url + "?" + String(Int(Date().timeIntervalSince1970 / 60))
        
           
        cameraImage.sd_setImage(with: URL(string: urlString), placeholderImage: placeholder, options: .refreshCached, completed: { image, error, cacheType, imageURL in
                        
                let superViewWidth = self.view.frame.size.width - 16
                 
                if (error != nil) {
                    self.cameraImage.image = UIImage(named: "cameraOffline")
                } else {
      
                    let ratio = image!.size.width / image!.size.height
                    let newHeight = superViewWidth / ratio
                            
                    print(newHeight)
                            
                    self.cameraImageHeightConstraint.constant = newHeight
                      
                }
            }
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "CameraImage")
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
            mapView.settings.setAllGesturesEnabled(false)
            mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: self.cameraItem.latitude, longitude: self.cameraItem.longitude), zoom: 14))
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
}
