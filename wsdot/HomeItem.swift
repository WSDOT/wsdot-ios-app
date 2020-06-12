//
//  HomeCategories.swift
//  WSDOT
//
//  Created by Logan Sims on 6/10/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//


import SwiftUI

@available(iOS 13.0, *)
struct HomeItem: Hashable, Codable, Identifiable {
    
    var id: Int
    var name: String
    fileprivate var imageName: String

}

@available(iOS 13.0, *)
extension HomeItem {
    var image: Image {
        Image(imageName)
    }
}
