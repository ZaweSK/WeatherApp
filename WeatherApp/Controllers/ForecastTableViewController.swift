//
//  ForecastTableViewController.swift
//  WeatherApp
//
//  Created by Peter on 06/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

class ForecastTableViewController: UITableViewController {
    
    var weatherViewModel : WeatherViewModel?
    var dataFetcher : DataFetcher!
    
    var forecastDays = [String: [ForecastViewModel]]()
    
    var forecastListViewModel : ForecastlistViewModel?
    var dayWeatherList = [DayWeather]()
    
    var currentCity: String?
    
    func getSharedModel(){
        
        let tabBarController = self.tabBarController as! WeatherDataTabBarController
        if let weatherVM = tabBarController.weatherViewModel {
            weatherViewModel = weatherVM
        } else {
            let alertController = UIAlertController(title: "Error", message: "Destination Unknown", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataFetcher = (tabBarController as! WeatherDataTabBarController).dataFetcher
        
        getSharedModel()
        getForecastData()
    }
    
    func getForecastData(){
        guard currentCity != weatherViewModel?.name,
            let cityName = weatherViewModel?.name
            else {return}
        
        dataFetcher.getForecast(for: .city(cityName)).done { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                self.forecastListViewModel = try decoder.decode(ForecastlistViewModel.self, from: data)
            } catch {
                print(error)
            }
            
            self.checkDays()
            self.tableView.reloadData()
            
            }.catch { error in
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    func checkDays() {
        let calendar = Calendar.current
        
        guard let forecastList = forecastListViewModel else {return}
        
        dayWeatherList = forecastList.list.reduce(
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
    }
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dayWeatherList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayWeatherList[section].forecastList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastCell
        
        let forecast = dayWeatherList[indexPath.section].forecastList[indexPath.row]
        
        cell.temperatureLabel.text = forecast.temperature.current.asCelsius
        cell.timeLabel.text = forecast.time.timeOnly()
        cell.weatherConditionLabel.text = forecast.conditions.first?.description.capitalized
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dayWeatherList[section].date.dayOfWeek()
    }
}


//
//extension Date {
//    func dayOfWeek() -> String? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE"
//        return dateFormatter.string(from: self).capitalized
//    }
//    
//    func timeOnly()->String {
//        let minute = Formatter.minute0x.string(from: self)
//        let hour = Formatter.hour24.string(from: self)
//        return "\(hour):\(minute)"
//    }
//    
//}
//
//extension Formatter {
//    
//    static let minute0x: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "mm"
//        return formatter
//    }()
//    
//    static let hour24: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH"
//        return formatter
//    }()
//}

