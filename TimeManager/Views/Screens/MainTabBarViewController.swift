//
//  MainTabBarController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import Foundation
import UIKit

internal final class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate  {
    private var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let specificTaskListViewController = UINavigationController(rootViewController: SpecificTaskListViewController())
        specificTaskListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "checklist"), tag: 0)
        
        let delayedSpecificTaskListViewController = UINavigationController(rootViewController: DelayedSpecificTaskListViewController())
        delayedSpecificTaskListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "tray"), tag: 1)
        
        let generalTaskListViewController = UINavigationController(rootViewController: GeneralTaskListViewController())
        generalTaskListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "note.text"), tag: 2)
        
        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        settingsViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "gear"), tag: 3)
        
        viewControllers = [
            specificTaskListViewController,
            delayedSpecificTaskListViewController,
            generalTaskListViewController,
            settingsViewController
        ]
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = .red
        self.delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        currentIndex = self.selectedIndex
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let viewControllers = viewControllers else { return nil }
        guard let toIndex = viewControllers.firstIndex(of: toVC) else { return nil }
        
        
        let direction: TabBarTransition.SwipeDirection = toIndex > currentIndex ? .left : .right
        return TabBarTransition(direction: direction)
    }
}

class TabBarTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum SwipeDirection {
        case left, right
    }
    
    private let duration: TimeInterval = 0.3
    private var direction: SwipeDirection
    
    init(direction: SwipeDirection) {
        self.direction = direction
        super.init()
    }
    
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
        
        let screenWidth = UIScreen.main.bounds.width
        let transform = CGAffineTransform(translationX: direction == .right ? screenWidth : -screenWidth, y: 0)
        
        destinationVC.view.transform = transform.inverted()
        
        UIView.animate(withDuration: duration, animations: {
            sourceVC.view.transform = transform
            destinationVC.view.transform = .identity
        }) { finished in
            sourceVC.view.transform = .identity
            transitionContext.completeTransition(finished)
        }
    }
}
