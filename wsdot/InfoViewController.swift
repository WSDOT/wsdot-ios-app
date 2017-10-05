//
//  InfoViewController.swift
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
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {
   
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var aboutText: UITextView!
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var bugReportButton: UIButton!
    @IBOutlet weak var jobsButton: UIButton!
    

    var version = "?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let bundle = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        version = bundle as! String
    
        aboutText.sizeToFit()
        
        aboutText.text = "The Washington State Department of Transportation provides and supports safe, reliable and cost-effective transportation options to improve livable communities and economic vitality for people and businesses.\n\n"
            + "The WSDOT mobile app was created to make it easier for you to know the latest about Washington's transportation system. \n\n"
            + "To report HOV, HOT lane or ferry line violators please call 1-877-764-4376 or use our online reporting form at http://www.wsdot.wa.gov/HOV/reporting.\n\n"
            + "Questions, comments or suggestions about this app can be e-mailed to the WSDOT Communications Office at webfeedback@wsdot.wa.gov."
    
        aboutText.isEditable = false
    
        appVersionLabel.text = "App version: " + version
        
        styleButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/About")
    }
    
    
    @IBAction func openJobsSite(_ sender: UIButton) {
        GoogleAnalytics.screenView(screenName: "/About/Jobs")
        UIApplication.shared.openURL(URL(string: "https://www.governmentjobs.com/careers/washington?department%5B0%5D=Dept.%20of%20Transportation")!)
    }
    
    @IBAction func composeFeedbackMessage(_ sender: UIButton) {
    
        let bundle = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        let version = bundle as! String
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["webfeedback@wsdot.wa.gov"])
            mail.setSubject("WSDOT iOS v\(version) Feedback")
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto:")!)
        }
    }
    
    @IBAction func composeBugReport(_ sender: UIButton) {
    
        let bundle = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        let version = bundle as! String
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["webfeedback@wsdot.wa.gov"])
            mail.setSubject("WSDOT iOS v\(version) Issue Report")
            mail.setMessageBody("<b>Issue Description:<b><br><br> <b>Steps to Reproduce Issue (if applicable):</b><br><br>", isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto:")!)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
        /**
     * Method name: styleButtons()
     * Description: programmatically styles button background, colors, etc...
     */
    func styleButtons() {
        feedbackButton.layer.cornerRadius = 5
        feedbackButton.clipsToBounds = true
        
        bugReportButton.layer.cornerRadius = 5
        bugReportButton.clipsToBounds = true
        
        jobsButton.layer.cornerRadius = 5
        jobsButton.clipsToBounds = true
        
    }
}
