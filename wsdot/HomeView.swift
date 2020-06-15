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

    @ObservedObject var items: BindableResults<MountainPassItem>
    
    var body: some View {
        
        return NavigationView {
            /*
            List {
                ForEach(homeItems) { item in
                    HomeButton(rowName: item.name, image: item.image)
                }
            }
            */
            
            VStack {
                TrafficRow(categoryName: "Traffic & Travel")
                FerriesRow(categoryName: "Ferries")
                MountainPassesRow(categoryName: "Mountain Passes", passes: items)
                Spacer()
            }.navigationBarTitle(Text("WSDOT"))
        }
    }
}
