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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.weatherViewController = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        UIElements = [switchCityButton, tempLabel, cityLabel, imageVIew]
        
        hideElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        backgroundImageView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        
//        if let photo = weather.photoReference {
//
//            dataFetcher.fetchPlacePhotos(for: photo).done { image in
//
//                    self.backgroundImageView.image = image
//
//                }.catch { error in
//
//                    print(error)
//            }
//        }
    }
    
    func updateImage(with image: UIImage){
        
//        backgroundImageView.image = image
//
//        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
//
//            self.backgroundImageView.alpha = 1
//
//        }, completion: nil)
        
    }
    
    
    // MARK: - @IBOutlets & @IBActions
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBAction func switchCity(_ sender: UIButton) {
    }
    
    @IBOutlet var switchCityButton: UIButton!
    
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var imageVIew: UIImageView!

    
    @IBOutlet var backgroundImageView: UIImageView!
    
    // MARK: - Weather data fetching & Parsing
    
    func getWeatherData(for locationMethod: LocationMethod) {
        print("getting data")
        
        spinner.startAnimating()
        
        dataFetcher.fetchWeatherData(for: locationMethod).done { json in
            
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
    func updatePhotoReference(reference: String) {
        weather.photoReference = reference
        
        dataFetcher.fetchPlacePhotos(for: weather.photoReference!).done { image in
            
            self.backgroundImageView.image = image
        }
        
        
    }
    
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
