//
//  FerriesRow.swift
//  WSDOT
//
//  Created by Logan Sims on 6/15/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//


import SwiftUI
import RealmSwift

@available(iOS 13.0.0, *)
struct FerriesRow: View {
    
    var categoryName: String
    @ObservedObject var ferrySchedules: BindableResults<FerryScheduleItem>
    
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
            
            HStack() {
                Text(self.categoryName)
                    .font(.headline)
                    .padding(.leading, 15)
                    .padding(.top, 5)
            
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Vessel Watch")
                }
                .padding(.trailing, 8)
                .padding(.leading, 8)
                .padding(.top, 4)
                .padding(.bottom, 4)
                .accentColor(Color(Colors.wsdotPrimary))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(Colors.wsdotPrimary), lineWidth: 1)
                )
                
                Button(action: {
                   
                }) {
                    Text("Buy Tickets")
                }
                .padding(.trailing, 8)
                .padding(.leading, 8)
                .padding(.top, 4)
                .padding(.bottom, 4)
                .accentColor(Color(Colors.wsdotPrimary))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(Colors.wsdotPrimary), lineWidth: 1)
                )
                
            }.padding(.trailing, 15)
            
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 0) {
      
                    if ferrySchedules.results.count == 0 {
                        RowItem(title: "", details: "", loading: true) {
                            print("")
                        }
                    }
                                         
                    ForEach(ferrySchedules.results, id: \.routeId) { schedule in
                
                            RowItem(
                                title:schedule.routeDescription,
                                details: self.getAlertText(numAlerts: schedule.routeAlerts.count),
                                isFavorite: schedule.selected) {
                                    FerryRealmStore.updateFavorite(schedule, newValue: !schedule.selected)
                                }
                
                    }.animation(.default)
                }
            }
        }
    }
}
