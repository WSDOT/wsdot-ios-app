//
//  EventViewController.swift
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
import SafariServices

class EventViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var detailsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let eventItem = EventStore.getActiveEvent()
        if (eventItem != nil){
            self.title = eventItem!.title
            detailsTextView.sizeToFit()
            detailsTextView.isEditable = false
            detailsTextView.delegate = self
        
            let htmlStyleLight =
            "<style>*{font-family:'-apple-system';font-size:17px;color:black}h1{font-weight:bold}a{color: #007a5d}a strong{color: #007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}</style>"
            
            let htmlStyleDark =
            "<style>*{font-family:'-apple-system';font-size:17px;color:white}h1{font-weight:bold}a{color: #007a5d}a strong{color: #007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}</style>"
            
            let htmlStringLight = htmlStyleLight + eventItem!.details
            let htmlStringDark = htmlStyleDark + eventItem!.details
            
            let attrStrLight = try! NSMutableAttributedString(
                data: htmlStringLight.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil)
        
            let attrStrDark = try! NSMutableAttributedString(
                data: htmlStringDark.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil)
                  
            if self.traitCollection.userInterfaceStyle == .light {
                detailsTextView.attributedText = attrStrLight
                detailsTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().mainColor, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
                detailsTextView.delegate = self
            }
            
            if self.traitCollection.userInterfaceStyle == .dark {
                detailsTextView.attributedText = attrStrDark
                detailsTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().mainColor, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
                detailsTextView.delegate = self
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "Event")
    }
 
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    
        guard let scheme = URL.scheme else { return true }
        if scheme != "http" && scheme != "https" { return true }
    
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
        return false
    }
}
