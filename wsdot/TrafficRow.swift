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
            
            Text(self.categoryName)
                .font(.headline)
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
                        image: Image("icMap")
                    )
                        
                    HomeItem(
                        title: "Border Waits",
                        image: Image("icBorderWaits")
                    )
                }
                  
                HStack() {
                    HomeItem(
                        title: "Toll Rates",
                        image: Image("icTollRates")
                    )
                    HomeItem(
                        title: "Amtrak Cascades",
                        image: Image("icTrain")
                    )
                }
                
                HStack() {
                    HomeItem(
                        title: "My Routes",
                        image: Image("icRoute")
                    )
                    HomeItem(
                        title: "Favorites",
                        image: Image("icFillHeart")
                    )
                }
                
            }
        }
    }
}
