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
            AgendaParser.fetchAgendaItems { result in
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

        #if targetEnvironment(macCatalyst)
        tableView.deselectRow(at: indexPath, animated: true)
        #endif
    }

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = agendaItems[indexPath.row]

        #if targetEnvironment(macCatalyst)
        #else
        let openInBrowserAction = UIAction(title: NSLocalizedString("Open in Browser", comment: ""), image: UIImage(systemName: "safari")) { (action) in
            UIApplication.shared.open(item.link, options: [:], completionHandler: nil)
        }
        #endif

        let shareAction = UIAction(title: NSLocalizedString("Share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { (action) in
            let viewController = UIActivityViewController(activityItems: [item.link], applicationActivities: nil)
            viewController.popoverPresentationController?.sourceView = tableView
            viewController.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            self.present(viewController, animated: true, completion: nil)
        }

        #if targetEnvironment(macCatalyst)
        let children = [shareAction]
        #else
        let children = [openInBrowserAction, shareAction]
        #endif

        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ -> UIMenu? in
            return UIMenu(title: "", children: children)
        })
        return configuration
    }
}
