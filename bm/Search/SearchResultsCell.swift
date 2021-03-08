//
//  SearchResultsCell.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 08/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class SearchResultsCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with document: Document) {
        selectionStyle = .none

        textLabel?.text = document.formattedTitle()
        textLabel?.font = .preferredFont(forTextStyle: .headline)
        if #available(iOS 13.0, *) {
            textLabel?.textColor = .label
        }

        if let firstCreator = document.meta.creators?.first,
           let components = firstCreator.nameComponents() {
            detailTextLabel?.text = PersonNameComponentsFormatter.localizedString(from: components, style: .default)
        }
        else {
            detailTextLabel?.text = nil
        }

        detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        if #available(iOS 13.0, *) {
            detailTextLabel?.textColor = .secondaryLabel
        }

//        if let image = document.imageURL {
//            imageView?.af.setImage(withURL: image)
//            imageView?.backgroundColor = nil
//            imageView?.contentMode = .scaleAspectFit
//        }
//        else {
            if #available(iOS 13.0, *) {
                let imageName = document.systemImageNameForType()
                imageView?.image = UIImage(systemName: imageName)
                imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
                imageView?.tintColor = .secondaryLabel
                imageView?.contentMode = .center
            }
            else {
                imageView?.image = nil
            }
//        }
    }
}
