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

        searchBar?.searchTextField.backgroundColor = .white
        searchBar?.searchTextField.textColor = .black
        searchBar?.backgroundColor = .white
        searchBar?.backgroundImage = UIImage()
        searchBar?.isTranslucent = true
        searchButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        searchButton?.configureRoundCorners()

        closeButton?.configureCloseButton()
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

        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces),
            query.isEmpty == false,
            let formattedQuery = query.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
        }

        let urlString = "http://catalogue.bm-grenoble.fr/in/faces/browse.xhtml?query=\(formattedQuery)"

        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url)
            present(viewController, animated: true, completion: nil)
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
