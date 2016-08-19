//
//  SR167ViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class SR167ViewController: UIViewController{

    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {

        let htmlStyleString = "<style>body{font-family: Helvetica; font-size:17px;}</style>"
        let htmlString = htmlStyleString + "<p>Tolls are collected in both directions</p>" +
				"<ul>" +
				"<li>$.50 minimum during periods of little congestion.</li>" +
				"<li>$9.00 maximum during periods of heavy congestion.</li>" +
				"<li>During other levels of congestion, the toll amount varies between $.50 and $9.00.</li>" +
				"<li>Only single occupancy vehicles are tolled. Those vehicles with two or more passengers, and motorcycles, are not charged a toll.</li>" +
				"<li>Customers are only charged once - at the toll that is displayed when the vehicle enters the lane.</li>" +
				"</ul><br>" +
				"<p>The SR 167 HOT lanes project opened May 2008. Toll rates for HOT lanes are dynamically priced, meaning the toll can change throughout the day to ensure reliable travel times. The goal is to keep an average speed of at least 45 mph in the HOT lanes.</p>" +
				"<p>The toll rate can change based on congestion factors, time of day, traffic volumes, and traffic flow. Customers can anticipate that tolls will be in effect on the SR 167 HOT lanes between 5 a.m. and 7 p.m.</p>" +
				"<p><em>Good To Go!</em> customers who use the HOT lane should look for the electronic sign above the lane that displays the actual toll rate and make a choice to enter the lane.</p>"


        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        textView.attributedText = attrStr
        
    }
    
    override func viewWillLayoutSubviews() {
        textView.setContentOffset(CGPointZero, animated: false)
    }


}