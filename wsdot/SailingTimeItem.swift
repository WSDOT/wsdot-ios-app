//
//  SailingTimeItem.swift
//  WSDOT
//
//  Created by Logan Sims on 7/19/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation
import SwiftyJSON

class SailingTimeItem: NSObject {
    
    var uuid: String = NSUUID().UUIDString
    var departingTime: String = ""
    var arrivingTime: String? = nil
    var annotationIndexes = [Int]()
    
    init(departingTime: String, arrivingTime: String?, annotationIndexesJSON: JSON) {
        super.init()
        self.departingTime = departingTime
        self.arrivingTime = arrivingTime
        self.annotationIndexes = getAnnotationsIndexesFromJson(annotationIndexesJSON)
        
    }
    
    private func getAnnotationsIndexesFromJson(indexesJSON: JSON) -> [Int]{
        var indexes = [Int]()
        
        for (_,indexeJSON):(String, JSON) in indexesJSON {
            indexes.append(indexeJSON.intValue)
        }
        
        return indexes
        
    }
}
