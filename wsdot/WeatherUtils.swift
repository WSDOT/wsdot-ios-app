//
//  WeatherUtils.swift
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
import UIKit

class WeatherUtils {
    
    // Returns the first sentance from input String
    static func getForecastBriefDescription(_ fullForecast: String) -> String {
        if (fullForecast != ""){
            return fullForecast.split(separator: ".").map(String.init)[0]
        } else {
            return ""
        }
    }
    
    static fileprivate let clear = ("icClear", "icClearNight", ["fair", "sunny", "clear"])
    static fileprivate let fewClouds = ("icCloudy1", "icCloudyNight1", ["few clouds", "scattered clouds", "mostly sunny", "mostly clear"])
    static fileprivate let partlyCloudy = ("icCloudy2", "icCloudyNight2", ["partly cloudy", "partly sunny"])
    static fileprivate let cloudy = ("icCloudy3", "icCloudyNight3", ["cloudy", "increasing clouds"])
    static fileprivate let mostlyCloudy = ("icCloudy4", "icCloudyNight4", ["broken", "mostly cloudy"])
    static fileprivate let overcast = ("icOvercast", "icOvercast", ["overcast"])
    static fileprivate let sleet = ("icSleet", "icSleet", ["rain snow", "light rain snow", "heavy rain snow", "rain and snow"])
    static fileprivate let lightRain = ("icLightRain", "icLightRain", ["light rain", "showers", "scattered rain"])
    static fileprivate let rain = ("icRain", "icRain", ["rain", "heavy rain", "raining"])
    static fileprivate let snow = ("icSnow", "icSnow", ["snow", "snowing", "light snow", "heavy snow"])
    static fileprivate let fog = ("icFog", "icFog", ["fog"])
    static fileprivate let hail = ("icHail", "icHail", ["ice pellets", "light ice pellets", "heavy ice pellets", "hail"])
    static fileprivate let thunderStorm = ("icThunderStorm", "icThunderStorm", ["thunderstorm", "thunderstorms"])
    
    static fileprivate let weather = [clear, fewClouds, partlyCloudy, cloudy, mostlyCloudy, overcast, sleet, lightRain, rain, snow, fog, hail, thunderStorm]
    
    static func getIconName(_ forecast: String, title: String) -> String {
        
        let shortForecast = WeatherUtils.getForecastBriefDescription(forecast)
        
        for weatherTriple in weather {
            if (weatherTriple.2.filter({(item: String) -> Bool in return shortForecast.lowercased().contains(item.lowercased())}).count > 0){
                return isNight(title) ? weatherTriple.1 : weatherTriple.0
            }
        }
        return ""
    }
    
    static func isNight(_ title: String) -> Bool {
        do {
            let internalExpression: NSRegularExpression = try NSRegularExpression(pattern: "night|tonight", options: .caseInsensitive)
            let matches = internalExpression.matches(in: title, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range:NSMakeRange(0, title.count))
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
