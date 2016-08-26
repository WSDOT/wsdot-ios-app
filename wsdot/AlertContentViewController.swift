//
//  HighwayAlertsPagerViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/26/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class AlertContentViewController: UIViewController{

    var itemIndex: Int = 0
    var alertText = ""
    var loadingPage = false

    @IBOutlet var alertLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = Colors.lightGrey
        self.view.frame = parentViewController!.view.frame
        
        if loadingPage {
            progressIndicator.startAnimating()
            alertLabel.hidden = true
        }else {
            alertLabel.text = alertText
            progressIndicator.hidden = true
        }
    }
    
}
