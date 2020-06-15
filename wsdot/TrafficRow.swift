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
                .padding(.top, 5)

  
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
      
                    //   NavigationLink(
                    //       destination: LandmarkDetail(
                    //           landmark: landmark
                    //       )
                    //   ) {
               
                    //}
                  
                    HomeItem(title: "Map")
                    HomeItem(title: "Toll Rates")
                    HomeItem(title: "Border Waits")
                    HomeItem(title: "Amtrak Cascades")
                }
            }
        }
    }
}
