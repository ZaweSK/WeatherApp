//
//  GoogleRouter.swift
//  WeatherApp
//
//  Created by Peter on 07/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import Alamofire

enum GoogleRouter: URLRequestConvertible {
    
    case placeSearch(parameters: [String:String])
    case placeDetails(parameters: [String:String])
    case placePhotos(parameters: [String:String])
    
    private static let baseURLString = "https://maps.googleapis.com/maps/api/place"
    
    private var method: HTTPMethod {
        return .get
    }
    
    private var path: String {
        switch self {
        case .placeSearch :
            return "/findplacefromtext/json"
        case .placeDetails:
            return "/details/json"
        case .placePhotos:
            return "photo"
            
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        let url = try GoogleRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .placeSearch(let parameters) :
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .placeDetails(let parameters) :
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .placePhotos(let parameters) :
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
    
    
    
}
