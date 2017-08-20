//
//  Favorites.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/19/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import Foundation

public class Favorites {
    // As all we need to persist is a simple array, saving to user defaults should be sufficient
    private static var favorites: [Int]? {
        set (ids) {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(ids, forKey: "favorites")
            userDefaults.synchronize()
        }
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.array(forKey: "favorites") as? [Int]
        }
    }
    
    // Add a new id to the persisted list
    static func save(id: Int) {
        if var ids = favorites {
            ids.append(id)
            favorites = ids
        }
    }
    
    // Remove an id from the persisted list
    static func remove(id: Int) {
        if var ids = favorites, let index = ids.index(of: id) {
            ids.remove(at: index)
            favorites = ids
        }
    }
    
    // Check if an id is on the persisted list
    static func check(id: Int) -> Bool {
        if let ids = favorites, ids.contains(id) {
            return true
        }
        
        return false
    }
}
