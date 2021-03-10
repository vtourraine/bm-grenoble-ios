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
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var authorLabel: UILabel?
    @IBOutlet var availabilityLabel: UILabel?
    @IBOutlet var availabilityImageView: UIImageView?
    @IBOutlet var thumbnail: UIImageView?

    func configure(with searchResult: SearchResult) {
        titleLabel?.text = searchResult.document.formattedTitle()

        if let firstCreator = searchResult.document.meta?.creators?.first,
           let components = firstCreator.nameComponents() {
            authorLabel?.text = PersonNameComponentsFormatter.localizedString(from: components, style: .default)
        }

        if searchResult.availability.isAvailable {
            availabilityLabel?.text = NSLocalizedString("Document available", comment: "")

            if #available(iOS 13.0, *) {
                availabilityImageView?.image = UIImage(systemName: "checkmark.circle.fill")
                availabilityImageView?.tintColor = .systemGreen
            }
        }
        else {
            availabilityLabel?.text = NSLocalizedString("Document not available", comment: "")

            if #available(iOS 13.0, *) {
                availabilityImageView?.image = UIImage(systemName: "xmark.octagon.fill")
                availabilityImageView?.tintColor = .red
            }
        }

        if let image = searchResult.document.imageURL {
            thumbnail?.backgroundColor = nil
            thumbnail?.contentMode = .scaleAspectFit
            thumbnail?.af.setImage(withURL: image, completion: { response in
                self.setNeedsLayout()
            })
        }
        else {
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
        }
    }
}
