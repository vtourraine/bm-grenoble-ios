//
//  AboutViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 27/09/2019.
//  Copyright © 2019-2024 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class AboutViewController: UIViewController {

    @IBOutlet var closeButton: UIButton?
    @IBOutlet var contactButton: UIButton?
    @IBOutlet var codeButton: UIButton?
    @IBOutlet var signoutButton: UIButton?

    var userIsLoggedIn: Bool = false

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        contactButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        contactButton?.configureRoundCorners()

        codeButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        codeButton?.configureRoundCorners()

        signoutButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        signoutButton?.configureRoundCorners()

        closeButton?.configureCloseButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        signoutButton?.isHidden = !userIsLoggedIn
    }

    // MARK: - Actions

    static func openComposeContactAddress() {
        let emailAddress = "studioamanga@gmail.com"
        let url = URL(string: "mailto:\(emailAddress)")!
        UIApplication.shared.open(url)
    }

    @IBAction func contact(_ sender: Any?) {
        AboutViewController.openComposeContactAddress()
    }

    @IBAction func openCodeRepository(_ sender: Any?) {
        let url = URL(string: "https://github.com/vtourraine/bm-grenoble-ios")!
        presentSafariViewController(url)
    }

    @IBAction func signOut(_ sender: Any) {
        guard let tabBarController = presentingViewController as? UITabBarController else {
                return
        }

        AboutViewController.signOut(from: tabBarController)

        dismiss(animated: true)
    }

    static func signOut(from tabBarController: UITabBarController) {
        try? Credentials.remove(from: Credentials.defaultKeychain())
    }

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}
