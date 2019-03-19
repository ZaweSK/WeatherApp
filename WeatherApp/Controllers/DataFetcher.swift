//
//  DataFetcher.swift
//  WeatherApp
//
//  Created by Peter on 19/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON
import CoreLocation

enum JSONError: Error {
    case generalError
}

class DataFetcher {
    
    
    let APP_ID = "ceb75d42efb0a329e2d5d1d6819032b1"
    let URL = "http://api.openweathermap.org/data/2.5/weather"
    

    
    func getParams(for method: LocationMethod) -> [String:String]{
        
        switch method{
            
        case .city(let cityName):
            
            let params : [String:String] = [
                "q" : cityName,
                "appid" : APP_ID
            ]
            
            return params
            
        case .userLocation(let location):
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String:String] = [
                "lat" : latitude,
                "lon" : longitude,
                "appid" : APP_ID
            ]
            
            return params
        }
    }
    
    func fetchData(for method: LocationMethod)-> Promise<JSON> {

        return Promise { seal in
            
            let params = getParams(for: method)
            
            Alamofire.request(URL, method: .get, parameters: params).validate().responseJSON { response in
                
                switch response.result {
                    
                case .success(let json):
                    seal.fulfill(JSON(json))
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}


