//
//  SearchResultsViewController.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 08/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class SearchResultsViewController: UITableViewController {

    var documents: [Document]

    private struct K {
        static let cellIdentifier = "Cell"
    }

    // MARK: - Initializers

    init(with documents: [Document]) {
        self.documents = documents

        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Search Results", comment: "")

        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: K.cellIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SearchResultsCell
        let document = documents[indexPath.row]
        cell.configure(with: document)

        return cell
    }
}
