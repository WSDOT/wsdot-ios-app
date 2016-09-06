//
//  RestAreaViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class RestAreaViewController: UIViewController {

    var restAreaItem: RestAreaItem?
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var milepostLabel: UILabel!
    @IBOutlet weak var amenities: UILabel!

    @IBOutlet weak var mapImage: UIImageView!

    override func viewDidLoad() {

        self.title = restAreaItem!.route + " - " + restAreaItem!.location
    
        directionLabel.text = restAreaItem!.direction
        milepostLabel.text = String(restAreaItem!.milepost)
        
        amenities.text? = ""
        
        for amenity in restAreaItem!.amenities {
            amenities.text?.appendContentsOf("• " + amenity + "\n")
        }
        
        let staticMapUrl = "http://maps.googleapis.com/maps/api/staticmap?center="
            + String(restAreaItem!.latitude) + "," + String(restAreaItem!.longitude)
            + "&zoom=15&size=320x320&maptype=roadmap&markers="
            + String(restAreaItem!.latitude) + "," + String(restAreaItem!.longitude)
            + "&key=" + ApiKeys.google_key
        
        mapImage.sd_setImageWithURL(NSURL(string: staticMapUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
        
        scrollView.contentMode = .ScaleAspectFit
        mapImage.sizeToFit()
        scrollView.contentSize = CGSizeMake(mapImage.frame.size.width, mapImage.frame.size.height)
    }

    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Traffic Map/Rest Area Details")
    }

}