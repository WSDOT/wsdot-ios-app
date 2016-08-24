//
//  HighwayAlertViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import Foundation

class HighwayAlertViewController: UIViewController, INDLinkLabelDelegate {
    
    var alertItem = HighwayAlertItem()
    
    @IBOutlet weak var descLinkLabel: INDLinkLabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        title = alertItem.eventCategory
        
        let htmlStyleString = "<style>body{font-family: '\(descLinkLabel.font.fontName)'; font-size:\(descLinkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + alertItem.headlineDesc
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        descLinkLabel.attributedText = attrStr

        updateTimeLabel.text = TimeUtils.timeAgoSinceDate(alertItem.lastUpdatedTime, numericDates: false)
        
        let staticMapUrl = "http://maps.googleapis.com/maps/api/staticmap?center="
            + String(alertItem.startLatitude) + "," + String(alertItem.startLongitude)
            + "&zoom=15&size=320x320&maptype=roadmap&markers="
            + String(alertItem.startLatitude) + "," + String(alertItem.startLongitude)
            + "&key=" + ApiKeys.google_key
        
        
        mapImage.sd_setImageWithURL(NSURL(string: staticMapUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)

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