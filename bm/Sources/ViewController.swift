//
//  ViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

import WebKit
import SafariServices
import MessageUI

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class ViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var loans: [Item] = []
    var loader: GhostLoader?

    let LoginSegueIdentifier = "Login"
    let CardSegueIdentifier = "Card"

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(openInfoPanel(sender:)), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem

        refreshControl?.tintColor = .white

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        if let itemCache = ItemCache.load(from: .standard) {
            loans = itemCache.items
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if Credentials.load(from: .standard) == nil {
            presentLoginScreen(sender: nil)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions

    @objc func openAccountInWebBrowser(sender: Any?) {
        let url = URL(string: GhostWebView.AccountURL)!
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true, completion: nil)
    }

    @objc func openInfoPanel(sender: Any) {
        let viewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if Credentials.load(from: .standard) == nil {
            viewController.addAction(UIAlertAction(title: NSLocalizedString("Sign In", comment: ""), style: .default, handler: { _ in
                self.presentLoginScreen(sender: nil)
            }))
        }
        else {
            viewController.addAction(UIAlertAction(title: NSLocalizedString("Sign Out", comment: ""), style: .destructive, handler: { _ in
                self.signOut(sender: nil)
            }))
        }
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Show Subscriber Card", comment: ""), style: .default, handler: { _ in
            self.performSegue(withIdentifier: self.CardSegueIdentifier, sender: nil)
        }))
    viewController.addAction(UIAlertAction(title: NSLocalizedString("Open Account in Safari", comment: ""), style: .default, handler: { _ in
            self.openAccountInWebBrowser(sender: nil)
        }))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("About", comment: ""), style: .default, handler: { _ in
            self.presentAboutScreen(sender: nil)
        }))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        viewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(viewController, animated: true, completion: nil)
    }

    @objc func presentAboutScreen(sender: Any?) {
        let viewController = UIAlertController(title: NSLocalizedString("About", comment: ""), message: NSLocalizedString("This application is developed by Vincent Tourraine, and is not affiliated with the Grenoble Public Library.", comment: ""), preferredStyle: .alert)
        if MFMailComposeViewController.canSendMail() {
            viewController.addAction(UIAlertAction(title: NSLocalizedString("Contact", comment: ""), style: .default, handler: { _ in
                self.contact(sender: nil)
            }))
        }
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Checkout Source Code", comment: ""), style: .default, handler: { _ in
            self.openCodeRepository(sender: nil)
        }))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(viewController, animated: true, completion: nil)
    }

    @IBAction func refresh(sender: Any?) {
        guard let credentials = Credentials.load(from: .standard) else {
            return
        }

        loader = GhostLoader(credentials: credentials, parentView: view, success: { (items) in
            self.loans = items
            let itemCache = ItemCache(items: self.loans)
            ItemCache.save(items: itemCache, to: .standard)

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.loader = nil
        }) { (error) in
            self.presentLoadingError(error)
            self.loader = nil
        }
    }

    @objc func contact(sender: Any?) {
        let emailAddress = "studioamanga@gmail.com"

        let viewController = MFMailComposeViewController()
        viewController.setToRecipients([emailAddress])
        viewController.setSubject(NSLocalizedString("BM Grenoble", comment: ""))
        viewController.mailComposeDelegate = self
        present(viewController, animated: true, completion: nil)
    }

    @objc func openCodeRepository(sender: Any?) {
        let url = URL(string: "https://github.com/vtourraine/bm-grenoble-ios")!
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true, completion: nil)
    }

    @objc func presentLoginScreen(sender: Any?) {
        performSegue(withIdentifier: LoginSegueIdentifier, sender: sender)
    }

    @objc func signOut(sender: Any?) {
        Credentials.remove(from: .standard)
        ItemCache.remove(from: .standard)

        loans = []
        tableView.reloadData()

        presentLoginScreen(sender: nil)
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        let item = loans[indexPath.row]
        cell.configure(item: item)
        return cell
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func presentLoadingError(_ error: Error?) {
        let alertController = UIAlertController(title: NSLocalizedString("Connection Error", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
