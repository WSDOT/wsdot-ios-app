//
//  I405TollRateItem.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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
class I405TollRateItem {

    let tripName: String
    let currentToll: Float
    let currentMessage: String
    let stateRoute: Int
    let travelDirection: String
    
    let startLocationName: String
    let endLocationName: String
    
    let startLatitude: Double
    let startLongitude: Double
    
    let endLatitude: Double
    let endLongitude: Double

    init(tripName: String, currentToll: Float, currentMessage: String, stateRoute: Int, travelDirection: String, startLocationName: String, endLocationName: String, startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double) {
    
        self.tripName = tripName
        self.currentToll = currentToll
        self.currentMessage = currentMessage
        self.stateRoute = stateRoute
        self.travelDirection = travelDirection
        self.startLocationName = startLocationName
        self.endLocationName = endLocationName
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
    }
}

class I405TollRateSignItem {

    let startLocationName: String
    let stateRoute: Int
    let travelDirection: String
    let startLatitude: Double
    let startLongitude: Double
    var trips: [I405TripItem] = []

    init(startLocationName: String, stateRoute: Int, travelDirection: String, startLatitude: Double, startLongitude: Double) {


        self.startLocationName = startLocationName
        self.stateRoute = stateRoute
        self.travelDirection = travelDirection
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
    }
}

class I405TripItem {
    
    let tripName: String
    let endLocationName: String
    let toll: Float
    let message: String
    let endLatitude: Double
    let endLongitude: Double
    let updatedAt: Date

    init(tripName: String, endLocationName: String, currentToll: Float, currentMessage: String, endLatitude: Double, endLongitude: Double) {
        
        self.tripName = tripName
        self.endLocationName = endLocationName
        self.toll = currentToll
        self.message = currentMessage
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.updatedAt = Date()
    
    }
}
