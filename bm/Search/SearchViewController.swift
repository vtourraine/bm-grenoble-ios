//
//  SearchViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 01/10/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var closeButton: UIButton?
    @IBOutlet var searchButton: UIButton?
    @IBOutlet var searchBar: UISearchBar?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private struct K {
        struct ViewControllerIdentifiers {
            static let searchResults = "SearchResultsViewController"
        }
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar?.configureRoundCorners()
        if let searchBar = searchBar {
            searchBar.layer.cornerRadius = (searchBar.frame.size.height / 2)
        }

        if #available(iOS 13.0, *) {
            searchBar?.searchTextField.backgroundColor = .white
            searchBar?.searchTextField.textColor = .black
            searchBar?.overrideUserInterfaceStyle = .light
        }

        searchBar?.backgroundColor = .white
        searchBar?.backgroundImage = UIImage()
        searchBar?.isTranslucent = true
        searchButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        searchButton?.configureRoundCorners()

        closeButton?.configureCloseButton()

        let guide = view.readableContentGuide
        if let searchButton = searchButton {
            guide.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor).isActive = true
            guide.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor).isActive = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        configureOutlets(enabled: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // searchBar?.becomeFirstResponder()
    }

    // MARK: - Configuration

    func configureOutlets(enabled: Bool) {
        if #available(iOS 13.0, *) {
            searchBar?.searchTextField.isEnabled = enabled
        }

        searchButton?.isEnabled = enabled
        searchButton?.titleLabel?.alpha = enabled ? 1.0 : 0.5
    }

    func showNoSearchResults() {
        let alert = UIAlertController(title: NSLocalizedString("No Result Found", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showSearchError(error: Error) {
        presentError(error, theme: .error, title: NSLocalizedString("Search Error", comment: ""))
    }

    // MARK: - Actions

    @IBAction func search(_ sender: Any?) {
        guard let searchBar = searchBar else {
            return
        }

        searchBar.resignFirstResponder()

        guard let trimmedQuery = searchBar.text?.trimmingCharacters(in: .whitespaces),
            trimmedQuery.isEmpty == false else {
                return
        }

        // TODO: check it works
        /*
        if let session = Session.sharedSession() {
            configureOutlets(enabled: false)
            search(for: trimmedQuery, with: session.settingsToken)
        }
        else {
         */
            let urlSession = URLSession.shared
            _ = urlSession.fetchSettings { result in
                switch result {
                case .success(let token):
                    self.search(for: trimmedQuery, with: token)

                case .failure(let error):
                    self.configureOutlets(enabled: true)
                    self.showSearchError(error: error)
                }
            }
        /*
        }
         */
    }

    func search(for query: String, with token: String) {
        let urlSession = URLSession.shared

        _ = urlSession.search(for: query, with: token) { result in
            switch result {
            case .success(let response):
                guard !response.documents.isEmpty else {
                    self.configureOutlets(enabled: true)
                    self.showNoSearchResults()
                    return
                }

                let documentsIdentifiers = response.documents.map { $0.identifier }

                _ = urlSession.stockAvailability(for: documentsIdentifiers, with: token) { stockAvailabilityResult in
                    switch stockAvailabilityResult {
                    case .success(let availability):
                        self.presentSearchResults(query: query, token: token, response: response, availability: availability)

                    case .failure(let stockAvailabilityResultError):
                        self.configureOutlets(enabled: true)
                        self.showSearchError(error: stockAvailabilityResultError)
                    }
                }

            case .failure(let error):
                self.configureOutlets(enabled: true)
                self.showSearchError(error: error)
            }
        }
    }

    func presentSearchResults(query: String, token: String, response: DocumentResponse, availability: StockAvailabilityResponse) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: K.ViewControllerIdentifiers.searchResults) as? SearchResultsViewController else {
            return
        }

        viewController.title = String(format: NSLocalizedString("Search Results for “%@”", comment: ""), query)
        viewController.configure(with: response, availabilityResponse: availability)
        viewController.query = query
        viewController.token = token

        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func resignSearchField(_ sender: Any?) {
        searchBar?.resignFirstResponder()
    }

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Search bar delegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(nil)
    }
}

extension SearchViewController {
    static func searchResults(with documents: [Document], availability: StockAvailabilityResponse) -> [SearchResult]? {
        var results = [SearchResult]()
        for document in documents {
            guard let stock = availability[document.identifier] else {
                return nil
            }

            results.append(SearchResult(document: document, availability: stock))
        }

        return results
    }
}
