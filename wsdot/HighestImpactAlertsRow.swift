//
//  HighestImpactAlertsRow.swift
//  WSDOT
//
//  Created by Logan Sims on 6/16/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI
import RealmSwift

@available(iOS 13.0.0, *)
struct HighestImpactAlertsRow: View {
    
    var categoryName: String
    @ObservedObject var alerts: BindableResults<HighwayAlertItem>
    
    private func getAlertText(numAlerts: Int) -> String {
        if numAlerts == 1 {
            return "\(numAlerts) Alert"
        } else if numAlerts > 1 {
            return "\(numAlerts) Alerts"
        } else {
            return ""
        }
    }
    
    var body: some View {
        
        return VStack(alignment: .leading) {
            
            if (alerts.results.count > 0) {
            
                Text(self.categoryName)
                    .font(.headline)
                    .padding(.leading, 15)
                    .padding(.top, 5)
            
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top) {
                                         
                        ForEach(self.alerts.results, id: \.self) { alert in
                
                            HighestImpactAlertsItem(alert: alert)
                
                        }.animation(.default)
                    
                    
                    }
                }
            }
        }
    }
}
