//
//  SegmentedControlWithBadge.swift
//  WSDOT
//
//  Created by Logan Sims on 10/5/18.

//  Copyright (c) 2018 Washington State Department of Transportation
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

/*
  Custom class that supports adding one badge at a given segment.
  If the badge's segment is out of bounds, it simply won't display it.
*/
class SegmentedControlWithBadge: UISegmentedControl {

    fileprivate var badgeView: UIView?
    
    fileprivate var badgeValue = ""
    fileprivate var badgeSegment = -1
    
    func setbadge(value: String, forSegmentAt: Int) {
        badgeValue = value
        badgeSegment = forSegmentAt
        drawBadge()
        
    }
    
    func redrawBadge(){
        guard let bView = badgeView else { return }
        bView.removeFromSuperview()
        drawBadge()
    }
    
    fileprivate func drawBadge() {
        if numberOfSegments >= badgeSegment && badgeSegment >= 0 {
            let badge = getBadge(badgeValue, badgeSegment)
            badgeView = UIView(frame: self.frame)
            badgeView!.backgroundColor = UIColor.clear
            badgeView!.isUserInteractionEnabled = false
            badgeView!.addSubview(badge)
            badgeView!.isAccessibilityElement = false
            self.superview?.addSubview(badgeView!)
        }
    }
    
    fileprivate func getBadge(_ text: String, _ forSegmentAt: Int) -> UILabel {
        
        let label = UILabel(frame: CGRect(x: (self.frame.size.width/CGFloat(self.numberOfSegments) * (CGFloat(forSegmentAt)+1.0) - 20.0) , y: 2, width: 18, height: 18))
        
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont(name: "SanFranciscoText", size: 6)
        label.textColor = .white
        label.backgroundColor = UIColor.init(red: 230.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        label.text = text
        return label
    }
}

enum SegmentControlError: Error {
    case segmentIndex(String)
}
