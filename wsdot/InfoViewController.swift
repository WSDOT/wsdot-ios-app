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
    @IBOutlet weak var privacyPolicyText: UITextView!

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
        
        aboutText.text = "This app is provided to you by the Washington State Department of Transportation. Please use this to know before you go and never ever use this app while driving. Safe Travels!\n\nDISCLAIMER: WSDOT provides this information on an AS-IS basis and specifically disclaims all warranties of any kind, express or implied, arising out of or relating to the information provided in this app. To the maximum extent permitted by applicable law, WSDOT shall not be liable to you for any actual, consequential, incidental, indirect, or other damages related to your use of this information. It is your responsibility to observe conditions on the road and adjust your plans and driving accordingly."
    
        aboutText.isEditable = false
        appVersionLabel.text = "App version: " + version
        
        let attributedString = NSMutableAttributedString(string: "Privacy Policy")
        let url = URL(string: "https://wsdot.wa.gov/about/policies/web-privacy-notice")!

        attributedString.setAttributes([.link: url], range: NSMakeRange(0, attributedString.string.count))

        privacyPolicyText.attributedText = attributedString
        privacyPolicyText.isUserInteractionEnabled = true
        privacyPolicyText.isEditable = false
        privacyPolicyText.textAlignment = .center
        privacyPolicyText.linkTextAttributes = [
            .foregroundColor: Colors.wsdotPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        styleButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "About")
    }
    
    @IBAction func openJobsSite(_ sender: UIButton) {
        
        MyAnalytics.event(category: "About", action: "open_link", label: "jobs")
   
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL(string: self.jobsUrlString)!, configuration: config)
        
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
            UIApplication.shared.open(URL(string: "mailto:")!)
        }
    }
    
    @IBAction func composeFerriesFeedbackMessage(_ sender: UIButton) {
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.navigationBar.tintColor = Colors.yellow
            mail.mailComposeDelegate = self
            mail.setToRecipients(["wsfinfo@wsdot.wa.gov"])
            mail.setSubject("Ferries Feedback")
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(URL(string: "mailto:")!)
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
            UIApplication.shared.open(URL(string: "mailto:")!)
        }
    }
    
    // MARK: - UITextViewDelegate
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
