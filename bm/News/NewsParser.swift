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
            guard let linkString = parsedItem.parse(between: "<a href=\"", and: "\">"),
                let link = URL(string: "\(NewsParser.LinkRoot)\(linkString)"),
                let title = parsedItem.parseOccurences(between: "\(linkString)\">", and: "</a>").last?.cleanHTMLEntities(),
                let summary = parsedItem.parse(between: "<p>", and: "</p>")?.cleanHTMLEntities().replacingOccurrences(of: "<br>", with: "").replacingOccurrences(of: "\r", with: "") else {
                return nil
            }

            return NewsItem(title: title, summary: summary, link: link)
        })

        return items
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
