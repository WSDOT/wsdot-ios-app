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
    
}

enum Theme: Int {

    case defaultTheme = 0, orangeTheme = 1, blueTheme = 2, customTheme = 3

    var mainColor: UIColor {
        switch self {
        case .defaultTheme:
            
            if #available(iOS 13, *) {
                return UIColor.init { (trait) -> UIColor in
                    return trait.userInterfaceStyle == .dark ? Colors.wsdotPrimaryDark : Colors.wsdotPrimary
                }
            }
        
            return Colors.wsdotPrimary
       
        case .orangeTheme:
            return Colors.wsdotOrange
        case .blueTheme:
            return Colors.wsdotBlue
        case .customTheme:
            return Colors.customColor
        }
    }

    //Customizing the Navigation Bar
    var barStyle: UIBarStyle {
        switch self {
        case .defaultTheme:
            return .default
        case .orangeTheme:
            return .default
        case .blueTheme:
            return .default
        case .customTheme:
            return .default
        }
    }

    var darkColor: UIColor {
        switch self {
        case .defaultTheme:
            return Colors.wsdotPrimary
        case .orangeTheme:
            return Colors.wsdotDarkOrange
        case .blueTheme:
            return Colors.wsdotPrimary
        case .customTheme:
            return Colors.wsdotPrimary
        }
    }
    

    var secondaryColor: UIColor {
        switch self {
        case .defaultTheme:
            return UIColor.white
        case .orangeTheme:
            return UIColor.white
        case .blueTheme:
            return UIColor.white
        case .customTheme:
            return UIColor.white
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .defaultTheme:
            return UIColor.white
        case .orangeTheme:
            return UIColor.white
        case .blueTheme:
            return UIColor.white
        case .customTheme:
            return UIColor.white
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
