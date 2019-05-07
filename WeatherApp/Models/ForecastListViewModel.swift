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
