//
//  HighestImpactAlertsItems.swift
//  WSDOT
//
//  Created by Logan Sims on 6/22/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct HighestImpactAlertsItem: View {
    
    @State var showingDetail = false
    
    var alert: HighwayAlertItem
    
    var body: some View {
        
        Button(action: {
              self.showingDetail.toggle()
        }) {
        
            VStack() {
                HStack(alignment: .top) {
                    Text(alert.headlineDesc)
                        .font(.caption)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .padding(.top, 5)
                    Spacer()
                }
                Spacer()
            }
            .background(Color(UIColor.tertiarySystemBackground))
            .frame(minWidth: 0, maxWidth: 300, minHeight: 70, maxHeight: 70, alignment: .center)
            .cornerRadius(4)
            .padding(.leading, 15)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .shadow(radius: 2)
            .transition(.move(edge: .leading))
            
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            
            HighwayAlertMapDetails(alert: self.alert)

        }
    }
}

@available(iOS 13.0.0, *)
struct HighestImpactAlertsItem_Previews: PreviewProvider {
    static var previews: some View {
        HighestImpactAlertsItem(alert: HighwayAlertItem.init())
    }
}
