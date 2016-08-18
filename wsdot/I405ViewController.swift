//
//  I405ViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class I405ViewController: UIViewController, UITextViewDelegate{

    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {

        let htmlStyleString = "<style>body{font-family: Helvetica; font-size:17px;}</style>"
        let htmlString = htmlStyleString + "<p><strong>I-405 Express Toll Lanes between Bellevue and Lynnwood</strong><br />" +
		"I-405 express toll lanes will let drivers choose to travel faster by paying a toll. " +
		"Toll rates will adjust between 75 cents and $10 based on traffic volumes in the express " +
		"toll lane. Drivers will pay the rate they see upon entering the lanes, even if they see " +
		"a higher price down the road. Transit, vanpools, carpools and motorcycles can use the " +
		"lanes for free with a <em>Good To Go!</em> account and pass.</p>" +
        "<p><strong>Access to express toll lanes</strong><br />" +
		"Drivers who choose to use the lanes, will merge to the far left regular lane and can " +
		"enter express toll lanes at designated access points that are marked with dashed lines. " +
		"Just remember that failure to use designated access points will result in a $136 ticket " +
		"for crossing the double white lines.</p>" +
		"<p>There are two direct access ramps to I-405 express toll lanes that allow you to " +
		"directly enter the express toll lanes from the middle of the freeway. These ramps are at " +
		"Northeast 6th Street in Bellevue and Northeast 128th Street in Kirkland.</p>" +
		"<p><strong>Using the lanes</strong><br />" +
		"Any existing <em>Good To Go!</em> pass can be used to pay a toll.</p>" +
		"<p>If you carpool on the I-405 express toll lanes, you must meet the occupancy requirements " +
		"and have a <em>Good To Go!</em> account and Flex Pass set to HOV mode to travel toll-free. Carpool " +
		"requirements are three occupants during weekday peaks hours (5-9 a.m. and 3-7 p.m.) and two " +
		"occupants during off-peak hours (mid-day, evenings and weekends).</p>" +
		"<p>If a driver does not have a <em>Good To Go!</em> account, a Pay By Mail toll bill will be mailed " +
		"to the vehicle’s registered owner for an additional $2 per toll transaction.</p>" +
	    "<p>Visit GoodToGo405.org for more information.</p>"
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        attrStr.addAttribute(NSLinkAttributeName, value: "http://www.GoodToGo405.org", range: NSRange(location: 1603, length: 15))
        
        textView.delegate = self
        textView.attributedText = attrStr
        
    }
    
    override func viewWillLayoutSubviews() {
        textView.setContentOffset(CGPointZero, animated: false)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        UIApplication.sharedApplication().openURL(URL)
		return false
	}
    

}