//
//  CameraItem.swift
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
import RealmSwift

class CameraItem: Object {

    dynamic var cameraId = 0
    dynamic var url = ""
    dynamic var title = ""
    dynamic var roadName = ""
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var video = false
    dynamic var selected = false
    
    dynamic var delete = false
    
    override static func primaryKey() -> String? {
        return "cameraId"
    }
}
