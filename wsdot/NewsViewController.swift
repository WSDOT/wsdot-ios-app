//
//  NewsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/31/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

import UIKit
import Foundation

class NewsViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    let cellIdentifier = "NewsCell"
    
    var newsItems = [NewsItem]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        title = "WSDOT News"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(NewsViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Social Media/News")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            NewsStore.getNews({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.newsItems = validData
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
        return newsItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! NewsCell
        
        cell.titleLabel.text = newsItems[indexPath.row].title
        cell.publishedLabel.text = TimeUtils.fullTimeStamp(newsItems[indexPath.row].published)

        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIApplication.sharedApplication().openURL(NSURL(string: newsItems[indexPath.row].link)!)
        
    }
}