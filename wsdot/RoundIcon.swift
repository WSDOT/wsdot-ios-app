//
//  RoundIcon.swift
//  WSDOT
//
//  Created by Logan Sims on 6/17/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct RoundIcon: View {
    
    var image: Image
    var imageColor: Color = Color.white
    var bgColor: Color = Color(Colors.wsdotPrimary)
    
    var body: some View {
        
        ZStack(alignment: .center) {
        
            Circle()
                .fill(bgColor)
                .frame(width: 32, height: 32)
            //.shadow(radius: 5)
            
            image
                .resizable().renderingMode(.template)
                .frame(width: 22, height: 22)
                .foregroundColor(imageColor)
            
        }
    }
}

@available(iOS 13.0.0, *)
struct RoundIcon_Previews: PreviewProvider {
    static var previews: some View {
        RoundIcon(image: Image("icFerry"))
    }
}
