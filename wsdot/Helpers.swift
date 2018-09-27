//
//  Consts.swift
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


struct AlertMessages {

    static func getConnectionAlert() ->  UIAlertController{
        let alert = UIAlertController(title: "Connection Error", message: "Please check your connection", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = Colors.tintColor
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    static func getMailAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Cannot Compose Message", message: "Please add a mail account", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = Colors.tintColor
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    static func getAlert(_ title: String, message: String, confirm: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = Colors.tintColor
        alert.addAction(UIAlertAction(title: confirm, style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    static func getSingleActionAlert(_ title: String, message: String, confirm: String, comfirmHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = Colors.tintColor
        alert.addAction(UIAlertAction(title: confirm, style: UIAlertAction.Style.default, handler: comfirmHandler))
        return alert
    }
    
    static func getAcessDeniedAlert(_ title: String, message: String) -> UIAlertController {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { (alertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        return alert
    }
 }

struct Utils {
    
    static let maxClusterOpenZoom: Float = 16.0
    
    static func textToImage(_ drawText: NSString, inImage: UIImage, fontSize: CGFloat) -> UIImage{
        
        // Setup the font specific variables
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: fontSize)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]

        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        let atPoint = CGPoint(x: 0, y: (inImage.size.height-fontSize)/2.0)
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
    }
}

struct UIHelpers {

    
    static func getAlertIcon(forAlert: HighwayAlertItem) -> UIImage? {
    
        let alertHighIconImage = UIImage(named: "icMapAlertHigh")
        let alertHighestIconImage = UIImage(named: "icMapAlertHighest")
        let alertModerateIconImage = UIImage(named: "icMapAlertModerate")
        let alertLowIconImage = UIImage(named: "icMapAlertLow")
    
        let constructionHighIconImage = UIImage(named: "icMapConstructionHigh")
        let constructionHighestIconImage = UIImage(named: "icMapConstructionHighest")
        let constructionModerateIconImage = UIImage(named: "icMapConstructionModerate")
        let constructionLowIconImage = UIImage(named: "icMapConstructionLow")
    
        let closedIconImage = UIImage(named: "icMapClosed")
    
        if forAlert.headlineDesc.lowercased().contains("construction")
                    || forAlert.eventCategory.lowercased().contains("maintenance")
                    || forAlert.eventCategory.lowercased().contains("construction"){
            switch forAlert.priority {
                case "Lowest":
                    return constructionLowIconImage
                case "Low":
                    return constructionLowIconImage
                case "Moderate":
                    return constructionModerateIconImage
                case "High":
                    return constructionHighIconImage
                case "Highest":
                    return constructionHighestIconImage
                default:
                    return constructionModerateIconImage
            }

        } else if forAlert.headlineDesc.lowercased().contains("road closure") || forAlert.eventCategory.lowercased().contains("closure"){
            return closedIconImage
        } else {
            switch forAlert.priority {
                case "Lowest":
                    return alertLowIconImage
                case "Low":
                    return alertLowIconImage
                case "Moderate":
                    return alertModerateIconImage
                case "High":
                    return alertHighIconImage
                case "Highest":
                    return alertHighestIconImage
                default:
                    return alertModerateIconImage
            }
        }
    }
    

    static func getAlertLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 10, y: -10, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont(name: "SanFranciscoText-Light", size: 13)
        label.textColor = .white
        label.backgroundColor = .red
        label.text = "!"
        return label
    }
    
    static func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        return activityIndicator
    }

}

