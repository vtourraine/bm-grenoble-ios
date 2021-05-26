//
//  Document+Formatter.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 18/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import Foundation
import BMKit

extension Notice {
    func localizedStatus() -> String {
        switch status {
        case "Avalaible":
            return NSLocalizedString("Available", comment: "")
        case "Loaned":
            return NSLocalizedString("Loaned", comment: "")
        case "Réservé":
            return NSLocalizedString("Reserved", comment: "")
        case "En réparation":
            return NSLocalizedString("Under reparation", comment: "")
        case "Communication sur place":
            return NSLocalizedString("On-site communication", comment: "")
        case "A transférer autre bib.":
            return NSLocalizedString("To transfer to another library", comment: "")
        default:
            return status
        }
    }
}

extension Document {
    func formattedTitle() -> String {
        var formattedTitle = title

        if let slash = formattedTitle.range(of: " / ") {
            formattedTitle = String(formattedTitle[..<slash.lowerBound])
        }

        formattedTitle = formattedTitle.replacingOccurrences(of: "[\(type.uppercased())]", with: "")
        formattedTitle = formattedTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        return formattedTitle
    }

    static func systemImageName(for type: String) -> String {
        switch type {
        case "DVD":
            return "tv"
        case "CD":
            return "smallcircle.circle"
        default:
            return "book"
        }
    }

    func systemImageNameForType() -> String {
        return Document.systemImageName(for: type)
    }

    func webpage() -> URL {
        return BaseURL.appendingPathComponent("ark:/" + ark)
    }

    func localizedType() -> String {
        switch type {
        case "Books":
            return NSLocalizedString("Book", comment: "")
        case "Videos":
            return NSLocalizedString("Video", comment: "")
        case "Scores":
            return NSLocalizedString("Score", comment: "")
        case "Language learning aids":
            return NSLocalizedString("Language learning aid", comment: "")
        default:
            return type
        }
    }
}

extension DateComponents {

    // We want the formatted return date in “full” style, but without the “year” information, for instance:
    // “17 août” instead of “17 août 2019”
    // "August 17" instead of "August 17, 2019"
    func formattedReturnDate() -> (localizedDate: String, numberOfDays:Int, localizedNumberOfDays: String)? {
        let calendar = NSCalendar.current
        guard let returnDate = calendar.date(from: self),
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
