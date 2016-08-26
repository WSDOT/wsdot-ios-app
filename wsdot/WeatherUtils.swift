//
//  WeatherUtils.swift
//  WSDOT
//
//  Created by Logan Sims on 8/25/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class WeatherUtils {
    
    // Returns the first sentance from input String
    static func getForecastBriefDescription(fullForecast: String) -> String {
        return fullForecast.characters.split(".").map(String.init)[0]
    }
    
    static private let clear = ("icClear", "icClearNight", ["fair", "sunny", "clear"])
    static private let fewClouds = ("icCloudy1", "icCloudyNight1", ["few clouds", "scattered clouds", "mostly sunny", "mostly clear"])
    static private let partlyCloudy = ("icCloudy2", "icCloudyNight2", ["partly cloudy", "partly sunny"])
    static private let cloudy = ("icCloudy3", "icCloudyNight3", ["cloudy"])
    static private let mostlyCloudy = ("icCloudy4", "icCloudyNight4", ["broken", "mostly cloudy"])
    static private let overcast = ("icOvercast", "icOvercast", ["overcast"])
    static private let sleet = ("icSleet", "icSleet", ["rain snow", "light rain snow", "heavy rain snow", "rain and snow"])
    static private let lightRain = ("icLightRain", "icLightRain", ["light rain", "showers"])
    static private let rain = ("icRain", "icRain", ["rain", "heavy rain", "raining"])
    static private let snow = ("icSnow", "icSnow", ["snow", "snowing", "light snow", "heavy snow"])
    static private let fog = ("icFog", "icFog", ["fog"])
    static private let hail = ("icHail", "icHail", ["ice pellets", "light ice pellets", "heavy ice pellets", "hail"])
    static private let thunderStorm = ("icThunderStorm", "icThunderStorm", ["thunderstorm", "thunderstorms"])
    
    static private let weather = [clear, fewClouds, partlyCloudy, cloudy, mostlyCloudy, overcast, sleet, lightRain, rain, snow, fog, hail, thunderStorm]
    
    static func getIconName(forecast: String) -> String {

        let shortForecast = WeatherUtils.getForecastBriefDescription(forecast)

        for weatherTriple in weather {
            if (weatherTriple.2.filter({(item: String) -> Bool in
                    return shortForecast.lowercaseString.hasPrefix(item.lowercaseString)}).count > 0){
                return isNight(shortForecast) ? weatherTriple.1 : weatherTriple.0
            }
        }
        return ""
    }
    
    static func isNight(shortForcast: String) -> Bool {
        do {
            let internalExpression: NSRegularExpression = try NSRegularExpression(pattern: "night|tonight", options: .CaseInsensitive)
            let matches = internalExpression.matchesInString(shortForcast, options: NSMatchingOptions.WithoutAnchoringBounds, range:NSMakeRange(0, shortForcast.characters.count))
            if matches.count == 0 {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
}