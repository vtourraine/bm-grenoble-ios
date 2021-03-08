//
//  SearchViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 01/10/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class SearchEngine {
    static func encodedQuery(for query: String) -> String? {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+")
        return formattedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var closeButton: UIButton?
    @IBOutlet var searchButton: UIButton?
    @IBOutlet var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar?.configureRoundCorners()
        if let searchBar = searchBar {
            searchBar.layer.cornerRadius = (searchBar.frame.size.height / 2)
        }

        if #available(iOS 13.0, *) {
            searchBar?.searchTextField.backgroundColor = .white
            searchBar?.searchTextField.textColor = .black
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // searchBar?.becomeFirstResponder()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions

    @IBAction func search(_ sender: Any?) {
        guard let searchBar = searchBar else {
            return
        }

        searchBar.resignFirstResponder()

        guard let trimmedQuery = searchBar.text?.trimmingCharacters(in: .whitespaces),
            trimmedQuery.isEmpty == false,
            let encodedQuery = SearchEngine.encodedQuery(for: trimmedQuery) else {
                return
        }

        guard let credentials = Credentials.sharedCredentials() else {
            return
        }
        
        _ = URLSession.shared.search(for: trimmedQuery, with: credentials) { result in
            switch result {
            case .success(let documents):
                if documents.isEmpty {
                    let alert = UIAlertController(title: NSLocalizedString("No Result Found", comment: ""), message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let viewController = SearchResultsViewController(with: documents)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }

            case .failure(let error):
                let alert = UIAlertController(title: NSLocalizedString("Search Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
//        let urlString = "https://catalogue.bm-grenoble.fr/query?q=\(encodedQuery)"
//
//        if let url = URL(string: urlString) {
//            presentSafariViewController(url)
//        }
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
