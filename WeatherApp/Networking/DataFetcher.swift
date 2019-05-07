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

enum ImageError : Error {
    case unableToCreateImage
}

enum GoogleWebServiceError:Error{
    case wrongURL
}
 

class DataFetcher {
    
    var googlePlacesSessionManager : SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.adapter = GooglePlacesAdapter()
        return sessionManager
    }()
    
    var openWeatherSessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.adapter = OpeanWeatherAdapter()
        return sessionManager
    }()
    
    
    private func getOpenWeatherMapParams(for method: LocationMethod) -> [String:String]{
        
        switch method{
            
        case .city(let cityName):
            
            let params : [String:String] = [
                "q" : cityName,
                "units" : "metric"
            ]
            
            return params
            
        case .userLocation(let location):
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String:String] = [
                "lat" : latitude,
                "lon" : longitude,
                 "units" : "metric"
            ]
            
            return params
        }
    }
    
    private func createURL(with urlString: String, _ params: [String:String])->URL{
        
        var urlComponents = URLComponents(string: urlString)!
        
        let queryItems = convertToQueryItems(dict: params)
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!
    }
    
    private func convertToQueryItems(dict: [String:String])->[URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        for (key,value) in dict {
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        return queryItems
    }
    
    //
    func fetchWeatherData(for method: LocationMethod)-> Promise<Data> {
        
        return Promise { seal in
            
            let params = getOpenWeatherMapParams(for: method)
            
            openWeatherSessionManager.request(WeatherRouter.weather(parameters: params)).validate().responseData() { response in
    
                switch response.result {
                    
                case .success(let data):
                    seal.fulfill(data)
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func fetchPlacePhotos(for reference: String)->Promise<UIImage>{
        
        return Promise { seal in
            
            let params = [
                "photoreference" : reference,
                "maxheight" : "800"
            ]
            
            googlePlacesSessionManager.request(GoogleRouter.placePhotos(parameters: params)).validate().responseData() { response in
                
                
                switch response.result {
                    
                case .success(let data):
                  
                    guard let image = UIImage(data: data) else {
                        seal.reject(ImageError.unableToCreateImage)
                        return
                    }
                    
                    seal.fulfill(image)
                    
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
            

        }
    }
    
    
    
    func fetchPlaceDetails(for id: String)->Promise<JSON>{
        
        return Promise { seal in
            
            let params = [
                "placeid" : id
            ]
        
            googlePlacesSessionManager.request(GoogleRouter.placeDetails(parameters: params)).validate().responseJSON{ response in
         
                switch response.result {
                    
                case .success(let json):
                    seal.fulfill(JSON(json))
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    func fetchPlaceId(for city: String)->Promise<JSON> {
        
        return Promise { seal in
            
            let params = [
                "inputtype" : "textquery",
                "input" : city
            ]
            
            googlePlacesSessionManager.request(GoogleRouter.placeSearch(parameters: params)).validate().responseJSON{ response in
                
                switch response.result {
                    
                case .success(let json):
                    seal.fulfill(JSON(json))
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    
    
    
    func getForecast(for method: LocationMethod)->Promise<Data>{
        return Promise { seal in
            
            let params = getOpenWeatherMapParams(for: method)
            
            openWeatherSessionManager.request(WeatherRouter.forecast(parameters: params)).validate().responseData() { response in
           
                print(response.request)
                switch response.result {
                    
                case .success(let data):
                    seal.fulfill(data)
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}


