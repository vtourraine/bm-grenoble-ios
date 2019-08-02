//
//  ItemTableViewCell.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var authorLabel: UILabel?
    @IBOutlet var libraryLabel: UILabel?
    @IBOutlet var returnDateLabel: UILabel?
    @IBOutlet var returnNumberOfDaysLabel: UILabel?

    func configure(item: Item) {
        titleLabel?.text = item.formattedTitle()
        authorLabel?.text = item.formattedAuthor()

        let calendar = NSCalendar.current
        if let returnDate = calendar.date(from: item.returnDateComponents),
            let returnDateShifted = calendar.date(byAdding: .day, value: 1, to: returnDate){
            returnDateLabel?.text = DateFormatter.localizedString(from: returnDate, dateStyle: .medium, timeStyle: .none)

            let numberOfDays = calendar.dateComponents([.day], from: Date(), to: returnDateShifted)
            returnNumberOfDaysLabel?.text = DateComponentsFormatter.localizedString(from: numberOfDays, unitsStyle: .full)

            libraryLabel?.text = item.library
        }
    }
}
