//
//  HomeItem.swift
//  WSDOT
//
//  Created by Logan Sims on 6/15/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct HomeItem: View {
    
    var title: String
    var image: Image = Image("icHomeTraffic")
    
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .center) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                }.frame(minWidth: 70, maxWidth: 70, minHeight: 0, maxHeight: .infinity, alignment: .center)
                .padding(.leading, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            Text(title)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            //    .foregroundColor(.white)
                .padding(.top, 15)
                .padding(.trailing, 15)
            
        
            
        }
        //.padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80, alignment: .topLeading)
            .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .padding(.leading, 15)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .shadow(radius: 5)
        
        
  
    }
}

@available(iOS 13.0.0, *)
struct HomeItem_Previews: PreviewProvider {
    static var previews: some View {
        HomeItem(title: "title")
    }
}
