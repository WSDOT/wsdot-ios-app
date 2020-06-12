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
    
    var homeItems: [HomeItem] {
        homeData
    }
    
    var body: some View {
        NavigationView {
            /*
            List {
                ForEach(homeItems) { item in
                    HomeButton(rowName: item.name, image: item.image)
                }
            }
            */
            MountainPassesRow(categoryName: "Mountain Passes", items: items)
           
        }.navigationBarTitle(Text("WSDOT"))
    }
}
