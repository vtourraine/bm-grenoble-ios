//
//  InterfaceHelpers.swift
//  bm
//
//  Created by Vincent Tourraine on 09/08/2019.
//  Copyright © 2019-2022 Studio AMANgA. All rights reserved.
//

import UIKit
import SafariServices
import SwiftMessages

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class UITextFieldPadding : UITextField {
    let padding = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension UIViewController {
    func presentInfo(_ text: String?, details: String? = nil) {
        guard let text else {
            SwiftMessages.hide()
            return
        }

        let message = MessageView.viewFromNib(layout: .statusLine)
        message.configureTheme(.info)
        if let details {
            message.configureContent(title: text, body: details)
        }
        else {
            message.configureContent(body: text)
        }

        if #available(iOS 13.0, *) {
            message.backgroundColor = .systemBackground
        }
        message.button?.isHidden = true

        var config = SwiftMessages.Config()
        config.duration = .forever
        config.presentationStyle = .bottom

        SwiftMessages.show(config: config, view: message)
    }

    func presentError(title: String, body: String, theme: Theme = .error) {
        let message = MessageView.viewFromNib(layout: .messageView)
        message.configureTheme(theme)
        if theme == .error {
            message.backgroundColor = .BMRed
        }
        else if theme == .warning {
            message.backgroundColor = .systemOrange
        }
        message.configureContent(title: title, body: body)
        message.button?.isHidden = true

        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: 10)
        config.presentationStyle = .bottom

        SwiftMessages.show(config: config, view: message)
    }
    
    func presentError(_ error: Error?, theme: Theme = .error, title: String = NSLocalizedString("Error", comment: "")) {
        presentError(title: title, body: error?.localizedDescription ?? "")
    }
    
    func presentLoadingError(_ error: Error?) {
        if case .invalidData = (error as? GhostLoaderError) {
            presentError(title: NSLocalizedString("Connection Error", comment: ""), body: NSLocalizedString("Please try again later", comment: ""), theme: .info)
            return
        }

        presentError(error, theme: .warning, title: NSLocalizedString("Connection Error", comment: ""))
    }

    func presentSafariViewController(_ webpageURL: URL, readerMode: Bool = false) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = readerMode

        let viewController = SFSafariViewController(url: webpageURL, configuration: configuration)
        viewController.preferredControlTintColor = .BMRed
        present(viewController, animated: true, completion: nil)
    }

    func present(_ error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func configureRoundCorners() {
        let CornerRadius: CGFloat = 22
        layer.cornerRadius = CornerRadius
    }
}

extension UIButton {
    func configureCloseButton() {
        backgroundColor = .white
        tintColor = .BMRed
        setTitleColor(.BMRed, for: .normal)
        layer.cornerRadius = 22
        layer.borderWidth = UIScreen.main.scale
        layer.borderColor = UIColor.BMRed.cgColor

        if #available(iOS 13.0, *) {
            setTitle(nil, for: .normal)
            setImage(UIImage(systemName: "xmark"), for: .normal)
        }
    }
}

extension UIColor {
    static var BMRed: UIColor {
        return UIColor(named: "BMRed")!
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
