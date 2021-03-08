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

        if let formattedReturnDate = formattedReturnDate(components: item.returnDateComponents) {
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
        if let image = item.image {
            thumbnail?.af.setImage(withURL: image)
            thumbnail?.backgroundColor = nil
            thumbnail?.contentMode = .scaleAspectFit
        }
        else {
            if #available(iOS 13.0, *) {
                let imageName = Document.systemImageName(for: item.type)
                thumbnail?.image = UIImage(systemName: imageName)
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

    // We want the formatted return date in “full” style, but without the “year” information, for instance:
    // “17 août” instead of “17 août 2019”
    // "August 17" instead of "August 17, 2019"
    func formattedReturnDate(components returnDateComponents: DateComponents) -> (localizedDate: String, numberOfDays:Int, localizedNumberOfDays: String)? {
        let calendar = NSCalendar.current
        guard let returnDate = calendar.date(from: returnDateComponents),
            let returnDateShifted = calendar.date(byAdding: .day, value: 1, to: returnDate) else {
                return nil
        }

        let localizedLongReturnDate = DateFormatter.localizedString(from: returnDate, dateStyle: .long, timeStyle: .none)
        let localizedMediumReturnDate: String
        let year = calendar.component(.year, from: returnDate)
        let yearSuffixUS = ", \(year)"
        let yearSuffixFR = " \(year)"
        if localizedLongReturnDate.hasSuffix(yearSuffixUS) {
            localizedMediumReturnDate = localizedLongReturnDate.replacingOccurrences(of: yearSuffixUS, with: "")
        }
        else if localizedLongReturnDate.hasSuffix(yearSuffixFR) {
            localizedMediumReturnDate = localizedLongReturnDate.replacingOccurrences(of: yearSuffixFR, with: "")
        }
        else {
            localizedMediumReturnDate = DateFormatter.localizedString(from: returnDate, dateStyle: .medium, timeStyle: .none)
        }

        let numberOfDays = calendar.dateComponents([.day], from: Date(), to: returnDateShifted)
        guard let localizedNumberOfDays = DateComponentsFormatter.localizedString(from: numberOfDays, unitsStyle: .full),
            let numberOfDaysValue = numberOfDays.day else {
                return nil

        }

        return (localizedMediumReturnDate, numberOfDaysValue, localizedNumberOfDays)
    }
}
