//
//  ExpressLanesItem.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
import Foundation

class BestTimesToTravelItem {

    let available: Bool
    let name: String
    let routes: [BestTimesToTravelRouteItem]

    init(available: Bool, name: String, routes: [BestTimesToTravelRouteItem]){
        self.available = available
        self.name = name
        self.routes = routes
    }

}

class BestTimesToTravelRouteItem{
    let name: String
    let charts: [TravelChartItem]

    init(name: String, charts: [TravelChartItem]){
        self.name = name
        self.charts = charts
    }
}

class TravelChartItem {

    let url: String
    let altText: String
    
    init(url: String, altText: String){
        self.url = url
        self.altText = altText
    }
}
