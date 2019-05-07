//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Peter on 07/05/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    
    // MARK: - Properities
    
    var currentlyForecastedCity : String?
    var cityFromWeatherCoordinator: String?
    var dataFetcher : DataFetcher!
    var dayWeatherList = [DayWeather]()
    
    // MARK: - Outlets
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var cityLabel : UILabel!
    
    // MARK: - ViewControllers's Life Cycle methods
    
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
    
    // MARK: - Data fetching & parsing
    
    func getForecastData(){
        
        guard let cityName = currentlyForecastedCity else {
            return
        }
        
        dataFetcher.getForecast(for: .city(cityName)).done { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                let forecastListViewModel = try decoder.decode(ForecastlistViewModel.self, from: data)
                self.dayWeatherList = forecastListViewModel.organizeForecasts()
                self.tableView.reloadData()
                
            } catch {
                print(error)
            }
            
            }.catch { error in
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dayWeatherList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayWeatherList[section].forecastList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastCell
        
        let forecast = dayWeatherList[indexPath.section].forecastList[indexPath.row]
        
        cell.configure(with: forecast)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dayWeatherList[section].date.dayOfWeek()
    }

}
