//
//  ItemTableViewCell.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019-2020 Studio AMANgA. All rights reserved.
//

import UIKit
import AlamofireImage
import BMKit

class ItemTableViewCell: UITableViewCell {

    static let NumberOfDaysAlertThreshold = 10

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var authorLabel: UILabel?
    @IBOutlet var libraryLabel: UILabel?
    @IBOutlet var returnDateLabel: UILabel?
    @IBOutlet var returnNumberOfDaysLabel: UILabel?
    @IBOutlet var thumbnail: UIImageView?

    func configure(item: Item) {
        titleLabel?.text = item.title
        authorLabel?.text = item.author
        libraryLabel?.text = item.library

        if let formattedReturnDate = item.returnDateComponents.formattedReturnDate() {
            returnDateLabel?.text = formattedReturnDate.localizedDate
            if formattedReturnDate.numberOfDays <= 0 {
                returnNumberOfDaysLabel?.text = "⚠️ \(formattedReturnDate.localizedNumberOfDays)"
            }
            else {
                returnNumberOfDaysLabel?.text = formattedReturnDate.localizedNumberOfDays
            }

            var returnLabelsColor = UIColor.darkText

            if #available(iOS 13.0, *) {
                returnLabelsColor = UIColor.label
            }

            if formattedReturnDate.numberOfDays < ItemTableViewCell.NumberOfDaysAlertThreshold {
                returnLabelsColor = .BMRed
            }

            returnDateLabel?.textColor = returnLabelsColor
            returnNumberOfDaysLabel?.textColor = returnLabelsColor
        }

        thumbnail?.layer.cornerRadius = 2

        let placeholderImage: UIImage?
        if #available(iOS 13.0, *) {
            let imageName = Item.systemImageName(for: item.type)
            placeholderImage = UIImage(systemName: imageName)
        }
        else {
            placeholderImage = nil
        }

        if let imageURL = item.image {
            thumbnail?.backgroundColor = nil
            thumbnail?.contentMode = .scaleAspectFit
            thumbnail?.af.setImage(withURL: imageURL, placeholderImage: placeholderImage, completion: { response in
                if let data = response.data {
                    self.thumbnail?.image = UIImage(data: data)
                    self.setNeedsLayout()
                }
            })
        }
        else {
            if #available(iOS 13.0, *) {
                thumbnail?.image = placeholderImage
                thumbnail?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
                thumbnail?.tintColor = .secondaryLabel
                thumbnail?.backgroundColor = .systemFill
                thumbnail?.contentMode = .center
            }
            else {
                thumbnail?.image = nil
                thumbnail?.backgroundColor = .lightGray
            }
        }
    }
}
