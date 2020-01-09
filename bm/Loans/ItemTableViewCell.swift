//
//  ItemTableViewCell.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019-2020 Studio AMANgA. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    static let NumberOfDaysAlertThreshold = 10

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var authorLabel: UILabel?
    @IBOutlet var libraryLabel: UILabel?
    @IBOutlet var returnDateLabel: UILabel?
    @IBOutlet var returnNumberOfDaysLabel: UILabel?

    func configure(item: Item) {
        titleLabel?.text = item.formattedTitle()
        authorLabel?.text = item.formattedAuthor()
        libraryLabel?.text = item.library

        if let formattedReturnDate = formattedReturnDate(components: item.returnDateComponents) {
            returnDateLabel?.text = formattedReturnDate.localizedDate
            returnNumberOfDaysLabel?.text = formattedReturnDate.localizedNumberOfDays

            var returnLabelsColor = UIColor.darkText

            if #available(iOS 13.0, *) {
                returnLabelsColor = UIColor.label
            }

            if formattedReturnDate.numberOfDays < ItemTableViewCell.NumberOfDaysAlertThreshold,
                let alertColor = UIColor(named: "BMRed") {
                returnLabelsColor = alertColor
            }

            returnDateLabel?.textColor = returnLabelsColor
            returnNumberOfDaysLabel?.textColor = returnLabelsColor
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

        returnDateLabel?.text = localizedMediumReturnDate

        let numberOfDays = calendar.dateComponents([.day], from: Date(), to: returnDateShifted)
        guard let localizedNumberOfDays = DateComponentsFormatter.localizedString(from: numberOfDays, unitsStyle: .full),
            let numberOfDaysValue = numberOfDays.day else {
                return nil

        }

        return (localizedMediumReturnDate, numberOfDaysValue, localizedNumberOfDays)
    }
}
