//
//  FavoriteLocationRealmStore.swift
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
import RealmSwift

class FavoriteLocationStore{
    
    // Gets saved Favorite Items from Realm
    static func getTrafficMapFavorites() -> [FavoriteLocationItem]{
        let realm = try! Realm()
        let favoriteLocationItems = realm.objects(FavoriteLocationItem.self)
        return Array(favoriteLocationItems)
    }
    
    static func getVesselWatchFavorites() -> [VesselWatchFavoriteLocationItem]{
        let realm = try! Realm()
        let vesselWatchFavoriteLocationItem = realm.objects(VesselWatchFavoriteLocationItem.self)
        return Array(vesselWatchFavoriteLocationItem)
    }
    
    // Saves a favorite location, giving it a unique ID based on the current time
    static func saveFavorite(_ favorite: FavoriteLocationItem){
        
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
    
    static func saveVesselWatchFavorite(_ favorite: VesselWatchFavoriteLocationItem){
        
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
    
    
    static func updateName(_ location: FavoriteLocationItem, name: String){
        let realm = try! Realm()
        do {
            try realm.write{
                location.name = name
            }
        }catch{
            print("FavoriteLocationStore.saveFavorite: Realm write error")
        }
    }
  
    
    // Removes a favorite item from Realm
    static func deleteFavorite(_ favorite: FavoriteLocationItem){
        let realm = try! Realm()
        do {
            try realm.write{
                realm.delete(favorite)
            }
        }catch{
            print("FavoriteLocationStore.deleteFavorite: Realm write error")
        }
    }
    
    
    static func deleteVesselWatchFavorite(_ favorite: VesselWatchFavoriteLocationItem){
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
