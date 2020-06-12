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
    
    @ObservedObject var items: RealmSwift.List<MountainPassItem>

    var body: some View {
   
        return VStack(alignment: .leading) {
            
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
       
                    ForEach(items, id: \.id) { content in
                     //   NavigationLink(
                     //       destination: LandmarkDetail(
                     //           landmark: landmark
                     //       )
                     //   ) {
                        ContentItem(content: content)
                        //}
                    }
                }
            }
            //.frame(height: 185)
        }
    }
}

@available(iOS 13.0.0, *)
struct ContentItem: View {
    var content: MountainPassItem
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(content.name)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Text(content.roadCondition)
                .font(.caption).lineLimit(nil)
        }
        .padding()
        .frame(width: 180, height: 100, alignment: .topLeading)
        .background(Color.green)
        .cornerRadius(10)
        .padding(.leading, 15)
        .padding(.top, 10)
        .padding(.bottom, 10)
    .shadow(radius: 5)
        
        
  
    }
}


@available(iOS 13.0.0, *)
struct HomeRow_Previews: PreviewProvider {
    static var previews: some View {
        
        let pass1 = MountainPassItem()
        pass1.name = "test pass 1"
        
        let passes = RealmSwift.List<MountainPassItem>()
        passes.append(pass1)
        
        return MountainPassesRow(
            categoryName: "Mountain Passes",
            items: RealmSwift.List<MountainPassItem>()
        )
    }
}
 

/*
@available(iOS 13.0, *)
struct HomeRow_Previews: PreviewProvider {
    static var previews: some View {
        HomeRow(categoryName: "Mountain Passes",
                items: .init())
    }
}
*/
