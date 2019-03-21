//
//  TutorialPageViewController.swift
//  WeatherApp
//
//  Created by Peter on 18/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController
{    
    weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    
    enum Page: String, CaseIterable{
        case island1
        case island2
        case island3
    }

    // MARK: - VC's life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            
            setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        
        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    // MARK: - Content for PageViewController
    
    lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        Page.allCases.forEach {
            let vc = newViewController(for: $0)
            viewControllers.append(vc)
        }
       return viewControllers
    }()

    private func newViewController(for controller: Page)->UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: controller.rawValue)
    }

}

// MARK: - PageViewController data source methods

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return orderedViewControllers.last }
        
        guard orderedViewControllers.count > previousIndex else { return nil}
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex != orderedViewControllers.count else { return orderedViewControllers.first }
        
        guard orderedViewControllers.count > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageIndex: index)
        }
    }
}



// MARK: - Protocols

protocol TutorialPageViewControllerDelegate: class {
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController, didUpdatePageCount count: Int)
    
    func tutorialPageViewController(tutorialPageViewController: TutorialPageViewController, didUpdatePageIndex index: Int)
}
