//
//  APIManager.swift
//  BVGHackaton2018
//
//  Created by Daniel Montano on 19.08.18.
//  Copyright © 2018 Daniel Montano. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// The API Manager basically takes care of the interaction between
/// APP and API. It has different asynchronous methods that do specific
/// Tasks.
class APIManager {
    
    //////////////////////////////////////////////////////////////////////////////
    /////////////           Singleton Class Implementation           /////////////
    //////////////////////////////////////////////////////////////////////////////
    
    static let sharedInstance = APIManager()
    
    private init(){}
    
    func sendCoords(latitude: Double, longitude: Double, callback: @escaping (Error?) -> Void){
        
        jsonRequest(urlStr: "https://bvg-indoor-maps.appspot.com/post?lat=\(latitude)&long=\(longitude)", httpMethod: "GET", parameters: nil, completion: { json, error in
            
            if let err = error {
                callback(err)
            }
        })
    }
    
    /// Use this method to make a http request where the response should be a json file
    ///
    /// - Parameters:
    ///   - urlStr: The url where to get the JSON from
    ///   - callback: The callback method that will be called after the http request has been made.
    func jsonRequest(urlStr: String, httpMethod: String, parameters: Parameters?, completion: @escaping (JSON?, Error?) -> Void){
        
        guard let url = URL(string: urlStr) else {
            // Return error for not being able to create url instance
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        // Only add params if they are defined
        if let params = parameters {
            let pyload = try! JSONSerialization.data(withJSONObject: params);
            request.httpBody = pyload
        }
        
        Alamofire.request(request)
            .responseJSON { (dataResponse:DataResponse) in
                
                switch (dataResponse.result) {
                    
                case .success(let data):
                    
                    guard let httpResponse = dataResponse.response else {
                        
                        return
                    }
                    
                    if(httpResponse.statusCode == 200){
                        let json = JSON(data)
                        completion(json, nil)
                    }
                    
                    break
                case .failure(let error):
                    break
                }
        }
    }

}
