//
//  Router.swift
//  WeatherApp
//
//  Created by Peter on 07/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import Alamofire

enum WeatherRouter: URLRequestConvertible {
    
    case forecast(parameters: [String:String])
    case weather(parameters: [String: String])
    
    private static let baseURLString = "http://api.openweathermap.org/data/2.5"
    
    private var method: HTTPMethod {
        return .get
    }
    
    private var path: String {
        switch self {
        case .forecast:
            return "/forecast"
        case .weather :
            return "/weather"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try WeatherRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .forecast(let parameters) :
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .weather(let parameters) :
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
    
    
}
