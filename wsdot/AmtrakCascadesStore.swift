//
//  AmtrakCascadesStore.swift
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
import Alamofire
import SwiftyJSON

class AmtrakCascadesStore {
    
    typealias FetchAmtrakSchedulesCompletion = (_ data: [[(AmtrakCascadesServiceStopItem,AmtrakCascadesServiceStopItem?)]]?, _ error: NSError?) -> ()
    
    static func getSchedule(_ date: Date, originId: String, destId: String, completion: @escaping FetchAmtrakSchedulesCompletion) {
        
        let URL = "http://www.wsdot.wa.gov/traffic/api/amtrak/Schedulerest.svc/GetScheduleAsJson?AccessCode=" + ApiKeys.wsdot_key + "&StatusDate="
            + TimeUtils.formatTime(date, format: "MM/dd/yyyy") + "&TrainNumber=-1&FromLocation=" + originId + "&ToLocation=" + destId
        
        Alamofire.request(.GET, URL).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let serviceArrays = parseServiceItemsJSON(json)
                    let servicePairs = getServiceStopPairs(serviceArrays)
                    completion(data: servicePairs, error: nil)
                }
            case .Failure(let error):
                print(error)
                completion(data: nil, error: error)
            }
        }
    }
    
    fileprivate static func parseServiceItemsJSON(_ json: JSON) -> [[AmtrakCascadesServiceStopItem]] {
        var tripItems = [[AmtrakCascadesServiceStopItem]]()
    
        var currentTripNum = -1 // current trip number - not the same as trip index b/c trips don't have to start at 0 or 1
        var currentTripIndex = -1 // index into tripItems
    
        for (_, stationJson):(String, JSON) in json {
        
            if (currentTripNum != stationJson["TripNumber"].intValue) {
                tripItems.append([AmtrakCascadesServiceStopItem]())
                currentTripNum = stationJson["TripNumber"].intValue
                currentTripIndex = currentTripIndex + 1
            }
    
            let service = AmtrakCascadesServiceStopItem()

            service.stationId = stationJson["StationName"].stringValue
            service.stationName = stationJson["StationFullName"].stringValue
            
            service.trainNumber = stationJson["TrainNumber"].intValue
    
            service.tripNumer = stationJson["TripNumber"].intValue
            service.sortOrder = stationJson["SortOrder"].intValue

            service.arrivalComment = stationJson["ArrivalComment"].string
            service.departureComment = stationJson["DepartureComment"].string

            if let scheduledDepartureTime = stationJson["ScheduledDepartureTime"].string {
                service.scheduledDepartureTime = TimeUtils.parseJSONDateToNSDate(scheduledDepartureTime)
            }

            if let scheduledArrivalTime = stationJson["ScheduledArrivalTime"].string {
                service.scheduledArrivalTime = TimeUtils.parseJSONDateToNSDate(scheduledArrivalTime)
            }

            if service.scheduledDepartureTime == nil {
                service.scheduledDepartureTime = service.scheduledArrivalTime
            }
            
            if service.scheduledArrivalTime == nil {
                service.scheduledArrivalTime = service.scheduledDepartureTime
            }

            if let arrivComments = stationJson["ArrivalComment"].string {
                if (arrivComments.lowercaseString.containsString("late")){
                    let mins = TimeUtils.getMinsFromString(arrivComments)
                    service.arrivalComment = "Estimated " + arrivComments.lowercaseString + " at " + TimeUtils.getTimeOfDay(service.scheduledArrivalTime!.dateByAddingTimeInterval(mins * 60))
                } else if (arrivComments.lowercaseString.containsString("early")){
                    let mins = TimeUtils.getMinsFromString(arrivComments)
                    service.arrivalComment = "Estimated " + arrivComments.lowercaseString + " at " + TimeUtils.getTimeOfDay(service.scheduledArrivalTime!.dateByAddingTimeInterval(mins * -60))
                } else {
                    service.arrivalComment = "Estimated " + arrivComments.lowercaseString
                }
            } else {
                service.arrivalComment = ""
            }
            
            
            if let departComments = stationJson["ArrivalComment"].string {
                if (departComments.lowercaseString.containsString("late")){
                    let mins = TimeUtils.getMinsFromString(departComments)
                    service.departureComment = "Estimated " + departComments.lowercaseString + " at " + TimeUtils.getTimeOfDay(service.scheduledDepartureTime!.dateByAddingTimeInterval(mins * 60))
                } else if (departComments.lowercaseString.containsString("early")){
                    let mins = TimeUtils.getMinsFromString(departComments)
                    service.departureComment = "Estimated " + departComments.lowercaseString + " at " + TimeUtils.getTimeOfDay(service.scheduledDepartureTime!.dateByAddingTimeInterval(mins * -60))
                } else {
                    service.departureComment = "Estimated " + departComments.lowercaseString
                }
            } else {
                service.departureComment = ""
            }


            service.updated = TimeUtils.parseJSONDateToNSDate(stationJson["UpdateTime"].stringValue)

            tripItems[currentTripIndex].append(service)

        }
        return tripItems
    }
    
    
    // Creates origin-destination pairs from parsed JSON items of type [[AmtrakCascadesServiceStopItem]]
    // !!! Special case to consider is when the destination is not selected. In this case the pairs will have the destination value nil.
    static func getServiceStopPairs(_ servicesArrays: [[AmtrakCascadesServiceStopItem]]) -> [[(AmtrakCascadesServiceStopItem,AmtrakCascadesServiceStopItem?)]]{
    
        var servicePairs = [[(AmtrakCascadesServiceStopItem,AmtrakCascadesServiceStopItem?)]]()
        var pairIndex = 0
        
        for services in servicesArrays {
            
            servicePairs.append([(AmtrakCascadesServiceStopItem,AmtrakCascadesServiceStopItem?)]())
            
            var serviceIndex = 0 // index in services loop
            
            for service in services {
                
                if (services.endIndex - 1 <= serviceIndex) && (services.count == 1) { // last item and there was only one service, add a nil
                    servicePairs[pairIndex].append((service, nil))
                } else if (serviceIndex + 1 <= services.endIndex - 1){ // Middle Item
                    if service.stationId != services[serviceIndex + 1].stationId { // Stations will be listed twice when there is a transfer, don't add them twice
                        servicePairs[pairIndex].append((service, services[serviceIndex + 1]))
                    }
                }
                
                serviceIndex = serviceIndex + 1
            }
            pairIndex = pairIndex + 1
        }
        
        return servicePairs
    }
    
    // Builds an array of Station data for using in calculating the users distance from the station.
    static func getStations() -> [AmtrakCascadesStationItem]{
        var stations = [AmtrakCascadesStationItem]()
        stations.append(AmtrakCascadesStationItem(id: "VAC", name: "Vancouver, BC", lat: 49.2737293, lon: -123.0979175))
        stations.append(AmtrakCascadesStationItem(id: "BEL", name: "Bellingham, WA", lat: 48.720423, lon: -122.5109386))
        stations.append(AmtrakCascadesStationItem(id: "MVW", name: "Mount Vernon, WA", lat: 48.4185923, lon: -122.334973))
        stations.append(AmtrakCascadesStationItem(id: "STW", name: "Stanwood, WA", lat: 48.2417732, lon: -122.3495322))
        stations.append(AmtrakCascadesStationItem(id: "EVR", name: "Everett, WA", lat: 47.975512, lon: -122.197854))
        stations.append(AmtrakCascadesStationItem(id: "EDM", name: "Edmonds, WA", lat: 47.8111305, lon: -122.3841639))
        stations.append(AmtrakCascadesStationItem(id: "SEA", name: "Seattle, WA", lat: 47.6001899, lon: -122.3314322))
        stations.append(AmtrakCascadesStationItem(id: "TUK", name: "Tukwila, WA", lat: 47.461079, lon: -122.242693))
        stations.append(AmtrakCascadesStationItem(id: "TAC", name: "Tacoma, WA", lat: 47.2419939, lon: -122.4205623))
        stations.append(AmtrakCascadesStationItem(id: "OLW", name: "Olympia/Lacey, WA", lat: 46.9913576, lon: -122.793982))
        stations.append(AmtrakCascadesStationItem(id: "CTL", name: "Centralia, WA", lat: 46.7177596, lon: -122.9528291))
        stations.append(AmtrakCascadesStationItem(id: "KEL", name: "Kelso/Longview, WA", lat: 46.1422504, lon: -122.9132438))
        stations.append(AmtrakCascadesStationItem(id: "VAN", name: "Vancouver, WA", lat: 45.6294472, lon: -122.685568))
        stations.append(AmtrakCascadesStationItem(id: "PDX", name: "Portland, OR", lat: 45.528639, lon: -122.676284))
        stations.append(AmtrakCascadesStationItem(id: "ORC", name: "Oregon City, OR", lat: 45.3659422, lon: -122.5960671))
        stations.append(AmtrakCascadesStationItem(id: "SLM", name: "Salem, OR", lat: 44.9323665, lon: -123.0281591))
        stations.append(AmtrakCascadesStationItem(id: "ALY", name: "Albany, OR", lat: 44.6300975, lon: -123.1041787))
        stations.append(AmtrakCascadesStationItem(id: "EUG", name: "Eugene, OR", lat: 44.055506, lon: -123.094523))
        return stations.sorted(by: {$0.name > $1.name})
    }
    
    // Used to populate the destination selection
    static func getDestinationData() -> [String] {
        var dest = [String]()
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
        dest.sort()
        dest.insert("All", at: 0)
        return dest
    }
    
    // Used to populate the origin selection
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
        return origins.sorted()
    }
    
    // Station names to ID mapping.
    static let stationIdsMap: Dictionary<String, String> = [
        "All": "N/A",
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
    
    static let trainNumberMap: Dictionary<Int, String> = [
        7: "Empire Builder Train",
        8: "Empire Builder Train",
        11: "Coast Starlight Train",
        14: "Coast Starlight Train",
        27: "Empire Builder Train",
        28: "Empire Builder Train",
        500: "Amtrak Cascades Train",
        501: "Amtrak Cascades Train",
        502: "Amtrak Cascades Train",
        503: "Amtrak Cascades Train",
        504: "Amtrak Cascades Train",
        505: "Amtrak Cascades Train",
        506: "Amtrak Cascades Train",
        507: "Amtrak Cascades Train",
        508: "Amtrak Cascades Train",
        509: "Amtrak Cascades Train",
        510: "Amtrak Cascades Train",
        511: "Amtrak Cascades Train",
        513: "Amtrak Cascades Train",
        516: "Amtrak Cascades Train",
        517: "Amtrak Cascades Train"
    ]

}
