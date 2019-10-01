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
    @IBOutlet var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar?.configureRoundCorners()
        searchBar?.backgroundColor = UIColor.clear
        searchBar?.backgroundImage = UIImage()
        searchBar?.isTranslucent = true

        closeButton?.configureCloseButton()
    }

    // MARK: - Actions

    @IBAction func search(_ sender: Any?) {
        guard let searchBar = searchBar, let query = searchBar.text else {
            return
        }

        searchBar.resignFirstResponder()
        let urlString = "http://catalogue.bm-grenoble.fr/in/faces/browse.xhtml?query=\(query)"

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
