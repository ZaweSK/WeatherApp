//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Peter on 18/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import PromiseKit
import SwiftyJSON

class WeatherViewController: UIViewController
{
    
    // MARK: - Stored Properities
    
    var locationManager = CLLocationManager()
    
    
    var weather = WeatherDataModel()
    var dataFetcher = DataFetcher()
    
    var UIElements = [UIView]()
    
    // MARK: - UIConfiguration methods
    
    func hideElements(){
        UIElements.forEach {
            $0.alpha = 0
        }
    }
    
    func showElements(){
        
        UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction, animations: {
            self.UIElements.forEach {
                $0.alpha = 1
            }
        }, completion: nil)
    }
    
    func updateUIWithWeatherData(){
        tempLabel.text = String(weather.temperature) + "℃"
        cityLabel.text = weather.city
        
        if let image = UIImage(named: weather.weatherIconName) {
            imageVIew.image = image
        }
        
        spinner.stopAnimating()
        showElements()
    }
    
    
    // MARK: - View Controller Life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        UIElements = [switchCityButton, tempLabel, cityLabel, imageVIew]
        
        hideElements()
    }
    
    
    // MARK: - @IBOutlets & @IBActions
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBAction func switchCity(_ sender: UIButton) {
    }
    
    @IBOutlet var switchCityButton: UIButton!
    
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var imageVIew: UIImageView!

    
    
    // MARK: - Weather data fetching & Parsing
    
    func getWeatherData(for locationMethod: LocationMethod) {
        
        spinner.startAnimating()
        
        dataFetcher.fetchData(for: locationMethod).done { json in
            
            self.updateWeatherData(with: json)
            
            }.catch {error in
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateWeatherData(with json: JSON){
        
        if let temp = json["main"]["temp"].double {
            weather.temperature = Int(temp - 273)
            weather.city = json["name"].stringValue
            weather.condition = json["weather"][0]["id"].intValue
            
            updateUIWithWeatherData()
        }
    }
    
    
    // MARK: - NAvigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "switchCity" {
            let switchCityVC = segue.destination as! SwitchCityViewController
            switchCityVC.delegate = self
            switchCityVC.dataFetcher = dataFetcher
        }
    }

}


// MARK: - ChangeCity delegate methods

extension WeatherViewController: ChangeCityDelegate {
    func userEnteredNewCity(cityJson: JSON) {
        updateWeatherData(with: cityJson)
    }
}

// MARK: - LocationManagerDelegate methods

extension WeatherViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = (locations.last)!
        
        if currentLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            getWeatherData(for: .userLocation(currentLocation))
        }
    }
}

enum LocationMethod {
    case userLocation(CLLocation)
    case city(String)
}
