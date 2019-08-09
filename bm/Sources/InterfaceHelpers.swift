//
//  InterfaceHelpers.swift
//  bm
//
//  Created by Vincent Tourraine on 09/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentLoadingError(_ error: Error?) {
        let alertController = UIAlertController(title: NSLocalizedString("Connection Error", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension UIView {
    func configureRoundCorners() {
        let CornerRadius: CGFloat = 8
        layer.cornerRadius = CornerRadius
    }
}
