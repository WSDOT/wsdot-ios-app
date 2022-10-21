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
import Alamofire

class EventViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        let eventItem = EventStore.getActiveEvent()
        var EventTitle: String
        var EventDetails: String

        detailsTextView.sizeToFit()
        detailsTextView.isEditable = false
        detailsTextView.delegate = self
        detailsTextView.textContainerInset = UIEdgeInsets(top: 25, left: 15, bottom: 25, right: 15)
        
        // Display Event Message
        if ((eventItem != nil) && (isConnectedToInternet())) {
            self.title = eventItem!.title
            EventTitle = "<h1>" + eventItem!.bannerText + "</h1>"
            EventDetails = eventItem!.details
            displayEvent(EventTitle: EventTitle, EventDetails: EventDetails)
            
        }
        
        // No Internet Connection Message
        else if (!isConnectedToInternet()) {
            self.title = eventItem!.title
            EventTitle = ""
            EventDetails = "Oops, looks like we’re having trouble getting this alert. You might consider checking your internet connection or try again shortly."
            displayEvent(EventTitle: EventTitle, EventDetails: EventDetails)
            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.homepage, message: WSDOTErrorStrings.eventStatusAlert)
            
        }
        
        // Expired Alert Message
        else {
            EventTitle = ""
            EventDetails = "Alert Expired"
            displayEvent(EventTitle: EventTitle, EventDetails: EventDetails)
        }
        
        // Check for valid JSON response
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            EventStore.fetchAndSaveEventItem(validJSONCheck: true, completion: { error in
                if ((error?.asAFError?.isResponseSerializationError == true) || (error?.asAFError?.responseCode == 404)) {
                    self.detailsTextView.isHidden = true
                    AlertMessages.getConnectionAlert(backupURL: WsdotURLS.homepage, message: WSDOTErrorStrings.eventStatusAlert)
                }
            })
        }
    }
    
    func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "Event")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0

    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    detailsTextView.textColor = UIColor.white
                }
                else {
                    detailsTextView.textColor = UIColor.black
                }
            }
        }
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
    
    func displayEvent(EventTitle: String, EventDetails: String) {
        let htmlStyleLight =
        "<style>*{font-family:'-apple-system';font-size:17px;color:black}h1{font-weight:bold}a{color: #007a5d}a strong{color: #007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}</style>"
        
        let htmlStyleDark =
        "<style>*{font-family:'-apple-system';font-size:17px;color:white}h1{font-weight:bold}a{color: #007a5d}a strong{color: #007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}</style>"
        
        let htmlStringLight = htmlStyleLight + EventTitle + EventDetails
        let htmlStringDark = htmlStyleDark + EventTitle + EventDetails
        
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
            detailsTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().linkColor, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
            detailsTextView.delegate = self
        }
        
        if self.traitCollection.userInterfaceStyle == .dark {
            detailsTextView.attributedText = attrStrDark
            detailsTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().linkColor, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
            detailsTextView.delegate = self
        }
    }
    
}
