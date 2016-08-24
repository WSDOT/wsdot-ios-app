//
//  TollRatesModel.swift
//  WSDOT
//
//  Created by Logan Sims on 8/18/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

class TollRatesStore {

    static func getSR520data() -> [ThreeColItem] {
        var data = [ThreeColItem]()
        
        var item = ThreeColItem(colOne: "Monday to Friday", colTwo: "Good To Go! Pass", colThree: "Pay By Mail", header: true)
        data.append(item)
        item = ThreeColItem(colOne: "Midnight to 5 AM", colTwo: "$0",colThree: "$0",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "5 AM to 6 AM", colTwo: "$1.90",colThree: "$3.90",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 AM to 7 AM", colTwo: "$3.25",colThree: "$5.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 AM to 9 AM", colTwo: "$4.10",colThree: "$6.10",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 AM to 10 AM", colTwo: "$3.25",colThree: "$5.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "10 AM to 2 PM", colTwo: "$2.55",colThree: "$4.55",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "2 PM to 3 PM", colTwo: "$3.25",colThree: "$5.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "3 PM to 6 PM", colTwo: "$4.10",colThree: "$6.10",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 7 PM", colTwo: "$3.25",colThree: "$5.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 PM to 9 PM", colTwo: "$2.55",colThree: "$4.55",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 PM to 11 PM", colTwo: "$1.90",colThree: "$3.90",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 11:59 PM", colTwo: "$0",colThree: "$0",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "Weekends and Holidays", colTwo: "Good To Go! Pass", colThree: "Pay By Mail",  header: true)
        data.append(item)
        item = ThreeColItem(colOne: "Midnight to 5 AM", colTwo: "$0",colThree: "$0",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "5 AM to 8 AM", colTwo: "$1.30",colThree: "$3.30",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "8 AM to 11 AM", colTwo: "$1.95",colThree: "$3.95",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 AM to 6 PM", colTwo: "$2.50",colThree: "$4.50",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 9 PM", colTwo: "$1.95",colThree: "$3.95",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 PM to 11 PM", colTwo: "$1.30",colThree: "$3.30",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 11:59 PM", colTwo: "$0",colThree: "$0",  header: false)
        data.append(item)
        return data
    }

    static func getSR16data() -> [FourColItem]{
        var data = [FourColItem]()
        
        var item = FourColItem(colOne: "Number of Axles", colTwo: "Good To Go! Pass",colThree: "Cash", colFour: "Pay By Mail", header: true)
        data.append(item)
        item = FourColItem(colOne: "Two (includes motorcycle)", colTwo: "$5.00",colThree: "$6.00", colFour: "$7.00", header: false)
        data.append(item)
        item = FourColItem(colOne: "Three", colTwo: "$7.50",colThree: "$9.00", colFour: "$10.50", header: false)
        data.append(item)
        item = FourColItem(colOne: "Four", colTwo: "$10.00",colThree: "$12.00", colFour: "$14.00", header: false)
        data.append(item)
        item = FourColItem(colOne: "Five", colTwo: "$12.50",colThree: "$15.00", colFour: "$17.50", header: false)
        data.append(item)
        item = FourColItem(colOne: "Six or more", colTwo: "$15.00",colThree: "$18.00", colFour: "$21.00", header: false)
        data.append(item)
        return data
    }
}

struct FourColItem{
    let colOne: String
    let colTwo: String
    let colThree: String
    let colFour: String
    let header: Bool
}

struct ThreeColItem{
    let colOne: String
    let colTwo: String
    let colThree: String
    let header: Bool
}