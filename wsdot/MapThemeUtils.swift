
import UIKit
import GoogleMaps

class MapThemeUtils {
    
    static func setMapStyle(_ mapView: GMSMapView, _ traitCollection: UITraitCollection) {
        
        if (UserDefaults.standard.string(forKey: UserDefaultsKeys.mapStyle) == nil) {
            UserDefaults.standard.set("system", forKey: UserDefaultsKeys.mapStyle)
        }
        
        let mapStylePref = UserDefaults.standard.string(forKey: UserDefaultsKeys.mapStyle)
    
        if let mapStyle = mapStylePref {
            if (mapStyle == "system") {
                if #available(iOS 13, *){
                    if traitCollection.userInterfaceStyle == .dark {
                        setDarkStyle(mapView: mapView)
                    } else {
                        mapView.mapStyle = GMSMapStyle()
                    }
                } else {
                    mapView.mapStyle = GMSMapStyle()
                }
            
            } else if (mapStyle == "light"){
                mapView.mapStyle = GMSMapStyle()
            } else if (mapStyle == "dark"){
                setDarkStyle(mapView: mapView)
            }
        }
    }
    
    fileprivate static func setDarkStyle(mapView: GMSMapView) {
        do {
            if let styleURL = Bundle.main.url(forResource: "map_dark_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
}
