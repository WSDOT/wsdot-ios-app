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
    case Bulk_Insert_Error
    case Delete_Error
    case Search_Error
    case Update_Error
    case Nil_In_Data
    case Unknown_Error
}

class Tables {
    static let FERRIES_TABLE = "ferries_schedules"
    static let CAMERAS_TABLE = "cameras"
    static let CACHES_TABLE = "caches"
}


class AlertMessages {
    static func getConnectionAlert() ->  UIAlertController{
        let alert = UIAlertController(title: "Connection Error", message: "Please check your connection", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    
    static func getMailAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Cannot Compose Message", message: "Please add a mail account", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    
}
