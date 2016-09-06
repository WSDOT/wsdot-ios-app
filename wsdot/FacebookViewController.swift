//
//  FacebookViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/30/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import Foundation

class FacebookViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "postCell"
    
    var posts = [FacebookItem]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        title = "WSDOT on Facebook"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FacebookViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Social Media/Facebook")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            FacebookStore.getPosts({ data, error in
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! FacebookCell
        
        let post = posts[indexPath.row]
        
        let htmlStyleString = "<style>body{font-family: '\(cell.contentLabel.font.fontName)'; font-size:\(cell.contentLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + post.message
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.contentLabel.attributedText = attrStr
        cell.updatedLabel.text = TimeUtils.fullTimeStamp(post.createdAt)
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIApplication.sharedApplication().openURL(NSURL(string: "https://facebook.com/" + posts[indexPath.row].id)!)
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(label: INDLinkLabel, didLongPressLinkWithURL URL: NSURL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(label: INDLinkLabel, didTapLinkWithURL URL: NSURL) {
        UIApplication.sharedApplication().openURL(URL)
    }
}
