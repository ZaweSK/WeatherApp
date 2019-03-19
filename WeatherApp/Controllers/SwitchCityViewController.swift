//
//  SwitchCityViewController.swift
//  WeatherApp
//
//  Created by Peter on 19/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate{
    func userEnteredNewCity(city: String)
}

class SwitchCityViewController: UIViewController, UITextFieldDelegate
{

    var delegate: ChangeCityDelegate?
    

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
    
    @IBAction func getWeather(_ sender: UIButton) {
        let cityName = cityTextField.text!
        delegate?.userEnteredNewCity(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - UITextField Delegate methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("what")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cityTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        cityTextField.endEditing(true)
    }
}
