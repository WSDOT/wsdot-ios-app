//
//  TerminalItem.swift
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
import UIKit

class TerminalItem {

    var terminalID: Int = 0
    var terminalName: String = ""
    var addressLineOne: String = ""
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    var bulletins: Array<Any> = []
    
    init(terminalID: Int, terminalName: String, addressLineOne: String, city: String, state: String, zipCode: String, bulletins: Array<Any>) {
        self.terminalID = terminalID
        self.terminalName = terminalName
        self.addressLineOne = addressLineOne
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.bulletins = bulletins
    }
    
}
