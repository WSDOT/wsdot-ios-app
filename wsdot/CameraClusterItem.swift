//
//  POIItem.swift
//  WSDOT
//
//  Created by Logan Sims on 9/29/16.
//  Copyright © 2016 WSDOT. All rights reserved.
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
