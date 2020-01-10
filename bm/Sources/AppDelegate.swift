//
//  AppDelegate.swift
//  bm
//
//  Created by Vincent Tourraine on 30/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let tabBarViewController = window?.rootViewController as? UITabBarController,
            let navigationController = tabBarViewController.viewControllers?.first as? UINavigationController,
            let viewController = navigationController.topViewController as? LoansViewController {
            tabBarViewController.delegate = self
            viewController.refreshIfNecessary()
        }
    }
}

extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController,
            let topViewController = navigationController.topViewController as? UITableViewController,
            topViewController == navigationController.viewControllers.first,
            topViewController.tableView(topViewController.tableView, numberOfRowsInSection: 0) > 0 {
            topViewController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
