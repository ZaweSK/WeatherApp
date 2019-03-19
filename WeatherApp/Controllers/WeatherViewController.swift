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
    
    let APP_ID = "ceb75d42efb0a329e2d5d1d6819032b1"
    let URL = "http://api.openweathermap.org/data/2.5/weather"
    
    var weather = WeatherDataModel()
    var UIElements = [UIView]()
    
    // MARK: - UIConfiguration methods
    
    func hideElements(){
        UIElements.forEach {
            $0.alpha = 0
        }
    }
    
    func showElements(){
        UIView.animate(withDuration: 1) {
            self.UIElements.forEach {
                $0.alpha = 1
            }
        }
    }
    
    func updateUIWithWeatherData(){
        tempLabel.text = String(weather.temperature) + "℃"
        cityLabel.text = weather.city
        
        if let image = UIImage(named: weather.weatherIconName) {
            imageVIew.image = image
        }
        
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
    

    @IBAction func switchCity(_ sender: UIButton) {
    }
    
    @IBOutlet var switchCityButton: UIButton!
    
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var imageVIew: UIImageView!

    
    
    // MARK: - Weather data fetching & Parsing
    
    func getWeatherData(url: String, _ parameters : [String:String]) {
        Alamofire.request(url, method: .get, parameters: parameters)
            .responseJSON().done { response in
                
                let weatherJSON : JSON = JSON(response.json)
                
                self.updateWeatherData(with: weatherJSON)
                
            }.catch {error in
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.showElements()
                    
                })
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
    

}


// MARKL: - LocationManagerDelegate methods

extension WeatherViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = (locations.last)!
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()

            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String:String] = [
                "lat" : latitude,
                "lon" : longitude,
                "appid" : APP_ID
            ]
            
            getWeatherData(url: URL, params)
        }
    }
}
