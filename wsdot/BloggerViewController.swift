//
//  BloggerViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/30/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import Foundation

class BloggerViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    let cellIdentifier = "blogCell"
    
    var posts = [BlogItem]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        title = "WSDOT Blog"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BloggerViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Social Media/Blogger")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            BloggerStore.getBlogPosts({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.posts = validData
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
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! BloggerCell
        
        cell.title.text = posts[indexPath.row].title
        cell.content.text = posts[indexPath.row].content
        cell.updated.text = TimeUtils.fullTimeStamp(posts[indexPath.row].published)
        cell.imageView!.sd_setImageWithURL(NSURL(string: posts[indexPath.row].imageUrl), placeholderImage: UIImage(named: "imagePlaceholderSmall"), options: .RefreshCached)
        cell.imageView?.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIApplication.sharedApplication().openURL(NSURL(string: posts[indexPath.row].link)!)
        
    }
}