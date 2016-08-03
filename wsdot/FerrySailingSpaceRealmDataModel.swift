//
//  FerrySailingSpaceRealmDataModel.swift
//  WSDOT
//
//  Created by Logan Sims on 8/3/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import RealmSwift

class FerrySailingSpaceItem: Object{
    dynamic var maxSpace = 0
    dynamic var remainingSpaces = 0
    dynamic var date = NSDate(timeIntervalSince1970: 0)
}

