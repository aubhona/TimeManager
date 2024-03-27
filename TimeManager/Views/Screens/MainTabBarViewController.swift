//
//  MainTabBarController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import Foundation
import UIKit

internal final class MainTabBarController: UITabBarController, UITabBarControllerDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let specificTaskListViewController = SpecificTaskListViewController()
        specificTaskListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "checklist"), tag: 0)
        
        let calendarViewController = UIViewController()
        calendarViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "calendar"), tag: 1)
        
        let delayedSpecificTaskListViewController = UIViewController()
        delayedSpecificTaskListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "tray"), tag: 2)
        
        let generalViewController = UIViewController()
        generalViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "note.text"), tag: 3)
        
        let settingsViewController = UIViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "gear"), tag: 3)
        
        viewControllers = [
            UINavigationController(rootViewController: specificTaskListViewController),
            UINavigationController(rootViewController: calendarViewController),
            UINavigationController(rootViewController: delayedSpecificTaskListViewController),
            UINavigationController(rootViewController: generalViewController),
            UINavigationController(rootViewController: settingsViewController)
        ]
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = .red
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarTransition()
    }
}

class TabBarTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.3
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let sourceVC = transitionContext.viewController(forKey: .from),
              let destinationVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(destinationVC.view)
        
        
        destinationVC.view.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            destinationVC.view.alpha = 1
            sourceVC.view.alpha = 0
        }) { finished in
            sourceVC.view.alpha = 1
            transitionContext.completeTransition(finished)
        }
    }
}
