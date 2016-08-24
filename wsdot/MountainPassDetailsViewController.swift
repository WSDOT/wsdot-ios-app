//
//  MountainPassDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class MountainPassDetailsViewController: UIViewController{

    var passItem = MountainPassItem()
    
    override func viewDidLoad() {
        title = passItem.name


    }


}