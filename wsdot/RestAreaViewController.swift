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

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var milepostLabel: UILabel!
    @IBOutlet weak var amenities: UILabel!


    override func viewDidLoad() {

        self.title = restAreaItem!.route + " - " + restAreaItem!.location
    
        directionLabel.text = restAreaItem!.direction
        milepostLabel.text = String(restAreaItem!.milepost)
        
        amenities.text? = ""
        
        for amenity in restAreaItem!.amenities {
        
            amenities.text?.appendContentsOf("• " + amenity + "\n")
        
        }
        
    
    }

}