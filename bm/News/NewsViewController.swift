//
//  NewsViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController {

    var newsItems = [NewsItem]()
    var networkTask: URLSessionDataTask?
    var isFirstLaunch = true

    override func viewDidLoad() {
        super.viewDidLoad()

        if let cachedItems = NewsItemCache.load(from: .standard) {
            newsItems = cachedItems.items
        }

        navigationController?.configureCustomAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstLaunch {
            networkTask = NewsParser.fetchNewsItems { result in
                switch (result) {
                case .success(let items):
                    self.newsItems = items
                    self.tableView.reloadData()

                    NewsItemCache.save(items: items, to: .standard)

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
        return newsItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        let item = newsItems[indexPath.row]
        cell.configure(item: item)
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = newsItems[indexPath.row]
        presentSafariViewController(item.link, readerMode: true)

        #if targetEnvironment(macCatalyst)
        tableView.deselectRow(at: indexPath, animated: true)
        #endif
    }

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = newsItems[indexPath.row]

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
