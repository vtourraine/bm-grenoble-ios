//
//  AboutViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 27/09/2019.
//  Copyright © 2019-2020 Studio AMANgA. All rights reserved.
//

import UIKit
import MessageUI
import BMKit

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

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

    @IBAction func contact(_ sender: Any?) {
        let emailAddress = "studioamanga@gmail.com"

        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: NSLocalizedString("Contact", comment: ""), message: emailAddress, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }

        let viewController = MFMailComposeViewController()
        viewController.setToRecipients([emailAddress])
        viewController.setSubject(NSLocalizedString("BM Grenoble", comment: ""))
        viewController.mailComposeDelegate = self
        present(viewController, animated: true, completion: nil)
    }

    @IBAction func openCodeRepository(_ sender: Any?) {
        let url = URL(string: "https://github.com/vtourraine/bm-grenoble-ios")!
        presentSafariViewController(url)
    }

    @IBAction func signOut(_ sender: Any) {
        guard let presentingTabBarController = presentingViewController as? UITabBarController,
            let navigationController = presentingTabBarController.viewControllers?.first as? UINavigationController,
            let viewController = navigationController.topViewController as? LoansViewController else {
                return
        }

        Credentials.remove(from: .standard)
        ItemCache.remove(from: .standard)

        viewController.reloadData(state: .notLoggedIn)

        dismiss(animated: true) {
            viewController.presentLoginScreen(sender: nil)
        }
    }

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
