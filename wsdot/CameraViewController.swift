//
//  CameraViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/2/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraImage: UIImageView!
    
    var cameraItem: CameraItem = CameraItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = cameraItem.title;
        
        cameraImage.sd_setImageWithURL(NSURL(string: cameraItem.url), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
        
        let favoriteButton = UIButton()
        
        if (cameraItem.selected){
            favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Normal)
            favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Highlighted)
            favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Selected)
            favoriteButton.addTarget(self, action: #selector(CameraViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        }else{
            favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Normal)
            favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Highlighted)
            favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Selected)
            favoriteButton.addTarget(self, action: #selector(CameraViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        }
        
        favoriteButton.sizeToFit()
        let favoritesNavItemButton = UIBarButtonItem()
        favoritesNavItemButton.customView = favoriteButton
        
        self.navigationItem.rightBarButtonItem = favoritesNavItemButton
    }
    
    // Sets selected attribute of the route item to true and calls DB update logic
    func addFavorite(sender: UIButton){
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Normal)
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Highlighted)
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Selected)
        sender.removeTarget(self, action: #selector(CameraViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: #selector(CameraViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        CamerasStore.updateFavorite(cameraItem, newValue: true)
        
        
    }
    
    // Sets selected attribute of the route item to false and calls DB update logic
    func removeFavorite(sender: UIButton){
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Normal)
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Highlighted)
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Selected)
        sender.removeTarget(self, action: #selector(CameraViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: #selector(CameraViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        CamerasStore.updateFavorite(cameraItem, newValue: false)
    }
}
