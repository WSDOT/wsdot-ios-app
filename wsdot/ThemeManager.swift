//
//  File.swift
//  WSDOT
//
//  Created by Logan Sims on 2/2/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import Foundation


struct Colors {
    
    static let wsdotPrimary = UIColor.init(red: 0.0/255.0, green: 123.0/255.0, blue: 95.0/255.0, alpha: 1)
    static let wsdotPrimaryDark = UIColor.init(red: 0.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
    static let wsdotOrange = UIColor.init(red: 255.0/255.0, green: 108.0/255.0, blue: 12.0/255.0, alpha: 1)
    static let wsdotDarkOrange = UIColor.init(red: 196.0/255.0, green: 59.0/255.0, blue: 0.0/255.0, alpha: 1)
    
    static let wsdotBlue = UIColor.init(red: 0.0/255.0, green: 123.0/255.0, blue: 154.0/255.0, alpha: 1)
    
    
    static let customColor = UIColor.init(red: 0.0/255.0, green: 63.0/255.0, blue: 135.0/255.0, alpha: 1)
    
    static let tintColor = UIColor.init(red: 0.0/255.0, green: 174.0/255.0, blue: 65.0/255.0, alpha: 1)
    static let yellow = UIColor.init(red: 255.0/255.0, green: 235.0/255.0, blue: 59.0/255.0, alpha: 1)
    static let lightGreen = UIColor.init(red: 204.0/255.0, green: 239.0/255.0, blue: 184.0/255.0, alpha: 1)
    static let lightGrey = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
    static let paleGrey = UIColor.init(red: 209.0/255.0, green: 213.0/255.0, blue: 219.0/255.0, alpha: 1)
        
    // Utility Colors
    static let wsdotGray100 = UIColor.init(red: 29.0/255.0, green: 37.0/255.0, blue: 45.0/255.0, alpha: 1)
    static let wsdotGray80 = UIColor.init(red: 74.0/255.0, green: 81.0/255.0, blue: 87.0/255.0, alpha: 1)
    static let wsdotGray60 = UIColor.init(red: 119.0/255.0, green: 124.0/255.0, blue: 129.0/255.0, alpha: 1)
    static let wsdotGray40 = UIColor.init(red: 165.0/255.0, green: 168.0/255.0, blue: 171.0/255.0, alpha: 1)
    static let wsdotGray20 = UIColor.init(red: 210.0/255.0, green: 211.0/255.0, blue: 213.0/255.0, alpha: 1)
    static let wsdotGray10 = UIColor.init(red: 232.0/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1)
    static let wsdotGray5 = UIColor.init(red: 244.0/255.0, green: 244.0/255.0, blue: 255.0/255.0, alpha: 1)
    static let wsdotWhite = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
    static let wsdotGreen = UIColor.init(red: 40.0/255.0, green: 167.0/255.0, blue: 69.0/255.0, alpha: 1)
    static let wsdotRed = UIColor.init(red: 220.0/255.0, green: 53.0/255.0, blue: 69.0/255.0, alpha: 1)
    static let wsdotYellow = UIColor.init(red: 255.0/255.0, green: 193.0/255.0, blue: 7.0/255.0, alpha: 1)
    static let wsdotPurple = UIColor.init(red: 89.0/255.0, green: 49.0/255.0, blue: 95.0/255.0, alpha: 1)
    
    // Brand-Primary
    static let wsdotPrimaryBrand100 = UIColor.init(red: 0.0/255.0, green: 123.0/255.0, blue: 95.0/255.0, alpha: 1)
    static let wsdotPrimaryBrand80 = UIColor.init(red: 51.0/255.0, green: 149.0/255.0, blue: 127.0/255.0, alpha: 1)
    static let wsdotPrimaryBrand60 = UIColor.init(red: 102.0/255.0, green: 176.0/255.0, blue: 159.0/255.0, alpha: 1)
    static let wsdotPrimaryBrand40 = UIColor.init(red: 153.0/255.0, green: 202.0/255.0, blue: 191.0/255.0, alpha: 1)
    
    // Brand-Secondary
    static let wsdotLightAccent100 = UIColor.init(red: 151.0/255.0, green: 215.0/255.0, blue: 0.0/255.0, alpha: 1)
    static let wsdotLightAccentSoftened = UIColor.init(red: 173.0/255.0, green: 200.0/255.0, blue: 109.0/255.0, alpha: 1)
    static let wsdotDarkAccent100  = UIColor.init(red: 0.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)

    // Sub-Brand
    static let wsdotPMS519100  = UIColor.init(red: 89.0/255.0, green: 49.0/255.0, blue: 95.0/255.0, alpha: 1)
    static let wsdotPMS1585100  = UIColor.init(red: 255.0/255.0, green: 106.0/255.0, blue: 19.0/255.0, alpha: 1)
    static let wsdotPMS3125100  = UIColor.init(red: 0.0/255.0, green: 174.0/255.0, blue: 199.0/255.0, alpha: 1)
    static let wsdotPMS314100  = UIColor.init(red: 0.0/255.0, green: 127.0/255.0, blue: 163.0/255.0, alpha: 1)

}

enum Theme: Int {

