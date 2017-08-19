//
//  SeatGeekConnector.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/19/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import Foundation

class SeatGeekConnector {
    // Create singleton to persist across app
    public static let shared = SeatGeekConnector()
    
    private static let clientId = "ODU2ODIwMXwxNTAzMTE3NTgwLjgy"
    
    private init() {
    }
    
    // MARK: - Quries
    
    public func query(query: String) {
        
    }
}
