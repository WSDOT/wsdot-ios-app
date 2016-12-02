//
//  HighwayAlertViewController.swift
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
import Foundation

class HighwayAlertViewController: UIViewController, INDLinkLabelDelegate {
    
    var alertItem = HighwayAlertItem()
    
    @IBOutlet weak var descLinkLabel: INDLinkLabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = alertItem.eventCategory
        
        let htmlStyleString = "<style>body{font-family: '\(descLinkLabel.font.fontName)'; font-size:\(descLinkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + alertItem.headlineDesc
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        descLinkLabel.attributedText = attrStr

        updateTimeLabel.text = TimeUtils.timeAgoSinceDate(alertItem.lastUpdatedTime, numericDates: false)
        
        let staticMapUrl = "http://maps.googleapis.com/maps/api/staticmap?center="
            + String(alertItem.startLatitude) + "," + String(alertItem.startLongitude)
            + "&zoom=15&size=320x320&maptype=roadmap&markers="
            + String(alertItem.startLatitude) + "," + String(alertItem.startLongitude)
            + "&key=" + ApiKeys.google_key
        
        
        mapImage.sd_setImage(with: URL(string: staticMapUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Highway Alert")
    }
    
    // MARK: INDLinkLabelDelegate
    
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {
        UIApplication.shared.openURL(URL)
    }
    
}
