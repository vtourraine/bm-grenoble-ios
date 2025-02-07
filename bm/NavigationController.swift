//
//  NavigationController.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 27/03/2024.
//  Copyright © 2024 Studio AMANgA. All rights reserved.
//

import UIKit

extension UINavigationController {
    func configureCustomAppearance(tintColor: UIColor = .white, backgroundColor: UIColor = .bmRed) {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            var largeTitleTextAttributes = appearance.largeTitleTextAttributes
            largeTitleTextAttributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 34)
            largeTitleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
            appearance.largeTitleTextAttributes = largeTitleTextAttributes
            appearance.backgroundColor = backgroundColor
            navigationBar.tintColor = tintColor
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
        }
    }
}

extension UINavigationItem {
    func setTitle(_ title: String, subtitle: String?) {
        guard let subtitle else {
            self.titleView = nil
            return
        }

        let textColor = UIColor.white

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = textColor
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = textColor
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        subtitleLabel.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical

        self.titleView = stackView
    }
}
