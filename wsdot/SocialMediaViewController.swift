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
    let menu_icon_names = ["icBlogger", "icFacebook", "icFlickr", "icRss", "icTwitter", "icYouTube"]
    
    let segueBlogger = "BloggerViewController"
    let segueFacebook = "FacebookViewController"
    let segueFlickr = "FlickrViewController"
    let segueNews = "NewsViewController"
    let segueTwitter = "TwitterViewController"
    let segueYouTube = "YouTubeViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Social Media")
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! IconCell
        
        cell.label?.text = menu_options[indexPath.row]
        cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegue(withIdentifier: segueBlogger, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 1:
            performSegue(withIdentifier: segueFacebook, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 2:
            performSegue(withIdentifier: segueFlickr, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 3:
            performSegue(withIdentifier: segueNews, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 4:
            performSegue(withIdentifier: segueTwitter, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 5:
            performSegue(withIdentifier: segueYouTube, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            
        default:
            break
        }
    }
    
    
    
}
