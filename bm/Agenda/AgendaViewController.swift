//
//  AgendaViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 25/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import UIKit

class AgendaViewController: UITableViewController {

    var agendaItems = [AgendaItem]()
    var networkTask: URLSessionDataTask?
    var isFirstLaunch = true

    override func viewDidLoad() {
        super.viewDidLoad()

        if let cachedItems = AgendaItemCache.load(from: .standard) {
            agendaItems = cachedItems.items
        }

        navigationController?.configureCustomAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstLaunch {
            networkTask = AgendaParser.fetchAgendaItems { result in
                switch (result) {
                case .success(let items):
                    self.agendaItems = items
                    self.tableView.reloadData()

                    AgendaItemCache.save(items: items, to: .standard)

                case .failure:
                    break
                }
            }

            isFirstLaunch = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agendaItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AgendaTableViewCell
        let item = agendaItems[indexPath.row]
        cell.configure(item: item)
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = agendaItems[indexPath.row]
        presentSafariViewController(item.link, readerMode: true)
    }
}
