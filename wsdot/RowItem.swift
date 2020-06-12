//
//  RowItem.swift
//  WSDOT
//
//  Created by Logan Sims on 6/12/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct RowItem: View {
    
    var title: String
    var details: String
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(title)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Text(details)
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
struct RowItem_Previews: PreviewProvider {
    static var previews: some View {
        RowItem(title: "title", details: "Detail text")
    }
}
