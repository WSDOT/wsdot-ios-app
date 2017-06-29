//
//  TollRatesModel.swift
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

import Foundation

class TollRatesStore {

    static func getSR520data() -> [ThreeColItem] {
        var data = [ThreeColItem]()
        
        var item = ThreeColItem(colOne: "Monday to Friday", colTwo: "Good To Go! Pass", colThree: "Pay By Mail", header: true)
        data.append(item)
        item = ThreeColItem(colOne: "Midnight to 5 AM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "5 AM to 6 AM", colTwo: "$2.00",colThree: "$4.00",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 AM to 7 AM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 AM to 9 AM", colTwo: "$4.30",colThree: "$6.30",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 AM to 10 AM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "10 AM to 2 PM", colTwo: "$2.70",colThree: "$4.70",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "2 PM to 3 PM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "3 PM to 6 PM", colTwo: "$4.30",colThree: "$6.30",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 7 PM", colTwo: "$3.40",colThree: "$5.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "7 PM to 9 PM", colTwo: "$2.70",colThree: "$4.70",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 PM to 11 PM", colTwo: "$2.00",colThree: "$4.00",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 11:59 PM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "Weekends and Holidays", colTwo: "Good To Go! Pass", colThree: "Pay By Mail",  header: true)
        data.append(item)
        item = ThreeColItem(colOne: "Midnight to 5 AM", colTwo: "$1.25",colThree: "$3.25",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "5 AM to 8 AM", colTwo: "$1.40",colThree: "$3.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "8 AM to 11 AM", colTwo: "$2.05",colThree: "$4.05",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 AM to 6 PM", colTwo: "$2.65",colThree: "$4.65",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "6 PM to 9 PM", colTwo: "$2.05",colThree: "$4.05",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "9 PM to 11 PM", colTwo: "$1.40",colThree: "$3.40",  header: false)
        data.append(item)
        item = ThreeColItem(colOne: "11 PM to 11:59 PM", colTwo: "$1.25",colThree: "$3.25",  header: false)
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
