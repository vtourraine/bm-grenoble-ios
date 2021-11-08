//
//  AgendaViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 25/01/2020.
//  Copyright © 2020-2021 Studio AMANgA. All rights reserved.
//

import UIKit
import MobileCoreServices

class AgendaViewController: UITableViewController {

    var agendaItems = [AgendaItem]()
    var isFirstLaunch = true
    var filterTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dragDelegate = self

        if let cachedItems = AgendaItemCache.load(from: .standard) {
            agendaItems = cachedItems.items
        }

        navigationController?.configureCustomAppearance()

        updateFilterButton()
    }

    func updateFilterButton() {
        if #available(iOS 14.0, *) {
            let image = UIImage(systemName: filterTitle == nil ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
            let item = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)

            let libraries = librariesWithItems()
            var items = [UIAction]()

            for library in libraries {
                let action = UIAction(title: library) { _ in
                    if library == self.filterTitle {
                        self.resetFilter()
                    }
                    else {
                        self.filter(with: library)
                    }
                }

                if library == filterTitle {
                    action.state = .on
                }
                else {
                    action.state = .off
                }

                items.append(action)
            }

            item.menu = UIMenu(title: "", image: nil, children: items)

            navigationItem.rightBarButtonItem = item
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstLaunch {
            AgendaParser.fetchAgendaItems { result in
                switch (result) {
                case .success(let items):
                    AgendaItemCache.save(items: items, to: .standard)

                    self.filter(with: self.filterTitle)

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

    // MARK: - Data

    func librariesWithItems() -> [String] {
        guard let cachedItems = AgendaItemCache.load(from: .standard) else {
            return []
        }

        var libraries = [String]()

        for item in cachedItems.items {
            if let itemLibrary = item.library, !libraries.contains(itemLibrary), itemLibrary.count > 0 {
                libraries.append(itemLibrary)
            }
        }

        return libraries
    }

    // MARK: - Actions

    func resetFilter() {
        guard let cachedItems = AgendaItemCache.load(from: .standard) else {
            return
        }

        agendaItems = cachedItems.items
        filterTitle = nil
        tableView.reloadData()
        updateFilterButton()
    }

    func filter(with libraryName: String?) {
        if libraryName == nil {
            resetFilter()
            return
        }

        guard let cachedItems = AgendaItemCache.load(from: .standard) else {
            return
        }

        agendaItems = cachedItems.items.filter({ item in
            return item.library == libraryName
        })

        filterTitle = libraryName
        tableView.reloadData()
        updateFilterButton()
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        filterTitle
    }

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

extension AgendaViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: indexPath)
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let item = agendaItems[indexPath.row]
        let itemProvider = NSItemProvider(item: item.link as NSURL, typeIdentifier: kUTTypeURL as String)
        return [UIDragItem(itemProvider: itemProvider)]
    }
}
