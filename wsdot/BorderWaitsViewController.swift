//
//  BorderWaitViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class BorderWaitsViewController: UIViewController{
    
    override func viewDidLoad() {
        title = "Border Waits"
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
    
    
    
}
