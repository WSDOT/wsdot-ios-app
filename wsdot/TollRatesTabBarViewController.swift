//
//  TollRatesTabBarViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

class TollRatesTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let barViewControllers = self.viewControllers
        
        let sr16VC = barViewControllers![0] as! TollTableViewController
        let sr520VC = barViewControllers![1] as! TollTableViewController
        let sr99VC = barViewControllers![2] as! TollTableViewController
        
        let sr167VC = barViewControllers![3] as! DynamicTollRatesViewController
        let i405VC = barViewControllers![4] as! DynamicTollRatesViewController

        sr16VC.stateRoute = 16
        sr520VC.stateRoute = 520
        sr99VC.stateRoute = 99

        sr167VC.stateRoute = "167"
        i405VC.stateRoute = "405"
        

    }

}
