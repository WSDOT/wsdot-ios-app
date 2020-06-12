//
//  HomeRow.swift
//  WSDOT
//
//  Created by Logan Sims on 6/10/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI
import RealmSwift

@available(iOS 13.0.0, *)
struct MountainPassesRow: View {
    
    var categoryName: String
    
    var items: BindableResults<MountainPassItem>

    var body: some View {
   
        return VStack(alignment: .leading) {
            
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
       
                    ForEach(items.results, id: \.id) { content in
                     //   NavigationLink(
                     //       destination: LandmarkDetail(
                     //           landmark: landmark
                     //       )
                     //   ) {
                        RowItem(
                            title: content.name,
                            details: content.roadCondition)
                        //}
                    }
                }
            }
            //.frame(height: 185)
        }
    }
}
