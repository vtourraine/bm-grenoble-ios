//
//  PageParser.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

class PageParser {
    private static let CatalogueRoot = "http://catalogue.bm-grenoble.fr"

    class func parseLoans(html: String) -> [Item]? {
        if html.contains("<div class=\"accountEmptyList\">") && html.contains("<ul class=\"listItems\">") == false {
            return []
        }

        guard let ul = html.parse(between: "<div id=\"searchresult\" class=\"\">", and: "</div></div></div></div></div></div></div></div></div></div></div></div>") else {
                return nil
        }

        let lis = ul.parseOccurences(between: [
            ("<div class=\"jss411\">",
             "</div></li></div></ul></div></div></div><div>"),
            ("<div class=\"jss414\">",
             "</div></li></div></ul></div></div></div><div>"),
            ("<div class=\"jss627\">",
             "</div></div></div>"),
            ("<div class=\"jss424\">",
             "</div></li></div></ul></div></div></div><div>")
        ])

        let items: [Item] = lis.compactMap { parseLoan(li: $0) }

        return items
    }

    class func parseLoan(li: String) -> Item? {
        guard let titleLink = li.parse(between: "title=\"", and: "\"") else {
            return nil
        }

        let title: String
        let author: String

        if let titleFirst = titleLink.parse(before: " / "),
           let titleSecond = titleLink.parse(after: " / ") {
            title = titleFirst
            author = titleSecond.replacingOccurrences(of: "&amp;", with: "&")
        }
        else {
            title = titleLink
            author = ""
        }

        guard let returnDate = li.parse(between: [
            ("keyboard_return</span></div><div class=\"jss500\"><div class=\"jss390\">",
             "</div><span class=\"jss391\">Date de retour</span>"),
            ("keyboard_return</span></div><div class=\"jss716\"><div class=\"jss606\">",
             "</div><span class=\"jss607\">Date de retour</span>"),
            ("keyboard_return</span></div><div class=\"jss497\"><div class=\"jss390\">",
             "</div><span class=\"jss391\">Date de retour</span>"),
            ("keyboard_return</span></div><div class=\"jss500\"><div class=\"jss393\">",
             "</div><span class=\"jss394\">Date de retour</span>"),
            ("keyboard_return</span></div><div class=\"jss510\"><div class=\"jss403\">",
             "</div><span class=\"jss404\">Date de retour</span>")]) else {
            return nil
        }

        let library = li.parse(between: [
            "Emprunté à :</div><div dir=\"ltr\" class=\"meta-values jss458\"><span>",
            "Emprunté à :</div><div dir=\"ltr\" class=\"meta-values jss461\"><span>",
            "Emprunté à :</div><div dir=\"ltr\" class=\"meta-values jss471\"><span>"
        ], and: "</span>")

        let image: URL?

        if let imageString = li.parse(between: ["<img src=\"", "background-image: url(&quot;", "background: url(&quot;"], and: "&"),
           let imageURL = URL(string: "\(CatalogueRoot)\(imageString)") {
            image = imageURL
        }
        else {
            image = nil
        }

        let returnDateRawComponents = returnDate.trimmingCharacters(in: .whitespaces).components(separatedBy: "/")
        var returnDateComponents = DateComponents()
        if (returnDateRawComponents.count == 3) {
            returnDateComponents.day = Int(returnDateRawComponents[0])
            returnDateComponents.month = Int(returnDateRawComponents[1])
            returnDateComponents.year = Int(returnDateRawComponents[2])
        }

        return Item(identifier: "", isRenewable: false, title: title.cleanHTMLEntities(), type: "", author: author, library: library ?? "", returnDateComponents: returnDateComponents, image: image)
    }
}
