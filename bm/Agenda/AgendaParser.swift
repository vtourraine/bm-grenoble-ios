//
//  AgendaParser.swift
//  bm
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020-2024 Studio AMANgA. All rights reserved.
//

import Foundation

class AgendaParser {
    private static let AgendaWebpageURL = URL(string: "https://www.bm-grenoble.fr/Portal/recherche/openfind.svc/GetOpenFindSelectionRss?selectionUid=SELECTION_f5493341-0fec-496a-bbbf-c700d6e95e84")!

    struct Pagination {
        let nextPage: URL?
    }

    class func parseItems(rss: String) -> (items: [AgendaItem], pagination: Pagination)? {
        let parsedItems = rss.parseOccurences(between: "<item>", and: "</item>")
        let items: [AgendaItem] = parsedItems.compactMap({ parsedItem in
            return parseAgendaItem(html: parsedItem)
        })

        return (items: items, pagination: Pagination(nextPage: nil))
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
        guard let title = html.parse(between: "<title>", and: "</title>"),
              let desc = html.parse(between: "<description>", and: "</description>"),
              let link = html.parse(between: "<link>", and: "</link>"),
              let linkURL = URL(string: link) else {
            return nil
        }

        let categorie = desc.parse(between: "Catégorie&lt;/span&gt;&lt;/i&gt;", and: "&lt;")
        let library = desc.parse(between: "span class=\"location\"&gt;", and: "&lt;")
        let dateString = desc.parse(between: "session-date\"&gt;Le ", and: " de ")
        let resume = desc.parse(between: "short-abstract template-resume\"&gt;&#xD;", and: "&#xD;")?.trimmingCharacters(in: .whitespacesAndNewlines)

        let image: URL?
        if let enclosure = html.parse(between: "<enclosure", and: "/>"),
           let imageURLString = enclosure.parse(between: "url=\"", and: "\"") {
            image = URL(string: imageURLString)
        }
        else {
            image = nil
        }

        let date: AgendaItem.AgendaDate?
        if let comps = dateString?.components(separatedBy: "/"),
           comps.count == 3 {
            let year = Int(comps[2])
            let month = Int(comps[1])
            let day = Int(comps[0])
            date = .day(DateComponents(year: year, month: month, day: day))
        }
        else {
            date = nil
        }

        return AgendaItem(title: title, summary: resume, category: categorie ?? "", library: library, link: linkURL, date: date, image: image)
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
                guard let data,
                      let string = String(data: data, encoding: .utf8),
                      let agendaItem = parseItems(rss: string) else {
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
