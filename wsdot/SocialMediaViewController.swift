//
//  SocialMediaViewController.swift
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

import UIKit

class SocialMediaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "SocialCell"
    
    let menu_options = ["Blogger", "Facebook", "Flickr", "News", "Twitter", "YouTube"]
    let menu_icon_names = ["icBlogger", "icFacebook", "icFlickr", "icNews", "icTwitter", "icYouTube"]
    
    let segueBlogger = "BloggerViewController"
    let segueFacebook = "FacebookViewController"
    let segueFlickr = "FlickrViewController"
    let segueNews = "NewsViewController"
    let segueTwitter = "TwitterViewController"
    let segueYouTube = "YouTubeViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Social Media"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Social Media")
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
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegueWithIdentifier(segueBlogger, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 1:
            performSegueWithIdentifier(segueFacebook, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 2:
            performSegueWithIdentifier(segueFlickr, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 3:
            performSegueWithIdentifier(segueNews, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 4:
            performSegueWithIdentifier(segueTwitter, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 5:
            performSegueWithIdentifier(segueYouTube, sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        default:
            break
        }
    }
    
    
    
}