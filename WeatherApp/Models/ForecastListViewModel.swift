//
//  ForecastListViewModel.swift
//  WeatherApp
//
//  Created by Peter on 06/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import UIKit

struct ForecastlistViewModel : Decodable {
    
    var list : [ForecastViewModel]
    
    func organizeForecasts()->[DayWeather] {
        
        let calendar = Calendar.current
        
        let dayWeatherList = list.reduce(
            into: [Date: [ForecastViewModel]](),
            { result, forecastItem in
                let dateWithoutTime = calendar.date(
                    from: calendar.dateComponents(
                        [.year, .month, .day],
                        from: forecastItem.time
                    )
                )
                
                guard let groupingDate = dateWithoutTime else {
                    return
                }
                
                guard result.keys.contains(groupingDate) else {
                    result[groupingDate] = [forecastItem]
                    
                    return
                }
                
                result[groupingDate]?.append(forecastItem)
        }
            ).sorted {
                $0.0 < $1.0
            }.map { item -> DayWeather in
                return DayWeather(date: item.key, forecastList: item.value)
        }
        return dayWeatherList
    }
}

struct ForecastViewModel: Decodable {
    var temperature : TemperatureViewModel
    var conditions : [ConditionsViewModel]
    var time : Date
    
    private enum CodingKeys: String, CodingKey {
        case temperature = "main"
        case conditions = "weather"
        case time = "dt"
    }
    
    
}
