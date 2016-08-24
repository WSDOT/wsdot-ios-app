//
//  SR520TollRatesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class SR520ViewController: UIViewController {
    
    let cellIdentifier = "threeColCell"

    var data = [ThreeColItem]()
    
    override func viewDidLoad() {
        
        data = TollRatesStore.getSR520data()
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ThreeColTableCell

        cell.colOneLabel.text = data[indexPath.row].colOne
        cell.colTwoLabel.text = data[indexPath.row].colTwo
        cell.colThreeLabel.text = data[indexPath.row].colThree
        
        if (data[indexPath.row].header){
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        } else {
            cell.backgroundColor = UIColor.lightTextColor()
        }
                
        return cell
    }
    
}