//
//  CameraClusterItem.swift
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

/// Point of Interest Item which implements the GMUClusterItem protocol.
class CameraClusterItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: String!
  var camera: CameraItem

  init(position: CLLocationCoordinate2D, name: String, camera: CameraItem) {
    self.position = position
    self.name = name
    self.camera = camera
  }
}
