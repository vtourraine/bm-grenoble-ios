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
    @IBOutlet var library: UILabel?
    @IBOutlet var summary: UILabel?
    @IBOutlet var thumbnail: UIImageView?
}

extension AgendaTableViewCell {
    func configure(item: AgendaItem) {
        title?.text = item.title
        library?.text = [item.library, item.category].compactMap { $0 }.joined(separator: "\n")
        summary?.text = item.summary

        thumbnail?.layer.cornerRadius = 8
        if let image = item.image {
            thumbnail?.af.setImage(withURL: image)
        }
        else {
            thumbnail?.image = nil
        }

        switch item.date {
        case .day(let dateComponents):
            let formattedDate = AgendaTableViewCell.formatterDateWithoutYear(dateComponents)
            date?.text = formattedDate?.capitalizingFirstLetter()
        case .range(let startDateComponents, let endDateComponents):
            let formattedDate = AgendaTableViewCell.formatterRangeDateWithoutYear(from: startDateComponents, to: endDateComponents)
            date?.text = formattedDate?.capitalizingFirstLetter()
        case .none:
            date?.text = nil
        }
    }

    internal static func formatterStringWithoutYear(_ string: String) -> String {
        let year = Calendar.current.component(.year, from: Date())
        let yearSuffixUS = ", \(year)"
        let yearSuffixFR = " \(year)"
        if string.contains(yearSuffixUS) {
            return string.replacingOccurrences(of: yearSuffixUS, with: "")
        }
        else if string.contains(yearSuffixFR) {
            return string.replacingOccurrences(of: yearSuffixFR, with: "")
        }
        else {
            return string
        }
    }

    internal static func formatterRangeDateWithoutYear(from startDateComponents: DateComponents, to endDateComponents: DateComponents) -> String? {
        let dateFormatter = DateIntervalFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short

        guard let startDate = Calendar.current.date(from: startDateComponents),
              let endDate = Calendar.current.date(from: endDateComponents) else {
            return nil
        }

        let formattedDate = dateFormatter.string(from: startDate, to: endDate)
        return formatterStringWithoutYear(formattedDate)
    }

    internal static func formatterDateWithoutYear(_ dateComponents: DateComponents) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.doesRelativeDateFormatting = true

        guard let date = Calendar.current.date(from: dateComponents) else {
            return nil
        }

        let formattedString = dateFormatter.string(from: date)
        return formatterStringWithoutYear(formattedString)
    }
}
