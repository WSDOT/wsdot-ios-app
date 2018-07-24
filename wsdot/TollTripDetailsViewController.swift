//
//  TollTripDetailsViewController.swift
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

import Foundation

class TollTripDetailsViewController: UIViewController {

    var text = ""
    
    var startLatitude = 0.0
    var startLongitude = 0.0
    
    var endLatitude = 0.0
    var endLongitude = 0.0

    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var infoLinkLabel: INDLinkLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.screenView(screenName: "/Toll Rates/Toll Trip Details")
        
        let htmlStyleString = "<style>body{font-family: '\(infoLinkLabel.font.fontName)'; font-size:\(infoLinkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + "Travel as far as " + text
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        infoLinkLabel.attributedText = attrStr
        displayMap()
        
    }
    
    func displayMap() {

        let center = LatLonUtils.getCenterLocation(startLatitude, startLongitude, endLatitude, endLongitude)

        let distanceInMiles = Double(LatLonUtils.haversine(startLatitude, lonA: startLongitude, latB: endLatitude, lonB: endLongitude)) * 0.000189394
        var zoom = 0
        
        switch distanceInMiles {
        case ..<4:
            zoom = 12
        case 4..<8:
            zoom = 11
        case 8..<15:
            zoom = 10
        case 15...:
            zoom = 9
        default:
            fatalError()
        }

        let staticMapUrl = "http://maps.googleapis.com/maps/api/staticmap?center="
            + String(center.latitude) + "," + String(center.longitude)
            + "&zoom=" + String(zoom) + "&size=320x320&maptype=roadmap"
            + "&markers=color:green%7Clabel:S%7C"
            + String(self.startLatitude) + "," + String(self.startLongitude)
            + "&markers=color:red%7Clabel:E%7C"
            + String(self.endLatitude) + "," + String(self.endLongitude)
            + "&key=" + ApiKeys.getGoogleAPIKey()
        
        mapImageView.sd_setImage(with: URL(string: staticMapUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached)
    
    }
}
