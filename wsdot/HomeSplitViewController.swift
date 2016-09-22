//
//  HomeSplitViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 9/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class HomeSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .AllVisible
    }


}
