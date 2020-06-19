//
//  HomeView.swift
//  WSDOT
//
//  Created by Logan Sims on 6/10/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI
import RealmSwift
import Foundation

@available(iOS 13.0.0, *)
struct HomeView: View {

    @ObservedObject var passes: BindableResults<MountainPassItem>
    @ObservedObject var ferrySchedules: BindableResults<FerryScheduleItem>
    @ObservedObject var alerts: BindableResults<HighwayAlertItem>
    
    var body: some View {
        
        
        return NavigationView {

            ScrollView {
                TrafficRow(categoryName: "Traffic & Travel")
                    .padding(.trailing, 15)
                FerriesRow(categoryName: "Ferries", ferrySchedules: ferrySchedules)
                MountainPassesRow(categoryName: "Mountain Passes", passes: passes)
                HighestImpactAlertsRow(categoryName: "High Impact Alerts", alerts: alerts)
                Spacer()
            }
            .navigationBarTitle(Text("WSDOT"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                            print("notification button pressed...")
                        }) {
                            Image("icNotification")
                        },
                trailing: Button(action: {
                            print("info button pressed...")
                        }) {
                            Image("icInfo")
                        }
            )
            .background(Color(UIColor.secondarySystemBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
