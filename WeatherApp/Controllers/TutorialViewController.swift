//
//  TutorialViewController.swift
//  WeatherApp
//
//  Created by Peter on 18/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit
import CoreLocation

class TutorialViewController: UIViewController,TutorialPageViewControllerDelegate, CLLocationManagerDelegate
{
    
    // MARK: - VC's life cyclce methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        containerView.alpha = 0
        pageControl.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.2) {
            self.containerView.alpha = 1
            self.pageControl.alpha = 1
        }
    }
    
    
    // MARK: - UI configuration methods
    
    func animateDissapearance(_ completion: @escaping (()->())){
        UIView.animate(withDuration: 1, animations: {
            self.containerView.alpha = 0
            self.pageControl.alpha = 0
        }) { _ in
            self.containerView.removeFromSuperview()
            self.pageControl.removeFromSuperview()
            completion()
        }
    }
    
    // MARK : - @IBOutlets & @IBActions
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? TutorialPageViewController {
            tutorialPageViewController.tutorialDelegate = self
        }
    }
    
    
    //MARK: - TutorialPageViewController delegate's methods
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController, didUpdatePageCount count: Int) {
        pageControl.size(forNumberOfPages: count)
    }
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        
        if index == pageControl.lastPossibleIndex {
            
            UserDefaults.standard.set(true, forKey: "introductionComplete")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.animateDissapearance() {
                    self.performSegue(withIdentifier: "goToWeather", sender: self)
                }
            }
        }
    }
}

extension UIPageControl{
    
    var lastPossibleIndex: Int {
        return self.numberOfPages - 1
    }
}

