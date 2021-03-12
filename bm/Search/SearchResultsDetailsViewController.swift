//
//  SearchResultsDetailsViewController.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 12/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class SearchResultsDetailsViewController: UITableViewController {

    var searchResult: SearchResult?
    var token: String?
    var notices: [Notice] = []

    private struct K {
        struct CellIdentifier {
            static let document = "DocumentCell"
            static let notice = "NoticeCell"
        }
    }

    private enum Section: Int, CaseIterable {
        case document
        case availability
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Document", comment: "")

        tableView.tableFooterView = UIView(frame: .zero)

        if let searchResult = searchResult,
           let token = token {
        let urlSession = URLSession.shared
            _ = urlSession.fetchNotice(searchResult.document.identifier, with: token) { result in
                switch result {
                case .success(let notices):
                    self.notices = notices
                    self.tableView.reloadData()

                case .failure(let error):
                    break
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .document:
            return 1
        case .availability:
            return notices.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .availability:
            return NSLocalizedString("Where to find it?", comment: "")
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .availability:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.notice, for: indexPath)
            let notice = notices[indexPath.row]
            cell.textLabel?.text = notice.branch
            cell.detailTextLabel?.text = notice.status

            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.document, for: indexPath) as! SearchResultsCell

            if let searchResult = searchResult {
                cell.configure(with: searchResult)
            }

            return cell
        }
    }
}
