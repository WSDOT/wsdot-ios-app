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

class RestAreaViewController: UIViewController {

    var restAreaItem: RestAreaItem?
    

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var milepostLabel: UILabel!
    @IBOutlet weak var amenities: UILabel!

    @IBOutlet weak var mapImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rest Area"
    
        locationLabel.text = restAreaItem!.route + " - " + restAreaItem!.location
        directionLabel.text = restAreaItem!.direction
        milepostLabel.text = String(restAreaItem!.milepost)
        
        amenities.text? = ""
        
        for amenity in restAreaItem!.amenities {
            amenities.text?.append("• " + amenity + "\n")
        }
        
        let staticMapUrl = "http://maps.googleapis.com/maps/api/staticmap?center="
            + String(restAreaItem!.latitude) + "," + String(restAreaItem!.longitude)
            + "&zoom=15&size=320x320&maptype=roadmap&markers="
            + String(restAreaItem!.latitude) + "," + String(restAreaItem!.longitude)
            + "&key=" + ApiKeys.google_key
        
        mapImage.sd_setImage(with: URL(string: staticMapUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached)
        
        scrollView.contentMode = .scaleAspectFit
        mapImage.sizeToFit()
        scrollView.contentSize = CGSize(width: mapImage.frame.size.width, height: mapImage.frame.size.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Rest Area Details")
    }

}
