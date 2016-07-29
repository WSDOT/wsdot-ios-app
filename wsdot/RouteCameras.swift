//
//  RouteCameras.swift
//  WSDOT
//
//  Created by Logan Sims on 7/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import Foundation

/*

        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            CamerasStore.getCameras("Ferries", completion:  { data, error in
                if (error == nil){
                    if let selfValue = self{
                        selfValue.cameras = data
                        selfValue.tableView.reloadData()
                        print("Cameras Loaded")
                    }
                }else{
                    print("RouteDepartureViewContorller: Error getting cameras")
                }
            })
        }




 case 1: // Cameras
            let cell = tableView.dequeueReusableCellWithIdentifier(camerasCellIdentifier) as! CameraImageCustomCell
            
            if let url = NSURL(string: cameras![indexPath.row].url) {
                if let data = NSData(contentsOfURL: url) {
                    cell.CameraImage.image = UIImage(data: data)
                }
            }
            
            return cell
        default:

*/
