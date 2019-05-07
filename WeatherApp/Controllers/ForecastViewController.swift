//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Peter on 07/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    var currentlyForecastedCity : String?
    var cityFromWeatherCoordinator: String?
    var dataFetcher : DataFetcher!
    
    var forecastListViewModel : ForecastlistViewModel?
    var dayWeatherList = [DayWeather]()
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var cityLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard cityFromWeatherCoordinator != currentlyForecastedCity else  {
            return
        }
        
        currentlyForecastedCity = cityFromWeatherCoordinator
        cityLabel.text = currentlyForecastedCity
        
        getForecastData()
    }
    
    func getForecastData(){
        
        guard let cityName = currentlyForecastedCity else {
            return
        }
        
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
   
    
    //MARK: - UITableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastCell
        return cell
    }
    
    //MARK: - UITableViewDelegate Methods
    
    

}
