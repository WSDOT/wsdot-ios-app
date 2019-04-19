//
//  TollRateItem.swift
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

// Toll data structure for mostly static tolls (SR 16, 99. 520)

import RealmSwift

class TollRateTableItem: Object {

    @objc dynamic var route: Int = 0
    @objc dynamic var message: String = ""
    @objc dynamic var numCol: Int = 0
    
    var tollTable = List<TollRateRowItem>()

    @objc dynamic var delete: Bool = false

    override static func primaryKey() -> String? {
        return "route"
    }
}
