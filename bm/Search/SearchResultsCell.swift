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

    func configure(with searchResult: SearchResult) {
        selectionStyle = .none

        textLabel?.text = searchResult.document.formattedTitle()
        textLabel?.font = .preferredFont(forTextStyle: .headline)
        if #available(iOS 13.0, *) {
            textLabel?.textColor = .label
        }

        var detailText = ""

        if let firstCreator = searchResult.document.meta.creators?.first,
           let components = firstCreator.nameComponents() {
            detailText = PersonNameComponentsFormatter.localizedString(from: components, style: .default)
            detailText.append("\n")
        }

        if searchResult.availability.isAvailable {
            detailText.append(NSLocalizedString("Document available", comment: ""))
        }
        else {
            detailText.append(NSLocalizedString("Document not available", comment: ""))
        }

        detailTextLabel?.text = detailText
        detailTextLabel?.numberOfLines = 0
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
                let imageName = searchResult.document.systemImageNameForType()
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
