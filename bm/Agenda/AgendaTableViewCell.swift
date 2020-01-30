//
//  AgendaTableViewCell.swift
//  bm
//
//  Created by Vincent Tourraine on 25/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import UIKit
import AlamofireImage

class AgendaTableViewCell : UITableViewCell {
    @IBOutlet var title: UILabel?
    @IBOutlet var date: UILabel?
    @IBOutlet var summary: UILabel?
    @IBOutlet var thumbnail: UIImageView?
    @IBOutlet var disclosure: UIImageView?
}

extension AgendaTableViewCell {
    func configure(item: AgendaItem) {
        title?.text = item.title
        summary?.text = item.summary

        thumbnail?.layer.cornerRadius = 8
        if let image = item.image {
            thumbnail?.af_setImage(withURL: image)
        }
        else {
            thumbnail?.image = nil
        }

        switch item.date {
        case .day(let dateComponents):
            let formattedDate = formatterDateWithoutYear(dateComponents)
            date?.text = formattedDate
        case .range(let startDateComponents, let endDateComponents):
            let dateFormatter = DateIntervalFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .none
            if let startDate = Calendar.current.date(from: startDateComponents),
                let endDate = Calendar.current.date(from: endDateComponents) {
                date?.text = dateFormatter.string(from: startDate, to: endDate)
            }
        }

        if #available(iOS 13.0, *) {
            disclosure?.image = UIImage(systemName: "chevron.right")
        }
    }

    private func formatterDateWithoutYear(_ dateComponents: DateComponents) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.doesRelativeDateFormatting = true

        guard let date = Calendar.current.date(from: dateComponents),
            let year = dateComponents.year else {
                return nil
        }

        let formattedString = dateFormatter.string(from: date)

        let yearSuffixUS = ", \(year)"
        let yearSuffixFR = " \(year)"
        if formattedString.hasSuffix(yearSuffixUS) {
            return formattedString.replacingOccurrences(of: yearSuffixUS, with: "")
        }
        else if formattedString.hasSuffix(yearSuffixFR) {
            return formattedString.replacingOccurrences(of: yearSuffixFR, with: "")
        }
        else {
            return formattedString
        }
    }
}
