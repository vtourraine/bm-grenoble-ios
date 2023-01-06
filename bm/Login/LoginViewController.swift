//
//  LoginViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 03/08/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK - Outlets

    @IBOutlet var closeButton: UIButton?
    @IBOutlet var subscriberNumberLabel: UILabel?
    @IBOutlet var subscriberNumberTextField: UITextField?
    @IBOutlet var passwordLabel: UILabel?
    @IBOutlet var passwordTextField: UITextField?
    @IBOutlet var connectButton: UIButton?
    @IBOutlet var forgotPasswordButton: UIButton?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var statusBarBackground: UIView?

    var currentTextFieldTopConstraint: NSLayoutConstraint?
    var loader: GhostLoader?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(loading: false)

        closeButton?.configureCloseButton()

        subscriberNumberTextField?.configureRoundCorners()
        passwordTextField?.configureRoundCorners()

        forgotPasswordButton?.titleLabel?.adjustsFontForContentSizeCategory = true

        if let connectButton = connectButton {
            connectButton.titleLabel?.adjustsFontForContentSizeCategory = true
            connectButton.configureRoundCorners()

            let connectButtonConstraint = view.keyboardLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: connectButton.bottomAnchor, constant: 20)
            connectButtonConstraint.priority = .required - 1
            connectButtonConstraint.isActive = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        #if !targetEnvironment(macCatalyst)
        statusBarBackground?.frame = UIApplication.shared.statusBarFrame
        #endif
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        #if !targetEnvironment(macCatalyst)
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { _ in
            self.statusBarBackground?.frame = UIApplication.shared.statusBarFrame
        }
        #endif
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configure(loading: Bool) {
        let textFieldColor: UIColor?

        if loading {
            if #available(iOS 13.0, *) {
                textFieldColor = .tertiaryLabel
            }
            else {
                textFieldColor = .lightGray
            }

            activityIndicatorView?.startAnimating()
        }
        else {
            if #available(iOS 13.0, *) {
                textFieldColor = .label
            }
            else {
                textFieldColor = nil
            }

            activityIndicatorView?.stopAnimating()
        }

        subscriberNumberTextField?.isEnabled = !loading
        subscriberNumberTextField?.textColor = textFieldColor
        passwordTextField?.isEnabled = !loading
        passwordTextField?.textColor = textFieldColor
        connectButton?.isEnabled = !loading
        connectButton?.alpha = loading ? 0.5 : 1.0
    }

    func label(for textField: UITextField) -> UILabel? {
        if textField == subscriberNumberTextField {
            return subscriberNumberLabel
        }
        else if textField == passwordTextField {
            return passwordLabel
        }
        else {
            return nil
        }
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

        let credentials = Credentials(username: subscriberNumber, password: password)

        loader = GhostLoader(credentials: credentials, parentView: view, success: { (items) in
            self.configure(loading: false)

            try? credentials.save(to: Credentials.defaultKeychain())
            let itemCache = ItemCache(items: items)
            ItemCache.save(items: itemCache, to: .standard)

            self.loader = nil

            if let presentingTabBarController = self.presentingViewController as? UITabBarController,
               let navigationController = presentingTabBarController.viewControllers?.first as? UINavigationController,
               let viewController = navigationController.topViewController as? LoansViewController {
                viewController.reloadData(state: .loans(items, []))
            }
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.configure(loading: false)
            self.presentLoadingError(error)
            self.loader = nil
        }

/*
        let urlSession = URLSession.shared
        urlSession.connect(username: subscriberNumber, password: password) { result in
            switch result {
            case .success(let session):
                let credentials = Credentials(username: subscriberNumber, password: password)
                try? credentials.save(to: Credentials.defaultKeychain())

                self.fetchItems(with: session)

            case .failure(let error):
                self.configure(loading: false)
                self.presentLoadingError(error)
            }
        }
 */
    }

    @IBAction func presentResetPassword(_ sender: Any?) {
        let url = URL(string: "https://catalogue.bm-grenoble.fr/recover")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    private func fetchItems(with session: Session) {
        let urlSession = URLSession.shared
        urlSession.fetchItems(with: session) { result in
            self.configure(loading: false)

            switch result {
            case .success(let items):
                let itemCache = ItemCache(items: items)
                ItemCache.save(items: itemCache, to: .standard)

                self.dismissAfterSuccessfulLogin(with: items)

            case .failure(let error):
                self.presentLoadingError(error)
            }
        }
    }

    private func dismissAfterSuccessfulLogin(with items: [Item]) {
        if let presentingTabBarController = self.presentingViewController as? UITabBarController,
            let navigationController = presentingTabBarController.viewControllers?.first as? UINavigationController,
            let viewController = navigationController.topViewController as? LoansViewController {
            viewController.reloadData(state: .loans(items, []))
        }

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Text field delegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let label = label(for: textField) else {
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.currentTextFieldTopConstraint = label.topAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8)
            self.currentTextFieldTopConstraint?.isActive = true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.currentTextFieldTopConstraint?.isActive = false
            self.currentTextFieldTopConstraint = nil
        }
    }

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
