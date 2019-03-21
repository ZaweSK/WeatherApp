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
            weatherConditionImageVIew.image = image
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
        
        UIElements = [switchCityButton, tempLabel, cityLabel]
        backgroundImageView.alpha = 0
        
        hideElements()
    }
    
    @IBOutlet var weatherConditionCenterX: NSLayoutConstraint!
    @IBOutlet var weatherConditionPadding: NSLayoutConstraint!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        weatherConditionCenterX.constant = -view.bounds.width / 2
        weatherConditionPadding.isActive = false
        
        view.layoutIfNeeded()
    }
    
    
    func showImage(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {

            self.backgroundImageView.alpha = 1

        }, completion: { _ in
            
            
            self.weatherConditionCenterX.constant = 0
            self.weatherConditionPadding.isActive = true
            
            UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        })
    }
    
    func animateWeatherCondition(){
        
    }
    
    
    // MARK: - @IBOutlets & @IBActions
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBAction func switchCity(_ sender: UIButton) {
    }
    
    @IBOutlet var switchCityButton: UIButton!
    
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var weatherConditionImageVIew: UIImageView!

    
    @IBOutlet var backgroundImageView: UIImageView!
    
    // MARK: - data fetching
    
    func getWeatherData(for locationMethod: LocationMethod) {
        
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
    
    
    func checkForPhotoReference(for city: String){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        firstly {
            
            dataFetcher.fetchPlaceId(for: city)
            
            }.then { json -> Promise<JSON> in
                
                let placeId = json["candidates"][0]["place_id"].stringValue
                
                return self.dataFetcher.fetchPlaceDetails(for: placeId)
                
            }.done { json in
                
                self.weather.photoReference = json["result"]["photos"][0]["photo_reference"].stringValue
                
            }.ensure {
                
                self.setUpImage()
                
            }.catch {error in
                
                print(error)
        }
    }
    
    
    
    // MARK: - Parsing data
    
    func updateWeatherData(with json: JSON){
        
        if let temp = json["main"]["temp"].double {
            weather.temperature = Int(temp - 273)
            weather.city = json["name"].stringValue
            weather.condition = json["weather"][0]["id"].intValue
            
            checkForPhotoReference(for: weather.city)
            
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
    
    
    
    
    func setUpImage() {
        
        guard self.weather.photoReference.count > 0 else {
            
            backgroundImageView.image = UIImage(named: "cityNotFound")
            
            showImage()
            
            return
        }
        
        
        
        dataFetcher.fetchPlacePhotos(for: weather.photoReference).done { image in
            
            self.backgroundImageView.image = image
            
            self.showImage()
                
            }.catch { error in
                
                print("Error unable to get photo with specific reference : \(self.weather.photoReference) /n Error: \(error) ")
        }
    }
}


// MARK: - ChangeCity delegate methods



extension WeatherViewController: ChangeCityDelegate {
    
    func userEnteredNewCity(weatherForCityJson: JSON) {
        
        backgroundImageView.image = nil
        
        backgroundImageView.alpha = 0
        
        weather.photoReference = ""
        
        updateWeatherData(with: weatherForCityJson)
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


