//
//  TrafficRow.swift
//  WSDOT
//
//  Created by Logan Sims on 6/15/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI
import RealmSwift

@available(iOS 13.0.0, *)
struct TrafficRow: View {
    
    var categoryName: String

    var body: some View {
        
        return VStack(alignment: .leading) {
            
            
            HStack(alignment: .center, spacing: 0) {
                Text(self.categoryName)
                    .font(.headline)
                    
            
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("My Routes")
                }.accentColor(Color(Colors.wsdotPrimary))

            }
            .padding(.leading, 15)
            .padding(.top, 15)

            VStack(alignment: .center, spacing: 0) {
      
                    //   NavigationLink(
                    //       destination: LandmarkDetail(
                    //           landmark: landmark
                    //       )
                    //   ) {
               
                    //}
                HStack() {
                    HomeItem(
                        title: "Traffic Map",
                        image: Image("icHomeTraffic")
                    )
                        
                    HomeItem(
                        title: "Border Waits",
                        image: Image("icHomeBorderWaits")
                    )
                }
                  
                HStack() {
                    HomeItem(
                        title: "Toll Rates",
                        image: Image("icHomeTollRates")
                    )
                    HomeItem(
                        title: "Amtrak Cascades",
                        image: Image("icHomeAmtrakCascades")
                    )
                }
            }
        }
    }
}
