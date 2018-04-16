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
import SafariServices

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate {
   
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var aboutText: UITextView!
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var ferriesFeedbackButton: UIButton!
    @IBOutlet weak var bugReportButton: UIButton!
    @IBOutlet weak var jobsButton: UIButton!
    
    let jobsUrlString = "https://www.governmentjobs.com/careers/washington?department%5B0%5D=Dept.%20of%20Transportation"

    var version = "?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let bundle = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        version = bundle as! String
    
        aboutText.sizeToFit()
        aboutText.tintColor = ThemeManager.currentTheme().mainColor
        aboutText.delegate = self
        
        aboutText.text = "The Washington State Department of Transportation provides and supports safe, reliable and cost-effective transportation options to improve livable communities and economic vitality for people and businesses.\n\n"
            + "The WSDOT mobile app was created to make it easier for you to know the latest about Washington's transportation system. \n\n"
            + "Questions, comments or suggestions about this app can be e-mailed to the WSDOT Communications Office at webfeedback@wsdot.wa.gov. \n\n"
            + "To report HOV, HOT lane or ferry line violators please call 1-877-764-4376 or use our online reporting form at http://www.wsdot.wa.gov/HOV/reporting."
    
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
        let svc = SFSafariViewController(url: URL(string: self.jobsUrlString)!, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = UIColor.white
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = Colors.tintColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func composeFeedbackMessage(_ sender: UIButton) {
    
        let bundle = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        let version = bundle as! String
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.navigationBar.tintColor = Colors.yellow
            mail.mailComposeDelegate = self
            mail.setToRecipients(["webfeedback@wsdot.wa.gov"])
            mail.setSubject("WSDOT iOS v\(version) Feedback")
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto:")!)
        }
    }
    
    @IBAction func composeFerriesFeedbackMessage(_ sender: UIButton) {
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.navigationBar.tintColor = Colors.yellow
            mail.mailComposeDelegate = self
            mail.setToRecipients(["wsfinfo@wsdot.wa.gov"])
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
            mail.navigationBar.tintColor = Colors.yellow
            mail.mailComposeDelegate = self
            mail.setToRecipients(["webfeedback@wsdot.wa.gov"])
            mail.setSubject("WSDOT iOS v\(version) Issue Report")
            mail.setMessageBody("<b>Issue Description:<b><br><br> <b>Steps to Reproduce Issue (if applicable):</b><br><br>", isHTML: true)
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto:")!)
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        guard let scheme = URL.scheme else { return true }
        if scheme != "http" && scheme != "https" { return true }
        
        let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
        return false 
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
        feedbackButton.backgroundColor = ThemeManager.currentTheme().mainColor
        
        ferriesFeedbackButton.layer.cornerRadius = 5
        ferriesFeedbackButton.clipsToBounds = true
        ferriesFeedbackButton.backgroundColor = ThemeManager.currentTheme().mainColor
        
        bugReportButton.layer.cornerRadius = 5
        bugReportButton.clipsToBounds = true
        bugReportButton.backgroundColor = ThemeManager.currentTheme().mainColor
        
        jobsButton.layer.cornerRadius = 5
        jobsButton.clipsToBounds = true
        jobsButton.backgroundColor = ThemeManager.currentTheme().mainColor
        
    }
}
