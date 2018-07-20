//
//  TollRatesTabBarViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/19/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import UIKit

class TollRatesTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let barViewControllers = self.viewControllers
        let sr167VC = barViewControllers![2] as! DynamicTollRatesViewController
        let i405VC = barViewControllers![3] as! DynamicTollRatesViewController

        sr167VC.stateRoute = "167"
        i405VC.stateRoute = "405"

    }
}
