//
//  CameraPageContainerViewController.swift
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
import EasyTipView

// Container for the CameraPageVV so we can display an ad banner below it
class CameraPageContainerViewController: UIViewController, BannerViewDelegate {

    @IBOutlet weak var bannerView: AdManagerBannerView!
    var adTarget: String = "traffic"
    
    @IBOutlet weak var rightTipViewAnchor: UIView!
    @IBOutlet weak var leftTipViewAnchor: UIView!
    
    var tipView = EasyTipView(text: "")
    
    var cameras: [CameraItem] = []
    var selectedCameraIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.adSize = getFullWidthAdaptiveAdSize()
        bannerView.rootViewController = self
        let request = AdManagerRequest()
        request.customTargeting = ["wsdotapp":adTarget]
        
        bannerView.load(request)
        bannerView.delegate = self
    }
    
    // Pass data along to the embedded vc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CameraPageViewController, segue.identifier == "EmbedSegue" {
            vc.cameras = self.cameras
            vc.selectedCameraIndex = self.selectedCameraIndex
            vc.containingVC = self
        }
    }
    
    func dismissTipView(){
        tipView.dismiss()
    }
}

extension CameraPageContainerViewController: EasyTipViewDelegate {
    
    public func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("\(tipView) did tap!")
    }
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
         UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenCameraSwipeTipView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tipView.dismiss()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ((cameras.count > 1) && (!UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenCameraSwipeTipView) && !UIAccessibility.isVoiceOverRunning)){
            
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = EasyTipView.globalPreferences.drawing.font
            preferences.drawing.foregroundColor = EasyTipView.globalPreferences.drawing.foregroundColor
            preferences.drawing.backgroundColor =  EasyTipView.globalPreferences.drawing.backgroundColor
        
            if (selectedCameraIndex != cameras.count - 1) {
                preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.right
                tipView = EasyTipView(text: "Swipe to view your other cameras.", preferences: preferences, delegate: self)
                tipView.show(forView: self.rightTipViewAnchor)
            } else {
                    preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.left
                tipView = EasyTipView(text: "Swipe to view your other cameras.", preferences: preferences, delegate: self)
                tipView.show(forView: self.leftTipViewAnchor)
            }
        
        }
    }
}
