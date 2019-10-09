//
//  ViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

import WebKit

class ViewController: UITableViewController {

    var loans: [Item] = []
    var loader: GhostLoader?
    var isFirstLaunch = true
    var lastRefreshDate: Date?

    let LoginSegueIdentifier = "Login"
    let CardSegueIdentifier = "Card"
    let AboutSegueIdentifier = "About"
    let LibrariesSegueIdentifier = "Libraries"
    let SearchSegueIdentifier = "Search"

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(openAboutScreen(sender:)), for: .touchUpInside)
        let MinimumTargetSize: CGFloat = 44
        infoButton.frame = CGRect(x: 0, y: 0, width: MinimumTargetSize, height: MinimumTargetSize)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)

        let librariesBarButtonItem: UIBarButtonItem
        let searchBarButtonItem: UIBarButtonItem
        if #available(iOS 13.0, *) {
            librariesBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(presentLibrariesScreen(sender:)))
            searchBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(presentSearchScreen(sender:)))
        }
        else {
            librariesBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Libraries", comment: ""), style: .plain, target: self, action: #selector(presentLibrariesScreen(sender:)))
            searchBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Search", comment: ""), style: .plain, target: self, action: #selector(presentSearchScreen(sender:)))
        }

        // navigationItem.rightBarButtonItems = [infoBarButtonItem, librariesBarButtonItem, searchBarButtonItem]
        navigationItem.rightBarButtonItem = infoBarButtonItem

        refreshControl?.tintColor = .white

        tableView.tableFooterView = UIView(frame: CGRect.zero)

        if let itemCache = ItemCache.load(from: .standard) {
            reloadData(loans: itemCache.items)
        }

        navigationController?.configureCustomAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstLaunch {
            if Credentials.load(from: .standard) == nil {
                presentLoginScreen(sender: nil)
            }
            else {
                refresh(sender: nil)
            }

            isFirstLaunch = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func reloadData(loans: [Item]) {
        self.loans = loans
        tableView.reloadData()

        if loans.isEmpty {
            let label = UILabel(frame: .zero)
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.textColor = .gray
            label.textAlignment = .center
            label.text = NSLocalizedString("No Current Loans", comment: "")
            tableView.backgroundView = label
        }
        else {
            tableView.backgroundView = nil
        }
    }

    func configureToolbar(message: String?, animated: Bool) {
        guard let message = message else {
            navigationController?.setToolbarHidden(true, animated: animated)
            return
        }

        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let label = UILabel(frame: .zero)
        label.text = message
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        let labelItem = UIBarButtonItem(customView: label)
        setToolbarItems([spaceItem, labelItem, spaceItem], animated: false)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    // MARK: - Actions

    @objc func openAboutScreen(sender: Any) {
        self.performSegue(withIdentifier: self.AboutSegueIdentifier, sender: nil)
    }

    @IBAction func refresh(sender: Any?) {
        guard loader == nil, let credentials = Credentials.load(from: .standard) else {
            return
        }

        configureToolbar(message: NSLocalizedString("Updating Account…", comment: ""), animated: false)

        loader = GhostLoader(credentials: credentials, parentView: view, success: { (items) in
            self.reloadData(loans: items)
            let itemCache = ItemCache(items: self.loans)
            ItemCache.save(items: itemCache, to: .standard)

            self.refreshControl?.endRefreshing()
            self.configureToolbar(message: nil, animated: true)
            self.loader = nil
            self.lastRefreshDate = Date()
        }) { (error) in
            self.presentLoadingError(error)
            self.refreshControl?.endRefreshing()
            self.configureToolbar(message: nil, animated: true)
            self.loader = nil
        }
    }

    func refreshIfNecessary() {
        guard let lastRefreshDate = lastRefreshDate else {
            return
        }

        // Refresh every hour
        let minimumRefreshInterval: TimeInterval = (60 * 60)
        if lastRefreshDate.timeIntervalSinceNow < -minimumRefreshInterval {
            refresh(sender: nil)
        }
    }

    @objc func presentLoginScreen(sender: Any?) {
        performSegue(withIdentifier: LoginSegueIdentifier, sender: sender)
    }

    @objc func presentLibrariesScreen(sender: Any?) {
        performSegue(withIdentifier: LibrariesSegueIdentifier, sender: sender)
    }

    @objc func presentSearchScreen(sender: Any?) {
        performSegue(withIdentifier: SearchSegueIdentifier, sender: sender)
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        let item = loans[indexPath.row]
        cell.configure(item: item)
        return cell
    }
}

extension UINavigationController {
    func configureCustomAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            var largeTitleTextAttributes = appearance.largeTitleTextAttributes
            largeTitleTextAttributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 34)
            largeTitleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
            appearance.largeTitleTextAttributes = largeTitleTextAttributes
            appearance.backgroundColor = UIColor(named: "BMRed")
            navigationBar.tintColor = UIColor.white
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
        }
    }
}
