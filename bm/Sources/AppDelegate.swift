//
//  AppDelegate.swift
//  bm
//
//  Created by Vincent Tourraine on 30/07/2019.
//  Copyright © 2019-2024 Studio AMANgA. All rights reserved.
//

import UIKit
import MessageUI

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
            tabBarViewController.viewControllers?[0].tabBarItem.image = UIImage(systemName: "calendar")
            tabBarViewController.viewControllers?[1].tabBarItem.image = UIImage(systemName: "building.2.fill")
        }

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            tabBarViewController.tabBar.standardAppearance = appearance
            tabBarViewController.tabBar.scrollEdgeAppearance = appearance

            tabBarViewController.viewControllers?[3].tabBarItem.image = UIImage(systemName: "person.text.rectangle.fill")
        }
        else if #available(iOS 13.0, *) {
            tabBarViewController.viewControllers?[3].tabBarItem.image = UIImage(systemName: "creditcard.fill")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let tabBarViewController = window?.rootViewController as? UITabBarController {
            tabBarViewController.delegate = self
        }
    }

    @available(iOS 13.0, *)
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
        builder.remove(menu: .help)
        builder.insertSibling(AppDelegate.helpMenu(), afterMenu: .window)
    }

    @available(iOS 13.0, *)
    override func validate(_ command: UICommand) {
        switch command.action {
        case #selector(askToSignOut):
            command.attributes = canAskToSignOut() ? [] : .disabled
        default:
            break
        }
    }
}

@available(iOS 13.0, *)
extension AppDelegate {
    class func helpMenu() -> UIMenu {
        let contact = UIKeyCommand(title: NSLocalizedString("Contact Support", comment: ""), image: nil, action: #selector(AppDelegate.contactSupport), input: "", modifierFlags: [], propertyList: nil)
        return UIMenu(title: NSLocalizedString("Help", comment: ""), image: nil, identifier: UIMenu.Identifier("com.studioamanga.bmg.menus.help"), options: [], children: [contact])
    }

    @objc func canAskToSignOut() -> Bool {
        return Credentials.sharedCredentials() != nil
    }

    @objc func askToSignOut() {
        guard let viewController = window?.rootViewController else {
            return
        }

        let alertController = UIAlertController(title: NSLocalizedString("Are you sure you want to sign out?", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Sign Out", comment: ""), style: .destructive) { _ in 
            self.signOut()
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }

    @objc func contactSupport() {
        AboutViewController.openComposeContactAddress()
    }

    func signOut() {
        if let viewController = window?.rootViewController as? UITabBarController {
            AboutViewController.signOut(from: viewController)
        }
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

extension AppDelegate: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
