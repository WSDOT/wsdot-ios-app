//
//  CalloutViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class CalloutViewController: UIViewController {

    @IBOutlet weak var calloutImageView: UIImageView!
    var calloutURL = ""
    
    override func viewDidAppear(animated: Bool) {
        calloutImageView.sd_setImageWithURL(NSURL(string: calloutURL), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Traffic Map/JBLM Flow Map")
    }
}