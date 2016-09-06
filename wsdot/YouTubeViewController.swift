//
//  YouTubeViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

import UIKit
import Foundation

class YouTubeViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    let cellIdentifier = "YouTubeCell"
    
    var videoItems = [YouTubeItem]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        title = "WSDOT on YouTube"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(YouTubeViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
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
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                            
                        }
                    }
                }
            })
        }
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
