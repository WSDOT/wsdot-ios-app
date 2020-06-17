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
    
    var title: String = ""
    var details: String = ""
    var isFavorite: Bool = false
    var loading: Bool = false
    var height: CGFloat = 120
    var actionFavorite: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            
            if loading {
                        Spacer()
                        HStack() {
                            Spacer()
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                            Spacer()
                        }
                        Spacer()
            } else {
            
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading) {
                        Text(title).lineLimit(nil)
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 5)
                    .padding(.top, 5)
            
                    Spacer()
            
                    Button(action: {
                        self.actionFavorite()
                    }) {
                        if isFavorite {
                            Image("icFillHeart").resizable().frame(width: 24, height: 24).foregroundColor(Color(Colors.wsdotPrimary))
                        } else {
                            Image("icLineHeart").resizable().frame(width: 24, height: 24).foregroundColor(Color(Colors.wsdotPrimary))
                        }
                    }
                    .padding(.trailing, 5)
                    .padding(.top, 5)
                }
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(details)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                       
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color(Colors.wsdotPrimary))
                
            }
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .frame(width: 150, height: height, alignment: .topLeading)
        .cornerRadius(10)
        .padding(.leading, 15)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .shadow(radius: 2)
        .transition(.move(edge: .leading)) // adds animation
  
    }
}

@available(iOS 13.0.0, *)
struct RowItem_Previews: PreviewProvider {
    static var previews: some View {
        RowItem(title: "title", details: "Detail text") {
                                   print("")
                               }
    }
}
