//
//  HomeRow.swift
//  WSDOT
//
//  Created by Logan Sims on 6/10/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct HomeButton: View {
    
    var rowName: String
    var image: Image
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            image
            Text(rowName)
        }.padding()
    }
}

@available(iOS 13.0.0, *)
struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HomeButton(
            rowName: "Traffic Map",
            image: Image("icHomeTraffic")
        )
    }
}
