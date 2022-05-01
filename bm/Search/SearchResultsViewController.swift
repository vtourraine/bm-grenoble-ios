//
//  SearchResultsViewController.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 08/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

struct SearchResult {
    let document: Document
    let availability: StockAvailability
}

class SearchResultsViewController: UITableViewController {

    var query: String? = nil
    var token: String? = nil
    var searchResults: [SearchResult] = []
    var showLoadMoreResults = false
    var nextPageIndex: Int? = nil

    private struct K {
        struct CellIdentifier {
            static let document = "DocumentCell"
            static let loadMore = "ActionCell"
        }
    }

    private enum Section: Int, CaseIterable {
        case documents
        case loadMore
    }

    // MARK: - View life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SearchResultsDetailsViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let searchResult = searchResults[indexPath.row]
            viewController.searchResult = searchResult
            viewController.token = token
        }
    }

    // MARK: - Actions

    func loadNextPage() {
        guard let token = token,
              let nextPageIndex = nextPageIndex,
              let query = query else {
            return
        }

        let urlSession = URLSession.shared

        _ = urlSession.search(for: query, with: token, pageIndex: nextPageIndex) { result in
            switch result {
            case .success(let response):
                let documentsIdentifiers = response.documents.map { $0.identifier }

                _ = urlSession.stockAvailability(for: documentsIdentifiers, with: token) { stockAvailabilityResult in
                    switch stockAvailabilityResult {
                    case .success(let availability):
                        let lowerRange = self.searchResults.count

                        self.configure(with: response, availabilityResponse: availability)

                        let upperRange = self.searchResults.count
                        let newIndexPaths = (lowerRange..<upperRange).map { IndexPath(row: $0, section: Section.documents.rawValue) }

                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: newIndexPaths, with: .top)
                        if !self.showLoadMoreResults {
                            let loadMoreIndexPath = IndexPath(row: 0, section: Section.loadMore.rawValue)
                            self.tableView.deleteRows(at: [loadMoreIndexPath], with: .automatic)
                        }
                        self.tableView.endUpdates()

                    case .failure(let stockAvailabilityResultError):
                        self.showSearchError(error: stockAvailabilityResultError)
                    }
                }

            case .failure(let error):
                self.showSearchError(error: error)
            }
        }
    }

    func configure(with documentResponse: DocumentResponse, availabilityResponse: StockAvailabilityResponse) {
        guard let newSearchResults = SearchViewController.searchResults(with: documentResponse.documents, availability: availabilityResponse) else {
            return
        }

        searchResults.append(contentsOf: newSearchResults)
        showLoadMoreResults = (documentResponse.pageIndex < documentResponse.pagesCount)
        if showLoadMoreResults {
            nextPageIndex = documentResponse.pageIndex + 1
        }
    }

    func showSearchError(error: Error) {
        presentError(error, theme: .error, title: NSLocalizedString("Search Error", comment: ""))
    }

    func open(_ document: Document) {
        var urlComponents = URLComponents(string: "https://catalogue.bm-grenoble.fr/notice")!
        urlComponents.queryItems = [URLQueryItem(name: "id", value: document.identifier)]
        if let url = urlComponents.url {
            presentSafariViewController(url)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .documents:
            return searchResults.count
        case .loadMore:
            return showLoadMoreResults ? 1 : 0
        case .none:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .documents:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.document, for: indexPath) as! SearchResultsCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(with: searchResult)
            return cell

        case .loadMore:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.loadMore, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Load More Results", comment: "")
            return cell

        case .none:
            fatalError()
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .loadMore:
            tableView.deselectRow(at: indexPath, animated: true)
            loadNextPage()

        case .documents, .none:
            break
        }
    }
}
