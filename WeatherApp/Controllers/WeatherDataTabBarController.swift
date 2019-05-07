//
//  WeatherDataTabBarController.swift
//  WeatherApp
//
//  Created by Peter on 06/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import UIKit

class WeatherDataTabBarController: UITabBarController, WeatherCoordinator {
    
    
    var weatherViewModel: WeatherViewModel?
    var dataFetcher = DataFetcher()
    
    override func viewDidLoad() {
        injectDataFetcher()
    }
    
    var weatherVC: WeatherViewController {
        return self.viewControllers?[0] as! WeatherViewController
    }
    
    var forecastVC: ForecastViewController {
        return self.viewControllers?[1] as! ForecastViewController
    }
    
    func injectDataFetcher() {
        weatherVC.dataFetcher = dataFetcher
        weatherVC.weatherCoordinatorDelegate = self
        
        forecastVC.dataFetcher = dataFetcher
    }
    
    func cityChanged(_ city: String) {
        forecastVC.cityFromWeatherCoordinator = city
    }
    
  
}
