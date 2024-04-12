//
//  AgendaViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 25/01/2020.
//  Copyright © 2020-2024 Studio AMANgA. All rights reserved.
//

import UIKit
import MobileCoreServices
import EventKitUI

class AgendaViewController: UITableViewController {

    var agendaItems = [AgendaItem]()
    var isFirstLaunch = true
    var filterTitle: String?
    lazy var eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.tintColor = .white
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
            refresh(sender: nil)
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

    @IBAction func refresh(sender: Any?) {
        AgendaParser.fetchAgendaItems { result in
            self.refreshControl?.endRefreshing()

            switch (result) {
            case .success(let items):
                AgendaItemCache.save(items: items, to: .standard)
                self.filter(with: self.filterTitle)

            case .failure(let error):
                self.presentLoadingError(error)
            }
        }
    }

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

    func addToCalendar(_ item: AgendaItem) {
        let grantAccessCompletion: EKEventStoreRequestAccessCompletionHandler = { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.presentAddToCalendarViewController(item)
                }
                else {
                    self.presentError(error, title: NSLocalizedString("Cannot Add Event", comment: ""))
                }
            }
        }

        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            if #available(iOS 17.0, *) {
                eventStore.requestWriteOnlyAccessToEvents(completion: grantAccessCompletion)
            }
            else {
                eventStore.requestAccess(to: .event, completion: grantAccessCompletion)
            }
        case .restricted, .denied:
            presentError(title: NSLocalizedString("Cannot Add Event", comment: ""), body: NSLocalizedString("Please authorize calendar access in Settings.", comment: ""))
        case .authorized, .fullAccess, .writeOnly:
            presentAddToCalendarViewController(item)
        @unknown default:
            break
        }
    }

    func presentAddToCalendarViewController(_ item: AgendaItem) {
        let viewController = EKEventEditViewController()
        viewController.editViewDelegate = self
        let event = EKEvent(eventStore: eventStore)
        event.title = item.title
        event.notes = item.summary
        event.location = item.library
        event.url = item.link
        if case let .range(startDate, endDate) = item.date {
            let calendar = Calendar.current
            event.startDate = calendar.date(from: startDate)
            event.endDate = calendar.date(from: endDate)
        }
        viewController.event = event
        present(viewController, animated: true)
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

#if targetEnvironment(macCatalyst)
        UIApplication.shared.open(item.link)
#else
        presentSafariViewController(item.link, readerMode: true)
#endif

        #if targetEnvironment(macCatalyst)
        tableView.deselectRow(at: indexPath, animated: true)
        #endif
    }

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = agendaItems[indexPath.row]
        var children = [UIMenuElement]()

#if targetEnvironment(macCatalyst)
#else
        children.append(UIAction(title: NSLocalizedString("Open in Browser", comment: ""), image: UIImage(systemName: "safari")) { (action) in
            UIApplication.shared.open(item.link, options: [:], completionHandler: nil)
        })
#endif

        if #available(iOS 4.0, macCatalyst 13.1, *) {
            children.append(UIAction(title: NSLocalizedString("Add to Calendar", comment: ""), image: UIImage(systemName: "calendar.badge.plus")) { (action) in
                self.addToCalendar(item)
            })
        }

        children.append(UIAction(title: NSLocalizedString("Share", comment: ""), image: UIImage(systemName: "square.and.arrow.up")) { (action) in
            let viewController = UIActivityViewController(activityItems: [item.link], applicationActivities: nil)
            viewController.popoverPresentationController?.sourceView = tableView
            viewController.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            self.present(viewController, animated: true, completion: nil)
        })

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

extension AgendaViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            dismiss(animated: true, completion: nil)
    }
}
