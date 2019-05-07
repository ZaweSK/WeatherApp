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

protocol WeatherCoordinator {
    func cityChanged(_ city: String)
}

class WeatherViewController: UIViewController
{
    
    // MARK: - Stored Properities
    
    var weatherCoordinatorDelegate: WeatherCoordinator?
    
    var locationManager = CLLocationManager()
    
    var imageStore = ImageStore()
    
//    var weather = WeatherDataModel()
    
    
    var weatherViewModel : WeatherViewModel?
    
    var dataFetcher : DataFetcher!
    
    var UIElements = [UIView]()
    
    // MARK: - View Controller Life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.weatherViewController = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        UIElements = [switchCityButton, tempLabel, cityLabel]
        backgroundImageView.alpha = 0
        
        hideElements()
        hideWeatherConditions()
    }
    

    
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
    
    
    func hideWeatherConditions() {
        weatherConditionCenterX.constant = -view.bounds.width / 2
        weatherConditionPadding.isActive = false
        view.layoutIfNeeded()
    }
    
    func updateUIWithWeatherData2(){
        
        guard let weatherModel = weatherViewModel else {return}
        
        tempLabel.text = String(weatherModel.temperature.current.asCelsius)
        cityLabel.text = weatherModel.name
        
        if let image = UIImage(named: weatherModel.conditions.first!.weatherIconName) {
            weatherConditionImageVIew.image = image
        }
        
        spinner.stopAnimating()
        showElements()
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
    
    func setUpImage() {
        
        
        guard let weatherVM = weatherViewModel, weatherVM.photoReference.count > 0 else {
            
            backgroundImageView.image = UIImage(named: "cityNotFound")
            
            showImage()
            
            return
        }
        
        dataFetcher.fetchPlacePhotos(for: weatherVM.photoReference).done { image in
            
            self.imageStore.setImage(image, forKey: weatherVM.name)
            
            self.backgroundImageView.image = image
            
            self.showImage()
            
            }.catch { error in
                
                print("Error unable to get photo with specific reference : \(weatherVM.photoReference) /n Error: \(error) ")
        }
    }
    
    func setUpCityImage(){
        guard let weatherVM = weatherViewModel else { return}
        
        if let imageFromCache = imageStore.image(forKey: weatherVM.name){
            
            backgroundImageView.image = imageFromCache
            
            showImage()
            
        }else {
            
            checkForPhotoReference(for: weatherVM.name)
        }
    }
    
    // MARK: - @IBOutlets & @IBActions
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var switchCityButton: UIButton!
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var cityLabel: UILabel!
    
    @IBOutlet var weatherConditionImageVIew: UIImageView!
    
    @IBOutlet var weatherConditionCenterX: NSLayoutConstraint!
    
    @IBOutlet var weatherConditionPadding: NSLayoutConstraint!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    
    // MARK: - data fetching
    
    func getWeatherData(for locationMethod: LocationMethod) {
        
        spinner.startAnimating()
        
        
        dataFetcher.fetchWeatherData(for: locationMethod).done { data in
            
            do {
                self.weatherViewModel = try JSONDecoder().decode(WeatherViewModel.self, from: data)
                
                self.updateUIWithWeatherData2()
                self.setUpCityImage()
                
                guard let city = self.weatherViewModel?.name else {
                    return
                }
                
                self.weatherCoordinatorDelegate?.cityChanged(city)
                
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
    
    
    func checkForPhotoReference(for city: String){
        
        guard weatherViewModel != nil else { return}
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        firstly {
            
            dataFetcher.fetchPlaceId(for: city)
            
            }.then { json -> Promise<JSON> in
                
                let placeId = json["candidates"][0]["place_id"].stringValue
                
                return self.dataFetcher.fetchPlaceDetails(for: placeId)
                
            }.done { json in
                
                self.weatherViewModel!.photoReference = json["result"]["photos"][0]["photo_reference"].stringValue
                
            }.ensure {
                
                self.setUpImage()
                
            }.catch {error in
                
                print(error)
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
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            
        case (.compact, .compact):
            cityLabel.textAlignment = .left
        case(.compact,.regular):
            cityLabel.textAlignment = .center
        default: break
            
        }
    }
}


// MARK: - ChangeCity delegate methods

extension WeatherViewController: ChangeCityDelegate {
    
    func userEnteredNewCity(viewModel: WeatherViewModel) {
        
        hideWeatherConditions()
        
        backgroundImageView.image = nil
        
        backgroundImageView.alpha = 0
        
        weatherViewModel = viewModel
        
        updateUIWithWeatherData2()
        
        setUpCityImage()
        
        weatherCoordinatorDelegate?.cityChanged(viewModel.name)
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
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        switch(CLLocationManager.authorizationStatus())  {
            
        case .denied:
            
            let alertController = UIAlertController(title: "Allow location services",
                                                    message: nil,
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                
                if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(appSettings as URL)
                }
            }
            alertController.addAction(settingsAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        default: break
        }
    }
    
}

enum LocationMethod {
    case userLocation(CLLocation)
    case city(String)
}


