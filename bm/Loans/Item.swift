//
//  Book.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import Foundation

struct Item: Codable {
    let identifier: String
    let isRenewable: Bool
    let title: String
    let type: String
    let author: String
    let library: String
    let returnDateComponents: DateComponents
    let image: URL?
}


extension Item {
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
        return Item.systemImageName(for: type)
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
