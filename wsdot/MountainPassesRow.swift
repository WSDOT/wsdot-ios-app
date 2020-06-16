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
    
    @ObservedObject var passes: BindableResults<MountainPassItem>

    var body: some View {
        
        return VStack(alignment: .leading) {
            
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 0) {
                    
                    if passes.results.count == 0 {
                        RowItem(title: "", details: "", loading: true) {
                                                   print("")
                                               }
                    }
                  
                    ForEach(passes.results, id: \.id) { pass in
                        
                     //   NavigationLink(
                     //       destination: LandmarkDetail(
                     //           landmark: landmark
                     //       )
                     //   ) {
                        RowItem(
                            title: pass.name,
                            details: pass.roadCondition,
                            isFavorite: pass.selected) {
                                MountainPassStore.updateFavorite(pass, newValue: !pass.selected)}
                        //}
                        
                    }.animation(.default)
                }
            }
        }
    }
}
