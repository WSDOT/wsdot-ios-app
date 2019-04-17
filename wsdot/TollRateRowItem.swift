//
//  TollRateRowItem.swift
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

import RealmSwift

class TollRateRowItem: Object {

    @objc dynamic var index: Int = 0
    @objc dynamic var header: Bool = false
    @objc dynamic var startHourString = ""
    @objc dynamic var endHourString = ""
    @objc dynamic var weekday = true
    var rows = List<String>()
    
}
