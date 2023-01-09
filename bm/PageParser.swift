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

        guard let ul = html.parse(between: "<div id=\"searchresult\" class=\"\">", and: "</div></div></div></div></div></div></div></div></div></div></div></div></div></div>") else {
                return nil
        }

        let lis: [String]
        let lisA = ul.parseOccurences(between: "<div class=\"jss411\">", and: "</div></div></div>")
        if !lisA.isEmpty {
            lis = lisA
        }
        else {
            lis = ul.parseOccurences(between: "<div class=\"jss627\">", and: "</div></div></div>")
        }
        let items: [Item] = lis.compactMap({ li in
            return parseLoan(li: li)
        })

        return items
    }

    class func parseLoan(li: String) -> Item? {
        guard let titleLink = li.parse(between: "title=", and: "<div"),
              let title = titleLink.parse(between: "\"", and: " /"),
              let author = titleLink.parse(between: " /", and: "\">")?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        let returnDate: String
        if let returnDate1 = li.parse(between: "keyboard_return</span></div><div class=\"jss500\"><div class=\"jss390\">", and: "</div><span class=\"jss391\">Date de retour</span>") {
            returnDate = returnDate1
        }
        else if let returnDate2 = li.parse(between: "keyboard_return</span></div><div class=\"jss716\"><div class=\"jss606\">", and: "</div><span class=\"jss607\">Date de retour</span>") {
            returnDate = returnDate2
        }
        else {
            return nil
        }

        let library = ""
        
        let image: URL?
        let ImagePlaceholderSubString = "ISBN/?icon"
        if let imageString = li.parse(between: "<img src=\"", and: "\""),
            imageString.contains(ImagePlaceholderSubString) == false,
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

        return Item(identifier: "", isRenewable: false, title: title.cleanHTMLEntities(), type: "", author: author, library: library, returnDateComponents: returnDateComponents, image: image)
    }
}
