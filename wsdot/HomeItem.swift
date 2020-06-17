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
    var image: Image = Image("icFerry")
    
    var body: some View {
        HStack(alignment: .center) {
            
            VStack(alignment: .center) {
                
                RoundIcon(image: image)
                
            }
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            Text(title)
                .padding(.trailing, 15)
                .font(.headline)
            
        
            
        }
        //.padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .topLeading)
            .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(5 )
        .padding(.leading, 15)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .shadow(radius: 2)
        
        
  
    }
}

@available(iOS 13.0.0, *)
struct HomeItem_Previews: PreviewProvider {
    static var previews: some View {
        HomeItem(title: "this is a test of a very long title")
    }
}
