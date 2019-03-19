//
//  OnboardingVIewController.swift
//  WeatherApp
//
//  Created by Peter on 18/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

protocol OnboardingControllerDelegate: class {
    func onboardingPageViewController(onboardingPageViewController : OnboardingViewController, didUpdatePageCount count: Int)
    func onboardingPageViewController(onboardingPageViewController : OnboardingViewController, didUpdatePageIndex index: Int)
}

class OnboardingViewController: UIPageViewController , UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    
    var orderedViewControllers
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    
    enum PageViews: String, CaseIterable {
        case island1
        case island2
        case island3
    }

    
    
}
