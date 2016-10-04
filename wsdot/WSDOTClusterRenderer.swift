//
//  WSDOTClusterRenderer.swift
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

// Custom Renderer to override shouldCluster.
// Adds prefrence logic so that users can turn clustering on/off.
// Adds some custom cluster logic for cameras in the same place.
class WSDOTClusterRenderer: GMUDefaultClusterRenderer {

    override func shouldRenderAsCluster(cluster: GMUCluster, atZoom zoom: Float) -> Bool {

        // Set defualt value for camera display if there is none
        if (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.shouldCluster) == nil){
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: UserDefaultsKeys.shouldCluster)
        }
    
        let shouldCluster = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.shouldCluster)
        if shouldCluster == "off" {
            return false
        }
        
        // If all cameras are in the same spot always cluster.
        // Hard cap at 10 so we don't loop over lots of cameras. 
        // This assumes we don't have more than 10 cameras in the same place.
        if cluster.count < 10 && cluster.count > 1{
            if let firstCamera = cluster.items[0] as? CameraClusterItem {
                if !cluster.items.contains({(($0 as! CameraClusterItem).camera.latitude != firstCamera.camera.latitude) || (($0 as! CameraClusterItem).camera.longitude != firstCamera.camera.longitude)}) {
                    return true
                }
            }
        }
        return super.shouldRenderAsCluster(cluster, atZoom: zoom)
    }
}
