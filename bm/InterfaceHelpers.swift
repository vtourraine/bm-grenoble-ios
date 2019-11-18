//
//  InterfaceHelpers.swift
//  bm
//
//  Created by Vincent Tourraine on 09/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
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
    func presentLoadingError(_ error: Error?) {
        let alertController = UIAlertController(title: NSLocalizedString("Connection Error", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func presentSafariViewController(_ webpageURL: URL) {
        let viewController = SFSafariViewController(url: webpageURL)
        viewController.preferredControlTintColor = UIColor(named: "BMRed")
        present(viewController, animated: true, completion: nil)
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
        backgroundColor = UIColor.white
        tintColor = UIColor(named: "BMRed")
        setTitleColor(UIColor(named: "BMRed"), for: .normal)
        layer.cornerRadius = 22

        if #available(iOS 13.0, *) {
            setTitle(nil, for: .normal)
            setImage(UIImage(systemName: "xmark"), for: .normal)
        }
    }
}
