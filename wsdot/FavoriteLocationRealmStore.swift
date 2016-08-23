//
//  FavoriteLocationRealmStore.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import RealmSwift

class FavoriteLocationStore{
    
    // Gets all saved Favorite Items from Realm
    static func getFavorites() -> [FavoriteLocationItem]{
        let realm = try! Realm()
        let favoriteLocationItems = realm.objects(FavoriteLocationItem.self)
        return Array(favoriteLocationItems)
    }
    
    // Saves a favorite location, giving it a unique ID based on the current time
    static func saveFavorite(favorite: FavoriteLocationItem){
        
        favorite.id = TimeUtils.currentTime
        
        let realm = try! Realm()
        do {
            try realm.write{
                realm.add(favorite)
            }
        }catch{
            print("FavoriteLocationStore.saveFavorite: Realm write error")
        }
    }
    
    // Removes a favorite item from Realm
    static func deleteFavorite(favorite: FavoriteLocationItem){
        let realm = try! Realm()
        do {
            try realm.write{
                realm.delete(favorite)
            }
        }catch{
            print("FavoriteLocationStore.deleteFavorite: Realm write error")
        }
    }
}