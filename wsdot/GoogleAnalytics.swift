//
//  GoogleAnalytics.swift
//  WSDOT
//
//  Created by Logan Sims on 9/2/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

class GoogleAnalytics {
    
    static func screenView(screenName: String){
        if (ApiKeys.analytics_enabled){
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: screenName)
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
    }
    
    static func event(category: String, action: String, label: String){
        if (ApiKeys.analytics_enabled){
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: nil).build() as [NSObject : AnyObject])
        }
    }
}