//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Peter on 06/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {

    
    @IBOutlet var temperatureLabel: UILabel!
    
    @IBOutlet var weatherConditionLabel: UILabel!
    
    @IBOutlet var timeLabel: UILabel!
    
    func configure(with forecast: ForecastViewModel) {
        self.temperatureLabel.text = forecast.temperature.current.asCelsius
        self.timeLabel.text = forecast.time.timeOnly()
        self.weatherConditionLabel.text = forecast.conditions.first?.description.capitalized
    }
}
