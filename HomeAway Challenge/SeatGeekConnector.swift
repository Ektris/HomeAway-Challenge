//
//  SeatGeekConnector.swift
//  HomeAway Challenge
//
//  Created by Robert Carrier on 8/19/17.
//  Copyright © 2017 rwc. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class SeatGeekConnector {
    // Create singleton to use across app
    public static let shared = SeatGeekConnector()

    private init() {
    }
    
    // MARK: - Queries
    
    public func query(query: String, completion: @escaping ([Dictionary<String, Any>]) -> ()) {
        queryPage(query: query, page: 1, completion: completion)
    }
    
    public func queryPage(query: String, page: Int, completion: @escaping ([Dictionary<String, Any>]) -> ()) {
        let url = "https://api.seatgeek.com/2/events"
        let params: [String: Any] = ["client_id": QueryConstants.clientId,
                                     "q":query,
                                     "page":page]
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            if let json = response.result.value as? Dictionary<String, Any> {
                if let events = json["events"] as? [Dictionary<String, Any>] {
                    completion(events)
                }
            }
        }
    }
    
    // MARK: - Images
    
    public func loadImage(url: String, completion: @escaping (Image) -> ()) {
        Alamofire.request(url).responseImage { response in            
            if let image = response.result.value {
                completion(image)
            }
        }
    }
}
