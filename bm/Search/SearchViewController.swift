//
//  SearchViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 01/10/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

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

        let urlString = "https://catalogue.bm-grenoble.fr/query?q=\(encodedQuery)"

        if let url = URL(string: urlString) {
            presentSafariViewController(url)
        }
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
