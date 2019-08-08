//
//  LoginViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 03/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK - Outlets

    @IBOutlet var subscriberNumberTextField: UITextField?
    @IBOutlet var passwordTextField: UITextField?
    @IBOutlet var connectButton: UIButton?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?

    var loader: GhostLoader?

    // MARK - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(loading: false)

        if let connectButton = connectButton {
            connectButton.layer.cornerRadius = 8
            view.keyboardLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: connectButton.bottomAnchor, constant: 20).isActive = true
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configure(loading: Bool) {
        let textFieldColor: UIColor?

        if loading {
            textFieldColor = .lightGray
            activityIndicatorView?.startAnimating()
        }
        else {
            textFieldColor = nil
            activityIndicatorView?.stopAnimating()
        }

        subscriberNumberTextField?.isEnabled = !loading
        subscriberNumberTextField?.textColor = textFieldColor
        passwordTextField?.isEnabled = !loading
        passwordTextField?.textColor = textFieldColor
        connectButton?.isEnabled = !loading
        connectButton?.alpha = loading ? 0.5 : 1.0
    }

    // MARK: - Actions

    @IBAction func connect(_ sender: Any) {
        subscriberNumberTextField?.resignFirstResponder()
        passwordTextField?.resignFirstResponder()

        guard let subscriberNumber = subscriberNumberTextField?.text,
            let password = passwordTextField?.text,
            subscriberNumber.count > 0,
            password.count > 0 else {
                return
        }

        configure(loading: true)

        let credentials = Credentials(userIdentifier: subscriberNumber, password: password)
        loader = GhostLoader(credentials: credentials, parentView: view, success: { (items) in
            self.configure(loading: false)

            credentials.save(to: .standard)
            let itemCache = ItemCache(items: items)
            ItemCache.save(items: itemCache, to: .standard)

            self.loader = nil

            if let presentingNavigationController = self.presentingViewController as? UINavigationController,
                let viewController = presentingNavigationController.topViewController as? ViewController {
                viewController.loans = items
                viewController.tableView.reloadData()
            }
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.configure(loading: false)
            self.presentLoadingError(error)
            self.loader = nil
        }
    }

    // MARK: - Text field delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == subscriberNumberTextField {
            passwordTextField?.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }

        return true
    }
}
