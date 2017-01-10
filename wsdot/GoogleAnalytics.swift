//
//  GoogleAnalytics.swift
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

class GoogleAnalytics {
    
    static let analytics_enabled = true
    static let analytics_dryrun = true
    
    static func screenView(screenName: String){
        if (GoogleAnalytics.analytics_enabled){
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.set(kGAIScreenName, value: screenName)
                if let builder = GAIDictionaryBuilder.createScreenView() {
                    tracker.send(builder.build() as [NSObject : AnyObject])
                }
            }
        }
    }
    
    static func event(category: String, action: String, label: String){
        if (GoogleAnalytics.analytics_enabled){
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil).build() as [NSObject : AnyObject])
            }
        }
    }
}
