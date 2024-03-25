//
//  MainTabBarController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import Foundation
import UIKit

final class MainTabBarController: UITabBarController {

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
    }
}
