//
//  TerminalStore.swift
//  WSDOT
//
//  Copyright (c) 2025 Washington State Department of Transportation
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
import Alamofire
import SwiftyJSON

/*
 * Gets terminal information from JSON API
 */
class TerminalStore: Decodable {
    
    typealias TerminalCompletion = (_ data: [TerminalItem]?, _ error: Error?) -> ()
    
     static func parseTerminalsJSON(_ json: JSON) ->[TerminalItem]{
        
        var terminals = [TerminalItem]()
        
        for (_,terminalJson):(String, JSON) in json {
        
            let terminal = TerminalItem(
                terminalID: terminalJson["TerminalID"].intValue,
                terminalName: terminalJson["TerminalName"].stringValue,
                addressLineOne: terminalJson["AddressLineOne"].stringValue,
                city: terminalJson["City"].stringValue,
                state: terminalJson["State"].stringValue,
                zipCode: terminalJson["ZipCode"].stringValue,
                bulletins: terminalJson["Bulletins"].arrayValue)
            terminals.append(terminal)
        }
        return terminals
    }
    
}
