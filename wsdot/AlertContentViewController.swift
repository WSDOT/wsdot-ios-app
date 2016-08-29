//
//  HighwayAlertsPagerViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/26/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class AlertContentViewController: UIViewController{

    var itemIndex: Int = 0
    var alertText = ""
    var loadingPage = false
    var alert = HighwayAlertItem()
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = Colors.lightGrey
        self.view.frame = parentViewController!.view.frame
        
        if loadingPage {
            progressIndicator.startAnimating()
            alertLabel.hidden = true
        }else {
            alertLabel.text = alertText
            
            if (alert.alertId != 0){
                let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlertContentViewController.labelAction(_:)))
                tapGesture.numberOfTapsRequired = 1
                alertLabel.userInteractionEnabled =  true
                alertLabel.addGestureRecognizer(tapGesture)
            }
            progressIndicator.hidden = true
        }
    }
    
    func labelAction(sender: UILabel){
        performSegueWithIdentifier(SegueHighwayAlertViewController, sender: self)
    }
    
     // MARK: Naviagtion
    // Get refrence to child VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueHighwayAlertViewController {
            let destinationViewController = segue.destinationViewController as! HighwayAlertViewController
            destinationViewController.alertItem = alert
        }
    }
    
}
