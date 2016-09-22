//
//  YouTubeViewController.swift
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

import UIKit
import Foundation

class YouTubeViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    let cellIdentifier = "YouTubeCell"
    
    var videoItems = [YouTubeItem]()
    let refreshControl = UIRefreshControl()
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WSDOT on YouTube"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(YouTubeViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        showOverlay(self.view)
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Social Media/YouTube")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            YouTubeStore.getVideos({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.videoItems = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                            
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(view: UIView) {
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        
        if self.splitViewController!.collapsed {
            activityIndicator.center = CGPointMake(view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPointMake(view.center.x - self.splitViewController!.viewControllers[0].view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! YouTubeCell
        
        let video = videoItems[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.publishedLabel.text = TimeUtils.fullTimeStamp(video.published)
        cell.videoThumbnailView.sd_setImageWithURL(NSURL(string: video.thumbnailLink), placeholderImage: UIImage(named: "imagePlaceholderSmall"), options: .RefreshCached)
        cell.videoThumbnailView.layer.cornerRadius = 8.0
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIApplication.sharedApplication().openURL(NSURL(string: videoItems[indexPath.row].link)!)
        
    }
}
