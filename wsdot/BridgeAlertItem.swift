//
//  BridgeAlertItem.swift
//  WSDOT
//

import RealmSwift

class BridgeAlertItem: Object {

    @objc dynamic var alertId: Int = 0
    @objc dynamic var bridge: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var duration: String = ""
    @objc dynamic var descText: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var milepost: Double = 0.0
    @objc dynamic var direction: String = ""
    @objc dynamic var roadName: String = ""
    @objc dynamic var priority: String = ""
    @objc dynamic var eventCategory: String = ""
    @objc dynamic var openingTime: Date? = nil
    @objc dynamic var localCacheDate = Date()
    @objc dynamic var delete = false

    override static func primaryKey() -> String? {
        return "alertId"
    }
}

