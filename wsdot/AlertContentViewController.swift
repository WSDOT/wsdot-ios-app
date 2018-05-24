//
//  HighwayAlertsPagerViewController.swift
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

class AlertContentViewController: UIViewController{

    var itemIndex: Int = 0
    var alertText = ""
    var loadingPage = false
    var alert = HighwayAlertItem()
    var alertCount = 1
    var alertNumber = 1
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.lightGrey
        self.view.frame = parent!.view.frame
        
        if loadingPage {
            progressIndicator.startAnimating()
            alertLabel.isHidden = true
        }else {
            alertLabel.text = alertText
            
            alertLabel.accessibilityLabel = "highest impact alert " + String(alertNumber) + " of " + String(alertCount) + ". " + alertText
            
            if (alert.alertId != 0){
                let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlertContentViewController.labelAction(_:)))
                tapGesture.numberOfTapsRequired = 1
                alertLabel.isUserInteractionEnabled =  true
                alertLabel.addGestureRecognizer(tapGesture)
            }
            progressIndicator.isHidden = true
            progressIndicator.isAccessibilityElement = false
        }
    }
    
    @objc func labelAction(_ sender: UILabel){
        performSegue(withIdentifier: SegueHighwayAlertViewController, sender: self)
    }
    
     // MARK: Naviagtion
    // Get refrence to child VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueHighwayAlertViewController {
            let destinationViewController = segue.destination as! HighwayAlertViewController
            destinationViewController.alertId = alert.alertId
        }
    }
    
}
