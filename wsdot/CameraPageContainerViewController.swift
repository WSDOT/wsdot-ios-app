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

// Container for the CameraPageVV so we can display an ad banner below it
class CameraPageContainerViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var bannerView: DFPBannerView!
    var adTarget: String = "other"
    
    @IBOutlet weak var pageLabel: UILabel!
    var cameras: [CameraItem] = []
    var selectedCameraIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":adTarget]
        
        if cameras.count > 1 {
            pageLabel.text = "\(selectedCameraIndex + 1) of \(cameras.count)"
        } else {
            pageLabel.text = ""
        }
        
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
    
    func setPageLabel(currentPage: Int){
        pageLabel.text = "\(currentPage + 1) of \(cameras.count)"
    }
}