    case defaultTheme = 0, orangeTheme = 1, emergencyTheme = 2

    var mainColor: UIColor {
        switch self {
        case .defaultTheme:
            
            if #available(iOS 13, *) {
                
                // Update Navigation Bar for iOS 15
                let appearance = UINavigationBarAppearance()
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.backgroundColor = Colors.wsdotPrimary
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                
                return UIColor.init { (trait) -> UIColor in
                    return trait.userInterfaceStyle == .dark ? Colors.wsdotPrimaryDark : Colors.wsdotPrimary
                }
            }
        
            return Colors.wsdotPrimary
       
        case .orangeTheme:
            
            if #available(iOS 13, *) {
                
                // Update Navigation Bar for iOS 15
                let appearance = UINavigationBarAppearance()
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.backgroundColor = Colors.wsdotOrange
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                
                return UIColor.init { (trait) -> UIColor in
                    return trait.userInterfaceStyle == .dark ? Colors.wsdotDarkOrange : Colors.wsdotOrange
                }
            }
            
            
            return Colors.wsdotOrange
            
     
            
        case .emergencyTheme:
            
            if #available(iOS 13, *) {
                
                // Update Navigation Bar for iOS 15
                let appearance = UINavigationBarAppearance()
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.backgroundColor = Colors.wsdotPrimary
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                
                return UIColor.init { (trait) -> UIColor in
                    return trait.userInterfaceStyle == .dark ? Colors.wsdotPrimaryDark : Colors.wsdotPrimary
                }
            }
        
            return Colors.wsdotPrimary
        }
    }

    //Customizing the Navigation Bar
    var barStyle: UIBarStyle {
        switch self {
        case .defaultTheme:
            return .default
        case .orangeTheme:
            return .default
        case .emergencyTheme:
            return .default
        }
    }

    var darkColor: UIColor {
        switch self {
        case .defaultTheme:
            return Colors.wsdotPrimary
        case .orangeTheme:
            return Colors.wsdotDarkOrange
        case .emergencyTheme:
            return Colors.wsdotPrimary
        }
    }
    

    var secondaryColor: UIColor {
        switch self {
        case .defaultTheme:
            return UIColor.white
        case .orangeTheme:
            return UIColor.white
        case .emergencyTheme:
            return UIColor.white
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .defaultTheme:
            return UIColor.white
        case .orangeTheme:
            return UIColor.white
        case .emergencyTheme:
            return UIColor.white
        }
    }
    
    var bannerTextColor: UIColor {
        switch self {
        case .defaultTheme:
            return Colors.wsdotPrimary
        case .orangeTheme:
            return Colors.wsdotDarkOrange
        case .emergencyTheme:
            return Colors.wsdotRed
        }
    }
    
    
}

// Enum declaration
let SelectedThemeKey = "SelectedTheme"

// This will let you use a theme in the app.
class ThemeManager {

    // ThemeManager
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .defaultTheme
        }
    }

    static func applyTheme(theme: Theme) {

        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()

        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor

        UIToolbar.appearance().tintColor = theme.darkColor
        UITabBar.appearance().tintColor = theme.darkColor
        
        UIProgressView.appearance().tintColor = theme.mainColor
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        UIPageControl.appearance().currentPageIndicatorTintColor = theme.mainColor
        
        UINavigationBar.appearance().barStyle = theme.barStyle

        UINavigationBar.appearance().barTintColor = theme.mainColor
        UINavigationBar.appearance().tintColor = theme.secondaryColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : theme.titleTextColor]

        UIPopoverBackgroundView.appearance().tintColor = theme.mainColor
        
        UITabBar.appearance().barStyle = theme.barStyle

        UISwitch.appearance().onTintColor = theme.mainColor.withAlphaComponent(0.8)
        
        
        UISegmentedControl.appearance().tintColor = theme.mainColor
        
    }
}
