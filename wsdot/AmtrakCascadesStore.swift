//
//  AmtrakCascadesStore.swift
//  WSDOT
//
//  Created by Logan Sims on 9/1/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation

class AmtrakCascadesStore {
    
    static func getStations() -> [AmtrakCascadesStationItem]{
        var stations = [AmtrakCascadesStationItem]()
        stations.append(AmtrakCascadesStationItem(id: "VAC", name: "Vancouver, BC", sortOrder: 0, lat: 49.2737293, lon: -123.0979175))
        stations.append(AmtrakCascadesStationItem(id: "BEL", name: "Bellingham, WA", sortOrder: 1, lat: 48.720423, lon: -122.5109386))
        stations.append(AmtrakCascadesStationItem(id: "MVW", name: "Mount Vernon, WA", sortOrder: 2, lat: 48.4185923, lon: -122.334973))
        stations.append(AmtrakCascadesStationItem(id: "STW", name: "Stanwood, WA", sortOrder: 3, lat: 48.2417732, lon: -122.3495322))
        stations.append(AmtrakCascadesStationItem(id: "EVR", name: "Everett, WA", sortOrder: 4, lat: 47.975512, lon: -122.197854))
        stations.append(AmtrakCascadesStationItem(id: "EDM", name: "Edmonds, WA", sortOrder: 5, lat: 47.8111305, lon: -122.3841639))
        stations.append(AmtrakCascadesStationItem(id: "SEA", name: "Seattle, WA", sortOrder: 6, lat: 47.6001899, lon: -122.3314322))
        stations.append(AmtrakCascadesStationItem(id: "TUK", name: "Tukwila, WA", sortOrder: 7, lat: 47.461079, lon: -122.242693))
        stations.append(AmtrakCascadesStationItem(id: "TAC", name: "Tacoma, WA", sortOrder: 8, lat: 47.2419939, lon: -122.4205623))
        stations.append(AmtrakCascadesStationItem(id: "OLW", name: "Olympia/Lacey, WA", sortOrder: 9, lat: 46.9913576, lon: -122.793982))
        stations.append(AmtrakCascadesStationItem(id: "CTL", name: "Centralia, WA", sortOrder: 10, lat: 46.7177596, lon: -122.9528291))
        stations.append(AmtrakCascadesStationItem(id: "KEL", name: "Kelso/Longview, WA", sortOrder: 11, lat: 46.1422504, lon: -122.9132438))
        stations.append(AmtrakCascadesStationItem(id: "VAN", name: "Vancouver, WA", sortOrder: 12, lat: 45.6294472, lon: -122.685568))
        stations.append(AmtrakCascadesStationItem(id: "PDX", name: "Portland, OR", sortOrder: 13, lat: 45.528639, lon: -122.676284))
        stations.append(AmtrakCascadesStationItem(id: "ORC", name: "Oregon City, OR", sortOrder: 14, lat: 45.3659422, lon: -122.5960671))
        stations.append(AmtrakCascadesStationItem(id: "SLM", name: "Salem, OR", sortOrder: 15, lat: 44.9323665, lon: -123.0281591))
        stations.append(AmtrakCascadesStationItem(id: "ALY", name: "Albany, OR", sortOrder: 16, lat: 44.6300975, lon: -123.1041787))
        stations.append(AmtrakCascadesStationItem(id: "EUG", name: "Eugene, OR", sortOrder: 17, lat: 44.055506, lon: -123.094523))
        return stations
    }
    
    static func getDestinationData() -> [String] {
        var dest = [String]()
        dest.append("Select your destination")
        dest.append("Vancouver, BC")
        dest.append("Bellingham, WA")
        dest.append("Mount Vernon, WA")
        dest.append("Stanwood, WA")
        dest.append("Everett, WA")
        dest.append("Edmonds, WA")
        dest.append("Seattle, WA")
        dest.append("Tukwila, WA")
        dest.append("Tacoma, WA")
        dest.append("Olympia/Lacey, WA")
        dest.append("Centralia, WA")
        dest.append("Kelso/Longview, WA")
        dest.append("Vancouver, WA")
        dest.append("Portland, OR")
        dest.append("Oregon City, OR")
        dest.append("Salem, OR")
        dest.append("Albany, OR")
        dest.append("Eugene, OR")
        return dest
    }
    
    static func getOriginData() -> [String]{
        var origins = [String]()
        origins.append("Vancouver, BC")
        origins.append("Bellingham, WA")
        origins.append("Mount Vernon, WA")
        origins.append("Stanwood, WA")
        origins.append("Everett, WA")
        origins.append("Edmonds, WA")
        origins.append("Seattle, WA")
        origins.append("Tukwila, WA")
        origins.append("Tacoma, WA")
        origins.append("Olympia/Lacey, WA")
        origins.append("Centralia, WA")
        origins.append("Kelso/Longview, WA")
        origins.append("Vancouver, WA")
        origins.append("Portland, OR")
        origins.append("Oregon City, OR")
        origins.append("Salem, OR")
        origins.append("Albany, OR")
        origins.append("Eugene, OR")
        return origins
    }
    
    static let stationIdsMap: Dictionary<String, String> = [
        "Select your destination": "N/A",
        "Vancouver, BC": "VAC",
        "Bellingham, WA": "BEL",
        "Mount Vernon, WA": "MVW",
        "Stanwood, WA": "STW",
        "Everett, WA": "EVR",
        "Edmonds, WA": "EDM",
        "Seattle, WA": "SEA",
        "Tukwila, WA": "TUK",
        "Tacoma, WA": "TAC",
        "Olympia/Lacey, WA": "OLW",
        "Centralia, WA": "CTL",
        "Kelso/Longview, WA": "KEL",
        "Vancouver, WA": "VAN",
        "Portland, OR": "PDX",
        "Oregon City, OR": "ORC",
        "Salem, OR": "SLM",
        "Albany, OR": "ALY",
        "Eugene, OR": "EUG"
    ]

}