//
//  InterfaceHelpers.swift
//  bm
//
//  Created by Vincent Tourraine on 09/08/2019.
//  Copyright © 2019-2022 Studio AMANgA. All rights reserved.
//

import UIKit
import SafariServices

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
    func presentError(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
    func presentError(_ error: Error?, title: String = NSLocalizedString("Error", comment: "")) {
        presentError(title: title, body: error?.localizedDescription ?? "")
    }
    
    func presentLoadingError(_ error: Error?) {
        presentError(error, title: NSLocalizedString("Connection Error", comment: ""))
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
    func configureXMarkImage() {
        layer.cornerRadius = 22
        tintColor = .BMRed
        setTitleColor(.BMRed, for: .normal)

        if #available(iOS 13.0, *) {
            setTitle(nil, for: .normal)
            setImage(UIImage(systemName: "xmark"), for: .normal)
            setPreferredSymbolConfiguration(.init(weight: .medium), forImageIn: .normal)
        }
    }
    func configureCloseButton() {
        backgroundColor = .white
        layer.borderWidth = UIScreen.main.scale
        layer.borderColor = UIColor.BMRed.cgColor
        configureXMarkImage()
    }

    func configureClearButton() {
        backgroundColor = .bmRed.withAlphaComponent(0.1)
        configureXMarkImage()
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
