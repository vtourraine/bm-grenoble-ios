//
//  NewsParser.swift
//  bm
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

class NewsParser {
    private static let LinkRoot = "https://www.bm-grenoble.fr"
    private static let NewsWebpageURL = URL(string: "https://www.bm-grenoble.fr/692-actualite.htm?TPL_CODE=TPL_ACTUALITELISTE")!

    class func parseNewsItems(html: String) -> [NewsItem]? {
        let parsedItems = html.parseOccurences(between: "<div class=\"item\">", and: "</div>")
        let items: [NewsItem] = parsedItems.compactMap({ parsedItem in
            return parseNewsItem(html: parsedItem)
        })

        return items
    }

    private class func parseNewsItem(html: String) -> NewsItem? {
        guard let linkString = html.parse(between: "<a href=\"", and: "\">"),
            let link = URL(string: "\(NewsParser.LinkRoot)\(linkString)"),
            let title = html.parseOccurences(between: "\(linkString)\">", and: "</a>").last?.cleanHTMLEntities(),
            let summary = html.parse(between: "<p>", and: "</p>")?.cleanHTMLEntitiesAndTags() else {
            return nil
        }

        let image: URL?
        if let imageString = html.parse(between: "<img src=\"", and: "\""),
            let imageURL = URL(string: "\(NewsParser.LinkRoot)\(imageString)") {
            image = imageURL
        }
        else {
            image = nil
        }

        return NewsItem(title: title, summary: summary, link: link, image: image)
    }

    class func fetchNewsItems(completionHandler: @escaping (Result<[NewsItem], Error>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: NewsWebpageURL) {(data, response, error) in
            DispatchQueue.main.async {
                guard let data = data,
                    let string = String(data: data, encoding: .utf8),
                    let newsItem = parseNewsItems(html: string) else {
                        if let networkError = error {
                            completionHandler(.failure(networkError))
                        }
                        else {
                            completionHandler(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                        }
                        return
                }

                completionHandler(.success(newsItem))
            }
        }

        task.resume()
        return task
    }
}
