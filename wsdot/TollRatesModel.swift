//
//  TollRatesModel.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

class TollRatesModel {

    static func getSR16data() -> [FourColItem]{
        var data = [FourColItem]()
        
        var item = FourColItem(one: "Number of Axles", two: "Good To Go! Pass",three: "Cash", four: "Pay By Mail", header: true)
        data.append(item)
        item = FourColItem(one: "Two (includes motorcycle)", two: "$5.00",three: "$6.00", four: "$7.00", header: false)
        data.append(item)
        item = FourColItem(one: "Three", two: "$7.50",three: "$9.00", four: "$10.50", header: false)
        data.append(item)
        item = FourColItem(one: "Four", two: "$10.00",three: "$12.00", four: "$14.00", header: false)
        data.append(item)
        item = FourColItem(one: "Five", two: "$12.50",three: "$15.00", four: "$17.50", header: false)
        data.append(item)
        item = FourColItem(one: "Six or more", two: "$15.00",three: "$18.00", four: "$21.00", header: false)
        data.append(item)
        return data
    }
}

class FourColItem{
    
    let colOne: String
    let colTwo: String
    let colThree: String
    let colFour: String
    let header: Bool
    
    init(one: String, two: String, three: String, four: String, header: Bool){
        self.colOne = one
        self.colTwo = two
        self.colThree = three
        self.colFour = four
        self.header = header
    }

}