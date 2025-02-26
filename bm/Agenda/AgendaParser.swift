//
//  AgendaParser.swift
//  bm
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020-2024 Studio AMANgA. All rights reserved.
//

import Foundation

class AgendaParser {
    private static let AgendaWebpageURL = URL(string: "https://bm-grenoble.fr/Portal/Recherche/Search.svc/Search")!

    class func parseItems(jsonData: Data) -> [AgendaItem]? {
        let decoder = JSONDecoder()
        guard let response = try? decoder.decode(SearchResponse.self, from: jsonData) else {
            return nil
        }

        return response.d.Results.compactMap { result in
            guard let link = URL(string: result.FriendlyUrl) else {
                return nil
            }

            let imageURL: URL?
            if let image = result.CompactResult.parse(between: "<img src=\"", and: "\" class") {
                imageURL = URL(string: image)
            }
            else {
                imageURL = nil
            }

            let date: AgendaItem.AgendaDate?
            if let dateString = result.CustomResult.parse(between: "<span class=\"session-date\">", and: "</span>"),
               let dayComponents = dateString.parse(between: "Le ", and: " de ")?.components(separatedBy: "/"),
               let startHourComponents = dateString.parse(between: " de ", and: " à ")?.components(separatedBy: ":"),
               let endHourComponents = dateString.parse(after: " à ")?.components(separatedBy: ":"),
               dayComponents.count == 3, startHourComponents.count == 2, endHourComponents.count == 2 {
                var dateComponents = DateComponents()
                dateComponents.day = Int(dayComponents[0])
                dateComponents.month = Int(dayComponents[1])
                dateComponents.year = Int(dayComponents[2])
                dateComponents.hour = Int(startHourComponents[0])
                dateComponents.minute = Int(startHourComponents[1])
                var endDateComponents = dateComponents
                endDateComponents.hour = Int(endHourComponents[0])
                endDateComponents.minute = Int(endHourComponents[1])
                date = .range(dateComponents, endDateComponents)
            }
            else {
                date = nil
            }

            let summary = result.CustomResult.parse(between: "<p class=\"abstract short-abstract template-resume\">\r\n        ", and: "\r\n    </p>")
            let library = result.CustomResult.parse(between: "<span class=\"location\">", and: "</span>")

            return AgendaItem(title: result.Resource.Ttl, summary: summary, category: result.Resource.Subj, library: library, link: link, date: date, image: imageURL)
        }
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
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json, text/javascript, */*; q=0.01"
            ]
        request.httpBody = """
        {"query":{"InitialSearch":true,"Page":0,"PageRange":3,"QueryString":"*:*","ResultSize":-1,"ScenarioCode":"CALENDAR_ACTIONCULTURELLE-BM","SearchContext":0,"SearchLabel":"","Url":"https://bm-grenoble.fr/search.aspx?SC=CALENDAR_ACTIONCULTURELLE-BM&QUERY_LABEL=#/Search/(query:(InitialSearch:!t,Page:0,PageRange:3,QueryString:'*:*',ResultSize:-1,ScenarioCode:CALENDAR_ACTIONCULTURELLE-BM,SearchContext:0,SearchLabel:''))"},"sst":4}
        """.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async {
                guard let data,
                      let agendaItem = parseItems(jsonData: data) else {
                    if let networkError = error {
                        completionHandler(.failure(networkError))
                    }
                    else {
                        completionHandler(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                    }
                    return
                }

                // let path = NSTemporaryDirectory().appending("output.json")
                // try? data.write(to: URL(fileURLWithPath: path))

                completionHandler(.success(agendaItem))
            }
        }

        task.resume()
    }
}

struct SearchResponse: Codable {
    let d: SearchResponseD
}

struct SearchResponseD: Codable {
    let Results: [SearchResponseResult]
}

struct SearchResponseResult: Codable {
    let FriendlyUrl: String
    let CompactResult: String
    let CustomResult: String
    let Resource: SearchResponseResource
}

struct SearchResponseResource: Codable {
    let Ttl: String
    let Subj: String
}
