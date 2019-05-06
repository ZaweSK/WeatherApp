//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Peter on 06/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation

struct WeatherViewModel: Decodable {
    
    var name: String
    var temperature : TemperatureViewModel
    var conditions : [ConditionsViewModel]
    var photoReference = ""
    
    private enum CodingKeys : String, CodingKey {
        case name
        case temperature = "main"
        case conditions = "weather"
    }
    
}

struct TemperatureViewModel : Decodable{
    var current : Double
    var humidity : Double
    var pressure : Double
    
    private enum CodingKeys: String, CodingKey {
        case current  = "temp"
        case humidity = "humidity"
        case pressure = "pressure"
    }
}

struct ConditionsViewModel: Decodable {
    var id : Int
    var description: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case description = "description"
    }
    
    var weatherIconName : String {
        
        switch id {
            
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return  "light_rain"
            
        case 501...600 :
            return  "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return  "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
        
    }
}

extension Double {
    var asCelsius : String {
        return "\(Int(self)) °C"
    }
}
