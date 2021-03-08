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

    var searchResults: [SearchResult] = []

    private struct K {
        static let cellIdentifier = "Cell"
    }

    // MARK: - View life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SearchResultsCell
        let searchResult = searchResults[indexPath.row]
        cell.configure(with: searchResult)
        
        return cell
    }
}
