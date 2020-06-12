//
//  HomeData.swift
//  WSDOT
//
//  Created by Logan Sims on 6/10/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//


import SwiftUI

@available(iOS 13.0, *)
let homeData: [HomeItem] = load("homeData.json")

@available(iOS 13.0, *)
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

@available(iOS 13.0.0, *)
struct HomeData_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
