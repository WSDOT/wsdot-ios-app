//
//  UserDefaultsKeys.swift
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
class UserDefaultsKeys {
    
    static let cameras = "CameraMarkerPref"
    static let alerts = "AlertsMarkerPref"
    static let restAreas = "RestAreaMarkerPref"
    static let jblmCallout = "JBLMMarkerPref"
    
    static let favoritesOrder = "FavoritesSectionOrderArrayv1"
    
    static let mapLat = "MapLatitudeBound"
    static let mapLon = "MapLongitudeBound"
    static let mapZoom = "MapZoom"
    
    static let hasSeenWarning = "HasSeenWarning"
    
    static let shouldCluster = "shouldClusterCameraIcons"
    
    // EasyTipView Keys
    static let hasSeenClusterTipView = "hasSeenClusterTipView"
    static let hasSeenTravelerInfoTipView = "hasSeenTravelerInfoTipView"
    static let hasSeenMyRouteTipView = "hasSeenMyRouteTipView"
    static let hasSeenCameraSwipeTipView = "hasSeenCameraSwipeTipView"
    static let hasSeenNotificationsTipView = "hasSeenNotificationsTipView"
    
    // Push Notifications
    static let pushNotificationTopicVersion = "pushNotificationTopicVersion"
    static let pushNotificationsTopicDescription = "pushNotificationsTopicDescription"

}
