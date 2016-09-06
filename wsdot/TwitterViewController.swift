//
//  TwitterViewController.swift
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

class TwitterViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "TwitterCell"
    
    var tweets = [TwitterItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerTextView: PickerTextField!
    
    let refreshControl = UIRefreshControl()
    
    let pickerData: [(name:String, screenName:String?)] =
        [("All Accounts", nil), ("Ferries", "wsferries"), ("Good To Go!", "GoodToGoWSDOT"),
        ("Snoqualmie Pass", "SnoqualmiePass"), ("WSDOT", "wsdot"), ("WSDOT Jobs", "WSDOTjobs"), ("WSDOT Southwest", "wsdot_sw"),
        ("WSDOT Tacoma","wsdot_tacoma"), ("WSDOT Traffic","wsdot_traffic")]
    
    let accountIconNames: Dictionary<String, String> = [
        "wsferries":"icTwitterFerries",
        "GoodToGoWSDOT":"icTwitterGoodToGo",
        "SnoqualmiePass":"icTwitterSnoqualmie",
        "wsdot":"icTwitterWsdot",
        "WSDOTjobs":"icTwitterJobs",
        "wsdot_sw":"icTwitterWsdotSW",
        "wsdot_tacoma":"icTwitterTacoma",
        "wsdot_traffic":"icTwitterTraffic"
    ]
    
    var currentAccountIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "WSDOT on Twitter"
        
        // Set up account picker
        let picker: UIPickerView
        picker = UIPickerView()
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self

        tableView.rowHeight = UITableViewAutomaticDimension
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TwitterViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        pickerTextView.text = pickerData[0].name
        pickerTextView.inputView = picker
        pickerTextView.inputAccessoryView = toolBar
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TwitterViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - self.refreshControl.frame.size.height)
        refresh(pickerData[self.currentAccountIndex].screenName)
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Social Media/Twitter")
    }
    
    override func didReceiveMemoryWarning() {
        print("Memory warning")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh(pickerData[self.currentAccountIndex].screenName)
    }
    
    func refresh(account: String?) {
        
        tweets.removeAll()
        tableView.reloadData()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            TwitterStore.getTweets(account, completion: { data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.tweets = validData
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
        return tweets.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! TwitterCell
        
        let tweet = tweets[indexPath.row]
        
        let htmlStyleString = "<style>body{font-family: '\(cell.contentLabel.font.fontName)'; font-size:\(cell.contentLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + tweet.text
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.contentLabel.attributedText = attrStr
        cell.contentLabel.delegate = self
        
        cell.publishedLabel.text = TimeUtils.fullTimeStamp(tweet.published)
        
        if let iconName = accountIconNames[tweet.screenName] {
            cell.iconView.image = UIImage(named: iconName)
        }
        
        if let mediaUrl = tweet.mediaUrl {
            cell.mediaImageView.sd_setImageWithURL(NSURL(string: mediaUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
            cell.mediaImageView.layer.cornerRadius = 8.0
        }else{
            cell.mediaImageView.sd_setImageWithURL(nil)
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIApplication.sharedApplication().openURL(NSURL(string: tweets[indexPath.row].link)!)
    }

    // MARK: -
    // MARK: Picker View Delegate & data source methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].name
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let selfValue = self {
                selfValue.currentAccountIndex = row
                selfValue.pickerTextView.text = selfValue.pickerData[selfValue.currentAccountIndex].name
            }
        }
    }
    
    func donePicker() {
        pickerTextView.text = pickerData[currentAccountIndex].name
        pickerTextView.resignFirstResponder()
        refreshControl.beginRefreshing()
        tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - self.refreshControl.frame.size.height)
        refresh(pickerData[self.currentAccountIndex].screenName)
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(label: INDLinkLabel, didLongPressLinkWithURL URL: NSURL) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
            if let selfValue = self{
                selfValue.presentViewController(activityController, animated: true, completion: nil)
            }
        }
    }
    
    func linkLabel(label: INDLinkLabel, didTapLinkWithURL URL: NSURL) {
        dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().openURL(URL)
        }
    }
}