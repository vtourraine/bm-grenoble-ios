//
//  SearchViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 01/10/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit
import SafariServices

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
            searchBar?.searchTextField.backgroundColor = .systemBackground
            searchBar?.backgroundColor = .systemBackground
        }
        else {
            searchBar?.searchTextField.backgroundColor = .white
            searchBar?.backgroundColor = .white
        }

        searchBar?.backgroundImage = UIImage()
        searchBar?.isTranslucent = true

        searchButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        searchButton?.configureRoundCorners()

        closeButton?.configureCloseButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchBar?.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction func search(_ sender: Any?) {
        guard let searchBar = searchBar,
            let query = searchBar.text,
            let formattedQuery = query.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
        }

        searchBar.resignFirstResponder()

        let urlString = "http://catalogue.bm-grenoble.fr/in/faces/browse.xhtml?query=\(formattedQuery)"

        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url)
            present(viewController, animated: true, completion: nil)
        }
    }

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Search bar delegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(nil)
    }
}
