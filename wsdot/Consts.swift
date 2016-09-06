//
//  Consts.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
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
    static let HIGHWAY_ALERTS_TABLE = "highway_alerts"
    static let FERRIES_TABLE = "ferries_schedules"
    static let CAMERAS_TABLE = "cameras"
    static let CACHES_TABLE = "caches"
}

class Colors {
    static let tintColor = UIColor.init(red: 0.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1)
    static let lightGrey = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
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
    
    static func getAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
}
