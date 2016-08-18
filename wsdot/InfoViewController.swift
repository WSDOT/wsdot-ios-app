//
//  InfoViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/17/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {
   
    @IBOutlet weak var aboutText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        aboutText.sizeToFit()
        
        aboutText.text = "The mission of the Washington State Department of Transportation is to keep people and business moving by operating and improving the state's transportation systems vital to our taxpayers and communities. \n\nThe WSDOT mobile app was created to make it easier for you to know the latest about Washington's transportation system."
        
    }
    
    @IBAction func composeFeedbackMessage(sender: UIButton) {
    
        let bundle = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let version = bundle as! String
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["simsl@wsdot.wa.gov"])
            mail.setSubject("WSDOT iOS v\(version) Feedback ")
            presentViewController(mail, animated: true, completion: nil)
        } else {
            presentViewController(AlertMessages.getMailAlert(), animated: true, completion: nil)
        }
        
    }
    
    @IBAction func composeBugReport(sender: UIButton) {
    
        let bundle = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let version = bundle as! String
    
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["simsl@wsdot.wa.gov"])
            mail.setSubject("WSDOT iOS v\(version) Bug Report ")
            mail.setMessageBody("<b>Bug Description:<b><br><br> <b>Steps to Reproduce:</b><br><br> <b>Paste Any Screenshots Below: </b><br><br>", isHTML: true)
            presentViewController(mail, animated: true, completion: nil)
        } else {
            presentViewController(AlertMessages.getMailAlert(), animated: true, completion: nil)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Saved")
        case MFMailComposeResultSent.rawValue:
            print("Sent")
        case MFMailComposeResultFailed.rawValue:
            print("Error: \(error?.localizedDescription)")
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}