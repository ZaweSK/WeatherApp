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

enum GoogleWebServiceError:Error{
    case wrongURL
}

enum GoogleWebService: String {
    case placeSearch = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
    case placeDetails = "https://maps.googleapis.com/maps/api/place/details/json?"
    case placePhotos = "https://maps.googleapis.com/maps/api/place/photo?"
}

class DataFetcher {
    
    
    let openWeatherMap_APP_ID = "ceb75d42efb0a329e2d5d1d6819032b1"
    let openWeatherMapURL = "http://api.openweathermap.org/data/2.5/weather"
    let googleWebService_APP_ID = "AIzaSyBKzijQZxg3vj9JSOolHfy8RmTwq5O7m14"
    
    
    private func getOpenWeatherMapParams(for method: LocationMethod) -> [String:String]{
        
        switch method{
            
        case .city(let cityName):
            
            let params : [String:String] = [
                "q" : cityName,
                "appid" : openWeatherMap_APP_ID
            ]
            
            return params
            
        case .userLocation(let location):
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String:String] = [
                "lat" : latitude,
                "lon" : longitude,
                "appid" : openWeatherMap_APP_ID
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
    
    func fetchWeatherData(for method: LocationMethod)-> Promise<JSON> {
        
        return Promise { seal in
            
            let params = getOpenWeatherMapParams(for: method)
            
            Alamofire.request(openWeatherMapURL, method: .get, parameters: params).validate().responseJSON { response in
                
                print(response.request)
                switch response.result {
                    
                case .success(let json):
                    seal.fulfill(JSON(json))
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    //
    func fetchWeatherData2(for method: LocationMethod)-> Promise<Data> {
        
        return Promise { seal in
            
            let params = getOpenWeatherMapParams(for: method)
            
            Alamofire.request(openWeatherMapURL, method: .get, parameters: params).validate().responseData() { response in
                
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
    
    
    
    
    func fetchPlacePhotos(for reference: String)->Promise<UIImage>{
        
        return Promise { seal in
            
            let params = [
                "photoreference" : reference,
                "maxheight" : "800",
                "key" : googleWebService_APP_ID
            ]
            
            let url = createURL(with: GoogleWebService.placePhotos.rawValue, params)
            
            guard let imageData =  try? Data(contentsOf: url) else {return}
            
            guard let image = UIImage(data: imageData) else {return}
            
            seal.fulfill(image)
        }
    }
    
    
    
    func fetchPlaceDetails(for id: String)->Promise<JSON>{
        
        return Promise { seal in
            
            let url = GoogleWebService.placeDetails.rawValue
            
            let params = [
                "placeid" : id,
                "key" : googleWebService_APP_ID
            ]
            
            Alamofire.request(url, method: .get, parameters: params).validate().responseJSON{ response in
                
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
            
            let url = GoogleWebService.placeSearch.rawValue
            
            let params = [
                "inputtype" : "textquery",
                "input" : city,
                "key" : googleWebService_APP_ID
            ]
            
            Alamofire.request(url, method: .get, parameters: params).validate().responseJSON{ response in
                
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


