//
//  HighwayAlertMapDetails.swift
//  WSDOT
//
//  Created by Logan Sims on 6/22/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct HighwayAlertMapDetails: View {
    
    var alert: HighwayAlertItem
    
    var body: some View {
                        
        ZStack(alignment: .bottom) {
        
            GoogleMapsView(
                zoom: 13,
                latitude: self.alert.startLatitude,
                longitude: self.alert.startLongitude
            )
            .edgesIgnoringSafeArea(.bottom)
            .edgesIgnoringSafeArea(.top)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            
        
            VStack() {
                
                VStack() {
                    Section() {
                        Text(self.alert.eventCategory)
                        .font(.headline)
                    }
                    .padding(15)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(15)
                .padding(.bottom, 35)
                .shadow(radius: 2)
                
                Spacer()
                
                VStack() {
                    Text(self.alert.headlineDesc)
                    .padding(15)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(15)
                .padding(.bottom, 35)
                .shadow(radius: 2)
            }
          
        }
    }
}
