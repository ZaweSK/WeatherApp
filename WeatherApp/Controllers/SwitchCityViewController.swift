//
//  SwitchCityViewController.swift
//  WeatherApp
//
//  Created by Peter on 19/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit

protocol ChangeCityDelegate{
    func userEnteredNewCity(viewModel: WeatherViewModel)
}

class SwitchCityViewController: UIViewController, UITextFieldDelegate
{

    var delegate: ChangeCityDelegate?
    
    var dataFetcher : DataFetcher!
    

    // MARK: - VC's life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cityTextField.endEditing(true)
    }
    
    // MARK: - @IBOutlets & @IBActions
    
    @IBOutlet var backButton: UIButton!
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var cityTextField: UITextField!
   
    @IBOutlet var getWeatherButton: UIButton!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        cityTextField.endEditing(true)
    }
    
    @IBAction func getWeather(_ sender: UIButton) {
        
        let cityName = cityTextField.text!
        
        guard cityName.count > 0 else {
            shakeTextField()
            return
        }
        
        dataFetcher.fetchWeatherData(for: .city(cityName)).done { data in
            
            let weatherVM = try JSONDecoder().decode(WeatherViewModel.self, from: data)
            
            self.delegate?.userEnteredNewCity(viewModel: weatherVM)
            
            self.dismiss(animated: true, completion: nil)
            
            }.catch { error in
                print(error)
                self.reactionToInvalidCity(with: cityName)
        }
    }
    
    // MARK: - UI methods
    
    func reactionToInvalidCity(with cityName: String){
        
        let options = [
            "Really? \(cityName) ? ",
            "We both know there is no such thing as \(cityName)",
            "Try again. There is no \(cityName)",
            "Never heard of \(cityName)",
        ]
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.darkGray
        label.text = options.randomElement()
        label.font = UIFont(name: "Hiragino Mincho ProN W3", size: 17)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var xPosition = label.centerXAnchor.constraint(equalTo: label.superview!.centerXAnchor, constant: -view.bounds.width )
        xPosition.isActive = true
        
        label.widthAnchor.constraint(equalTo: label.superview!.widthAnchor, multiplier: 0.7).isActive = true
        label.topAnchor.constraint(equalTo: getWeatherButton.bottomAnchor, constant: 15).isActive = true
        
        view.layoutIfNeeded()
        
        shakeTextField()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            
            xPosition.isActive = false
            xPosition = label.centerXAnchor.constraint(equalTo: label.superview!.centerXAnchor)
            xPosition.isActive = true
            self.view.layoutIfNeeded()
            
        }) { _ in
            
            UIView.animate(withDuration: 0.3, delay: 1.8, options: [.curveEaseIn], animations: {
                xPosition.isActive = false
                xPosition = label.centerXAnchor.constraint(equalTo: label.superview!.centerXAnchor, constant: self.view.bounds.width)
                xPosition.isActive = true
                self.view.layoutIfNeeded()
                
            }, completion: { (_) in
                label.removeFromSuperview()
            })
        }
    }
    
    
    func shakeTextField() {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: cityTextField.center.x - 10, y: cityTextField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: cityTextField.center.x + 10, y: cityTextField.center.y))
        
        cityTextField.layer.add(animation, forKey: "position")
        
    }
    
    
    //MARK: - UITextField Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cityTextField.resignFirstResponder()
        return true
    }
    
}
