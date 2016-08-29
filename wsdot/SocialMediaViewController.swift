//
//  SocialMediaViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/29/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class SocialMediaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "SocialCell"
    
    let menu_options = ["Blogger", "Facebook", "Flickr", "News", "Twitter", "YouTube"]
    let menu_icon_names = ["icBlogger", "icFacebook", "icFlickr", "icNews", "icTwitter", "icYouTube"]
    
    
    override func viewDidLoad() {
        self.title = "Social Media"
        
        
     
     
    }
    
      
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! IconCell
        
        cell.label?.text = menu_options[indexPath.row]
        cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        
        return cell
    }

    
}