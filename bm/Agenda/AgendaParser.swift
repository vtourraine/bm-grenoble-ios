//
//  AgendaParser.swift
//  bm
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

class AgendaParser {
    private static let LinkRoot = "https://www.bm-grenoble.fr"
    private static let AgendaWebpageURL = URL(string: "https://www.bm-grenoble.fr/688-agenda.htm?TPL_CODE=TPL_AGENDALISTE")!

    struct Pagination {
        let nextPage: URL?
    }

    class func parseItems(html: String) -> (items: [AgendaItem], pagination: Pagination)? {
        let parsedItems = html.parseOccurences(between: "<div class=\"item\">", and: "</div>")
        let items: [AgendaItem] = parsedItems.compactMap({ parsedItem in
            return parseAgendaItem(html: parsedItem)
        })

        let pagination: Pagination
        let currentPageStartTags = "</strong></span><span>"
        let navigationEndTags = "</div>"
        let lastPageTags = "</strong></span></div>"

        if let navigation = html.parse(between: currentPageStartTags, and: navigationEndTags),
            let nextPageString = navigation.parse(between: "href=\"", and: "\""),
            let nextPageURL = URL(string: "\(AgendaParser.LinkRoot)\(nextPageString)"),
            html.contains(lastPageTags) == false {
                pagination = Pagination(nextPage: nextPageURL)
        }
        else {
            pagination = Pagination(nextPage: nil)
        }

        return (items: items, pagination: pagination)
    }

    private class func dateComponent(from string: String) -> DateComponents? {
        let dateStringComponents = string.components(separatedBy: "/")
        guard dateStringComponents.count == 3 else {
            return nil
        }

        var dateComponents = DateComponents()
        dateComponents.day = Int(dateStringComponents[0])
        dateComponents.month = Int(dateStringComponents[1])
        dateComponents.year = Int(dateStringComponents[2])
        return dateComponents
    }

    private class func parseAgendaItem(html: String) -> AgendaItem? {
        guard let linkString = html.parse(between: "<a href=\"", and: "\">"),
            let link = URL(string: "\(LinkRoot)\(linkString)"),
            let title = html.parse(between: "</span> - ", and: "</a>")?.cleanHTMLEntities(),
            let infoString = html.parse(between: "class=\"alignleft\" alt=\"\">", and: "<p"),
            let summary = html.parse(between: "<p class=\"resume\">", and: "</p>")?.cleanHTMLEntitiesAndTags() else {
            return nil
        }

        let infoStringComponents = infoString.components(separatedBy: "<br>\n")
        guard infoStringComponents.count >= 2 else {
            return nil
        }

        let itemDate: AgendaItem.AgendaDate
        if let dateString = html.parse(between: "<span>Le ", and: "</span>"),
            let dateComponents = dateComponent(from: dateString) {
                itemDate = .day(dateComponents)
        }
        else if let dateRangeString = html.parse(between: "<span>Du ", and: "</span>") {
            let datesString = dateRangeString.components(separatedBy: " au ")
            guard datesString.count == 2,
                let startDateComponents = dateComponent(from: datesString[0]),
                let endDateComponents = dateComponent(from: datesString[1]) else {
                return nil
            }

            itemDate = .range(startDateComponents, endDateComponents)
        }
        else {
            return nil
        }

        let category = infoStringComponents[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let library = infoStringComponents[1].components(separatedBy: "-").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let image: URL?
        if let imageString = html.parse(between: "<img src=\"", and: "\""),
            let imageURL = URL(string: "\(AgendaParser.LinkRoot)\(imageString)") {
            image = imageURL
        }
        else {
            image = nil
        }

        return AgendaItem(title: title, summary: summary, category: category, library: library, link: link, date: itemDate, image: image)
    }

    class func fetchAgendaItems(completionHandler: @escaping (Result<[AgendaItem], Error>) -> Void) {
        fetchAgendaItems(at: AgendaWebpageURL, fetchedItems: []) { result in
            switch result {
            case .success(let items):
                completionHandler(.success(items))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    class func fetchAgendaItems(at url: URL, fetchedItems: [AgendaItem], completionHandler: @escaping (Result<[AgendaItem], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, let string = String(data: data, encoding: .utf8), let agendaItem = parseItems(html: string) else {
                    if let networkError = error {
                        completionHandler(.failure(networkError))
                    }
                    else {
                        completionHandler(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                    }
                    return
                }

                let updatedFetchedItems = fetchedItems + agendaItem.items
                if let nextPage = agendaItem.pagination.nextPage {
                    fetchAgendaItems(at: nextPage, fetchedItems: updatedFetchedItems, completionHandler: completionHandler)
                }
                else {
                    completionHandler(.success(updatedFetchedItems))
                }
            }
        }

        task.resume()
    }
}
