//
//  TollRatesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class TollRatesViewController: UIViewController{


    @IBOutlet weak var SR520ContainerView: UIView!
    @IBOutlet weak var SR16ContainerView: UIView!
    @IBOutlet weak var SR167ContainerView: UIView!
    @IBOutlet weak var I405ContainerView: UIView!

    override func viewDidLoad() {
        title = "Toll Rates"
    }
    
    // Remove and add hairline for nav bar
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Toll Rates/SR520")
    
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, forBarMetrics: .Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex){
            
        case 0:
            GoogleAnalytics.screenView("/Toll Rates/SR520")
            SR520ContainerView.hidden = false
            SR16ContainerView.hidden = true
            SR167ContainerView.hidden = true
            I405ContainerView.hidden = true
            break
        case 1:
            GoogleAnalytics.screenView("/Toll Rates/SR16")
            SR520ContainerView.hidden = true
            SR16ContainerView.hidden = false
            SR167ContainerView.hidden = true
            I405ContainerView.hidden = true
            break
        case 2:
            GoogleAnalytics.screenView("/Toll Rates/SR167")
            SR520ContainerView.hidden = true
            SR16ContainerView.hidden = true
            SR167ContainerView.hidden = false
            I405ContainerView.hidden = true
            break
        case 3:
            GoogleAnalytics.screenView("/Toll Rates/I405")
            SR520ContainerView.hidden = true
            SR16ContainerView.hidden = true
            SR167ContainerView.hidden = true
            I405ContainerView.hidden = false
            break
        default:
            break
        }
    }
}