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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = newsItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.summary
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = newsItems[indexPath.row]
        presentSafariViewController(item.link)
    }
}
