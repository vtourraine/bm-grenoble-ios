//
//  AppDelegate.swift
//  bm
//
//  Created by Vincent Tourraine on 30/07/2019.
//  Copyright © 2019-2020 Studio AMANgA. All rights reserved.
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
            tabBarViewController.viewControllers?[0].tabBarItem.image = UIImage(systemName: "books.vertical.fill")
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
        builder.insertSibling(AppDelegate.helpMenu(), afterMenu: .window)
        builder.insertChild(AppDelegate.fileMenu(), atEndOfMenu: .file)
    }

    override func validate(_ command: UICommand) {
        switch command.action {
        case #selector(askToSignOut):
            command.attributes = canAskToSignOut() ? [] : .disabled
        default:
            break
        }
    }
}

extension AppDelegate {
    class func fileMenu() -> UIMenu {
        let signOut = UICommand(title: NSLocalizedString("Sign Out…", comment: ""), image: nil, action: #selector(AppDelegate.askToSignOut))
        return UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("com.studioamanga.bmg.menus.file"), options: .displayInline, children: [signOut])
    }

    class func helpMenu() -> UIMenu {
        let contact = UIKeyCommand(title: NSLocalizedString("Contact Support", comment: ""), image: nil, action: #selector(AppDelegate.contactSupport), input: "", modifierFlags: [], propertyList: nil)
        return UIMenu(title: NSLocalizedString("Help", comment: ""), image: nil, identifier: UIMenu.Identifier("com.studioamanga.bmg.menus.help"), options: [], children: [contact])
    }

    @objc func canAskToSignOut() ->Bool {
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
        if let viewController = window?.rootViewController {
            AboutViewController.contact(from: viewController, delegate: self)
        }
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
