//
//  Consts.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import Foundation
import UIKit

enum DataAccessError: ErrorType {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Update_Error
    case Nil_In_Data
}

class Tables {
    static let FERRIES_TABLE = "ferries_schedules"
    static let CACHES_TABLE = "caches"
    
}


class AlertMessages {
    static func getConnectionAlert() ->  UIAlertController{
        let alert = UIAlertController(title: "Connection Error", message: "Please check your connection", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }

}
