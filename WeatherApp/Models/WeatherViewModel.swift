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
    var conditions : ConditionsViewModel
    
    private enum CodingKeys : String, CodingKey {
        case name
        case temperature = "main"
        case conditions = "weather"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        temperature = try container.decode(TemperatureViewModel.self, forKey: .temperature)
        let conditionsArray =  try container.decode([ConditionsViewModel].self, forKey: .conditions)
        conditions = conditionsArray.first!
        conditions.setUpWeatherIcon()
    }
}

struct TemperatureViewModel : Decodable{
    var temperature : Double
    var humidity : Double
    var pressure : Double
    
    private enum CodingKeys: String, CodingKey {
        case temperature  = "temp"
        case humidity = "humidity"
        case pressure = "pressure"
    }
}

struct ConditionsViewModel: Decodable {
    var id : Int
    var description: String
    var weatherIconName : String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case description = "description"
    }
    
    mutating func setUpWeatherIcon(){
        switch id {
            
            case 0...300 :
            weatherIconName = "tstorm1"
            
            case 301...500 :
            weatherIconName = "light_rain"
            
            case 501...600 :
            weatherIconName = "shower3"
            
            case 601...700 :
            weatherIconName  = "snow4"
            
            case 701...771 :
            weatherIconName = "fog"
            
            case 772...799 :
            weatherIconName =  "tstorm3"
            
            case 800 :
            weatherIconName = "sunny"
            
            case 801...804 :
            weatherIconName = "cloudy2"
            
            case 900...903, 905...1000  :
            weatherIconName = "tstorm3"
            
            case 903 :
            weatherIconName = "snow5"
            
            case 904 :
            weatherIconName = "sunny"
            
            default :
            weatherIconName = "dunno"
        }
    }
    
}
