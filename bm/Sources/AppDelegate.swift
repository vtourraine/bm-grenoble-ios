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
    var lastSelectedViewController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if targetEnvironment(macCatalyst)
        if let titlebar = window?.windowScene?.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif

        updateTabBarIcons()

        return true
    }

    func updateTabBarIcons() {
        guard let tabBarViewController = window?.rootViewController as? UITabBarController else {
            return
        }

        if #available(iOS 14.0, *) {
            tabBarViewController.viewControllers?[0].tabBarItem.image = UIImage(systemName: "books.vertical")
            tabBarViewController.viewControllers?[1].tabBarItem.image = UIImage(systemName: "newspaper")
            tabBarViewController.viewControllers?[2].tabBarItem.image = UIImage(systemName: "calendar")
            tabBarViewController.viewControllers?[3].tabBarItem.image = UIImage(systemName: "building.2")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let tabBarViewController = window?.rootViewController as? UITabBarController,
            let navigationController = tabBarViewController.viewControllers?.first as? UINavigationController,
            let viewController = navigationController.topViewController as? LoansViewController {
            tabBarViewController.delegate = self
            viewController.refreshIfNecessary()
        }
    }

    @available(iOS 13.0, *)
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
        builder.remove(menu: .help)
    }
}

extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if lastSelectedViewController == viewController,
            let navigationController = viewController as? UINavigationController,
            let topViewController = navigationController.topViewController as? UITableViewController,
            topViewController == navigationController.viewControllers.first,
            topViewController.tableView(topViewController.tableView, numberOfRowsInSection: 0) > 0 {
            topViewController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }

        lastSelectedViewController = viewController
    }
}
