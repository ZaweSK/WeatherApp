//
//  Adapter.swift
//  WeatherApp
//
//  Created by Peter on 07/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import Alamofire

class OpeanWeatherAdapter: RequestAdapter {
    
    private let APP_ID = "ceb75d42efb0a329e2d5d1d6819032b1"
    

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        guard let url = urlRequest.url else {return urlRequest}
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false )
        
        let appIDQueryItem = URLQueryItem(name: "appid", value: APP_ID)
        
        components?.queryItems?.append(appIDQueryItem)
        
        guard let adaptedURL = components?.url else {
            return urlRequest
        }
        return URLRequest(url: adaptedURL)
    }
}


class GooglePlacesAdapter: RequestAdapter {
    
    private let APP_ID = "AIzaSyBKzijQZxg3vj9JSOolHfy8RmTwq5O7m14"
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        
        guard let url = urlRequest.url else {return urlRequest}
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false )
        
        let appIDQueryItem = URLQueryItem(name: "key", value: APP_ID)
        
        components?.queryItems?.append(appIDQueryItem)
        
        guard let adaptedURL = components?.url else {
            return urlRequest
        }
        
        return URLRequest(url: adaptedURL)
    }
}
