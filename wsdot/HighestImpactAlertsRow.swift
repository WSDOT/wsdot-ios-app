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
                VStack(alignment: .leading, spacing: 0) {
                                         
                    ForEach(alerts.results, id: \.alertId) { alert in
                
                        HStack() {
                            
                            
                            VStack(alignment: .leading) {
            
                                RoundIcon(
                                    image: Image("icMap"),
                                    bgColor: Color.clear
                                )
                                
                                Spacer()
                                //Text(alert.eventCategory)
                                //    .lineLimit(1)
                                //    .font(.caption)
                                //    .foregroundColor(.white)
                                //    .padding(4)
                                                 
                            }
                            .frame(minWidth: 0, maxWidth: 24, minHeight: 0, maxHeight: .infinity)
                            .background(Color(Colors.wsdotPrimary))
                                
                            Spacer()
                            
                            Text(alert.headlineDesc)
                                .font(.caption)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                                .padding(.top, 5)
                        
              
                            
                        }
                            
                        .background(Color(UIColor.tertiarySystemBackground))
                        .frame(width: 150, height: 100, alignment: .topLeading)
                        .cornerRadius(4)
                        .padding(.leading, 15)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .shadow(radius: 2)
                        .transition(.move(edge: .leading))
                
                    }.animation(.default)
                    
                    
                }
          
            }
                
            }
        }
    }
}
