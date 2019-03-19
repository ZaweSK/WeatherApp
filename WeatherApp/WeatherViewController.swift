//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Peter on 18/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    
    let APP_ID = "ceb75d42efb0a329e2d5d1d6819032b1"
    let URL = "http://api.openweathermap.org/data/2.5/weather"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
    }
    

    @IBAction func switchCity(_ sender: UIButton) {
    }
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var imageVIew: UIImageView!

    
    
    func getWeatherData(url: String, _ parameters : [String:String]) {
        
    }

}


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
