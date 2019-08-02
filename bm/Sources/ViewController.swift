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

class ViewController: UITableViewController, WKNavigationDelegate, MFMailComposeViewControllerDelegate {

    var webView: GhostWebView?
    var loans: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureToolbar(status: nil)

        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(openInfoPanel(sender:)), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem

        refreshControl?.tintColor = .white

        let webView = GhostWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.webView = webView

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        if let itemCache = ItemCache.load(from: .standard) {
            loans = itemCache.items
            configureToolbarWithNumberOfItems()
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

    func configureToolbar(status: String?) {
        let label = UILabel(frame: .zero)
        label.text = status
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        let labelBarButtonItem = UIBarButtonItem(customView: label)
        let spaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        setToolbarItems([spaceBarButtonItem, labelBarButtonItem, spaceBarButtonItem], animated: false)
    }

    func configureToolbarWithNumberOfItems() {
        let status = String(format: NSLocalizedString("%d prêts en cours", comment: ""), self.loans.count)
        self.configureToolbar(status: status)
    }

    // MARK: - Actions

    @objc func openAccountInWebBrowser(sender: Any?) {
        let url = URL(string: GhostWebView.LoginURL)!
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true, completion: nil)
    }

    @objc func openInfoPanel(sender: Any) {
        let viewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Se déconnecter", comment: ""), style: .destructive, handler: nil))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Se connecter", comment: ""), style: .default, handler: { _ in
            self.presentLoginScreen(sender: nil)
        }))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Ouvrir avec Safari", comment: ""), style: .default, handler: { _ in
            self.openAccountInWebBrowser(sender: nil)
        }))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("À propos", comment: ""), style: .default, handler: { _ in
            self.presentAboutScreen(sender: nil)
        }))
        viewController.addAction(UIAlertAction(title: NSLocalizedString("Annuler", comment: ""), style: .cancel, handler: nil))
        viewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(viewController, animated: true, completion: nil)
    }

    @objc func presentAboutScreen(sender: Any?) {
        let viewController = UIAlertController(title: NSLocalizedString("À propos", comment: ""), message: NSLocalizedString("Cette application est développée par Vincent Tourraine, et n’est pas affiliée à la bibliothèque municipale de Grenoble.", comment: ""), preferredStyle: .alert)
        if MFMailComposeViewController.canSendMail() {
            viewController.addAction(UIAlertAction(title: NSLocalizedString("Me contacter", comment: ""), style: .default, handler: { _ in
                self.contact(sender: nil)
            }))
        }
        viewController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(viewController, animated: true, completion: nil)
    }

    @IBAction func refresh(sender: Any?) {
        refreshControl?.tintColor = .white
        configureToolbar(status: NSLocalizedString("Chargement en cours…", comment: ""))
        self.webView?.loadGhostPage()
    }

    @objc func contact(sender: Any?) {
        let emailAddress = "studioamanga@gmail.com"

        let viewController = MFMailComposeViewController()
        viewController.setToRecipients([emailAddress])
        viewController.setSubject(NSLocalizedString("BM Grenoble", comment: ""))
        viewController.mailComposeDelegate = self
        present(viewController, animated: true, completion: nil)
    }

    @objc func presentLoginScreen(sender: Any?) {
        let alertController = UIAlertController(title: NSLocalizedString("Connectez-vous", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Numéro d’abonné(e)", comment: "")
            textField.keyboardType = .numberPad
        }
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Mot de passe", comment: "")
            textField.isSecureTextEntry = true
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Se connecter", comment: ""), style: .default, handler: { _ in
            guard let textFields = alertController.textFields,
                let userIdentifier = textFields[0].text,
                let password = textFields[1].text else {
                    return
            }

            let credentials = Credentials(userIdentifier: userIdentifier, password: password)
            credentials.save(to: .standard)

            self.refresh(sender: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Annuler", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
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

    // MARK: - Web view navigation delegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url,
            let credentials = Credentials.load(from: .standard) else {
                return
        }

        if url.absoluteString == GhostWebView.LoginURL {
            self.webView?.setUsername(credentials.userIdentifier) {
                self.webView?.setPassword(credentials.password) {
                    self.webView?.submitForm {}
                }
            }
        }

        if url.absoluteString == GhostWebView.AccountURL {
            let request = URLRequest(url: URL(string: GhostWebView.AccountLoansURL)!)
            webView.load(request)
        }

        if url.absoluteString == GhostWebView.AccountLoansURL {
            self.webView?.getHTML { (html) in
                self.loans = PageParser.parseLoans(html: html)
                let itemCache = ItemCache(items: self.loans)
                ItemCache.save(items: itemCache, to: .standard)

                self.tableView.reloadData()

                self.configureToolbarWithNumberOfItems()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
