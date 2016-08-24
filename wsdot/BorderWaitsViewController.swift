//
//  BorderWaitViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class BorderWaitsViewController: UIViewController{
    
    @IBOutlet weak var southboundViewContrainer: UIView!
    @IBOutlet weak var northboundViewContainer: UIView!
    
    override func viewDidLoad() {
        title = "Border Waits"
        
        southboundViewContrainer.hidden = true
        northboundViewContainer.hidden = false
    }
    
    // Remove and add hairline for nav bar
    override func viewWillAppear(animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
        case 0:
            southboundViewContrainer.hidden = true
            northboundViewContainer.hidden = false
            break
        case 1:
            southboundViewContrainer.hidden = false
            northboundViewContainer.hidden = true
            break
        default:
            break
        }
    }
}
