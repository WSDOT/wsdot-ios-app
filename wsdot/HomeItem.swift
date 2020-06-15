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
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(title)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.white)
            
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80, alignment: .topLeading)
        .background(Color(Colors.wsdotPrimary))
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
