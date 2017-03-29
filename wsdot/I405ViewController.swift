//
//  I405ViewController.swift
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

class I405ViewController: UIViewController, UITextViewDelegate{

    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let htmlStyleString = "<style>body{font-family: Helvetica; font-size:17px;}</style>"
        let htmlString = htmlStyleString + "<p><strong>I-405 Express Toll Lanes between Bellevue and Lynnwood</strong><br />" +
		"I-405 express toll lanes let drivers choose to travel faster by paying a toll 5 a.m.-7 p.m. Monday-Friday. " +
		"Toll rates will adjust between 75 cents and $10 based on traffic volumes in the express " +
		"toll lane. Drivers will pay the rate they see upon entering the lanes, even if they see " +
		"a higher price down the road. Transit, vanpools, carpools and motorcycles can use the " +
		"lanes for free with a <em>Good To Go!</em> account and pass. The lanes are open to all " +
        "vehicles toll-free Monday-Friday 7 p.m.-5 a.m., on weekends, and on New Years Day, Memorial Day, " +
        "Independence Day, Labor Day, Thanksgiving Day, and Christmas Day.</p>" +
        
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
		"requirements are three occupants during weekday peak hours (5-9 a.m. and 3-7 p.m.) and two " +
		"occupants during off-peak hours (9 a.m.-3 p.m.).</p>" +
		"<p>If a driver does not have a <em>Good To Go!</em> account, a Pay By Mail toll bill will be mailed " +
		"to the vehicle’s registered owner for an additional $2 per toll transaction.</p>" +
	    "<p>Visit GoodToGo405.org for more information.</p>"
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        attrStr.addAttribute(NSLinkAttributeName, value: "http://www.GoodToGo405.org", range: NSRange(location: 1603, length: 15))
        
        textView.delegate = self
        textView.attributedText = attrStr
        
    }
    
    override func viewWillLayoutSubviews() {
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL)
		return false
	}
    

}
