//
//  SailingSpacesItem.swift
//  WSDOT
//
//  Created by Logan Sims on 7/26/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation

class SailingSpacesItem {

    var maxSpace = 0
    var remainingSpaces = 0
    var percentAvaliable: Float {
        get {
            return 1.0 - Float(remainingSpaces) / Float(maxSpace)
        }
    }
    var date = NSDate()

}
