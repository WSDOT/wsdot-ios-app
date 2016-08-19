//
//  SR16ViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class SR16ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "fourColCell"
    
    @IBOutlet var tableView: UITableView!
    var data = [FourColItem]()
    
    override func viewDidLoad() {
        
        data = TollRatesModel.getSR16data()
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! FourColTableCell

        cell.colOneLabel.text = data[indexPath.row].colOne
        cell.colTwoLabel.text = data[indexPath.row].colTwo
        cell.colThreeLabel.text = data[indexPath.row].colThree
        cell.colFourLabel.text = data[indexPath.row].colFour
        
        if (data[indexPath.row].header){
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }
                
        return cell
    }
    
}
