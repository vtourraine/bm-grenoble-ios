//
//  ViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/07/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import BMKit

class LoansViewController: UITableViewController {

    enum State {
        case loans([Item])
        case notLoggedIn
    }

    enum Section: Int, CaseIterable {
        case loans = 0
    }

    var state: State = .notLoggedIn
    var loader: GhostLoader?
    var lastRefreshDate: Date?
    weak var refreshLabel: UILabel?
    weak var refreshButton: UIButton?
    var retryCount = 0

    private struct K {
        struct CellIdentifier {
            static let loan = "Cell"
        }

        struct SegueIdentifier {
            static let login = "Login"
            static let card = "Card"
            static let about = "About"
            static let libraries = "Libraries"
            static let search = "Search"
        }
    }

    let LoansNotLoggedInViewXIB = "LoansNotLoggedInView"

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true
        refreshControl?.tintColor = .white

        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .systemBackground
        }
        tableView.tableFooterView = UIView(frame: .zero)

        if Credentials.sharedCredentials() == nil {
            reloadData(state: .notLoggedIn)
        }
        else {
            if let itemCache = ItemCache.load(from: .standard) {
                reloadData(state: .loans(itemCache.items))
            }
            else {
                configureBarButtonItems(userLoggedIn: true)
            }

            refresh(sender: nil)
        }

        navigationController?.configureCustomAppearance()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let aboutViewController = segue.destination as? AboutViewController {
            let userIsLoggedIn = (Credentials.sharedCredentials() != nil)
            aboutViewController.userIsLoggedIn = userIsLoggedIn
        }
    }

    func configureNotLoggedInPlaceholder() {
        if let placeholderView = Bundle.main.loadNibNamed(LoansNotLoggedInViewXIB, owner: self, options: nil)?.first as? UIView {
            for subview in placeholderView.subviews {
                if let button = subview as? UIButton {
                    button.configureRoundCorners()
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                }
            }
            tableView.backgroundView = placeholderView
        }
    }

    func configureEmptyListPlaceholder() {
        let label1 = UILabel(frame: .zero)
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.font = .preferredFont(forTextStyle: .title1)
        if #available(iOS 13.0, *) {
            label1.textColor = .secondaryLabel
        } else {
            label1.textColor = .gray
        }
        label1.textAlignment = .center
        label1.text = NSLocalizedString("No Current Loans", comment: "")
        label1.numberOfLines = 0
        label1.adjustsFontSizeToFitWidth = true

        let label2 = UILabel(frame: .zero)
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.font = .preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            label2.textColor = .secondaryLabel
        } else {
            label2.textColor = .gray
        }
        label2.textAlignment = .center
        label2.text = NSLocalizedString("You might need to refresh your account to see your current loans.", comment: "")
        label2.numberOfLines = 0
        label2.adjustsFontSizeToFitWidth = true

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Refresh", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(refresh(sender: )), for: .touchUpInside)

        let backgroundView = UIView(frame: .zero)
        backgroundView.addSubview(label1)
        backgroundView.addSubview(label2)
        backgroundView.addSubview(button)
        backgroundView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: label1.leadingAnchor).isActive = true
        backgroundView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: label1.trailingAnchor).isActive = true
        backgroundView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: label2.leadingAnchor).isActive = true
        backgroundView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: label2.trailingAnchor).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true

        label1.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 20).isActive = true
        button.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 20).isActive = true

        tableView.backgroundView = backgroundView
        refreshButton = button
        refreshLabel = label2
    }

    func reloadData(state: State) {
        // loadDemoData()
        // return;

        self.state = state
        tableView.reloadData()

        switch state {
        case .loans(let items):
            if items.isEmpty {
                configureEmptyListPlaceholder()
            }
            else {
                tableView.backgroundView = nil
            }
            configureBarButtonItems(userLoggedIn: true)
            NotificationManager.scheduleNotifications(for: items)

        case .notLoggedIn:
            configureNotLoggedInPlaceholder()
            configureBarButtonItems(userLoggedIn: false)
        }
    }

    func loadDemoData() {
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 4
        dateComponents.day = 15

        let items = [
            Item(identifier: "", isRenewable: false, title: "Sous le même ciel", type: "Books", author: "Britta Teckentrup", library: "Eaux Claires", returnDateComponents: dateComponents, image: URL(string: "https://images-na.ssl-images-amazon.com/images/I/81I38liMXCL.jpg")!),
            Item(identifier: "", isRenewable: false, title: "A la recherche de Calvin et Hobbes : catalogue de l'exposition", type: "Books", author: "Bill Watterson", library: "Centre Ville", returnDateComponents: dateComponents, image: URL(string: "https://products-images.di-static.com/image/bill-watterson-a-la-recherche-de-calvin-et-hobbes/9782258117389-475x500-1.jpg")!),
            Item(identifier: "", isRenewable: false, title: "Little Fires Everywhere", type: "Books", author: "Celeste Ng", library: "Bibliothèque municipale internationale", returnDateComponents: dateComponents, image: URL(string: "https://images-na.ssl-images-amazon.com/images/I/81wScwlTchL.jpg")!),
            Item(identifier: "", isRenewable: false, title: "Hilda et le chien noir", type: "Books", author: "Luke Pearson", library: "Jardin de Ville", returnDateComponents: dateComponents, image: URL(string: "https://www.casterman.com/media/cache/couverture_large/casterman_img/Couvertures/9782203097223.jpg")!)]

        state = .loans(items)
        tableView.reloadData()
    }

    func item(at indexPath: IndexPath) -> Item? {
        guard indexPath.section == Section.loans.rawValue else {
            return nil
        }

        switch state {
        case .loans(let items):
            return items[indexPath.row]

        default:
            return nil
        }
    }

    func configureBarButtonItems(userLoggedIn: Bool) {
        #if !targetEnvironment(macCatalyst)
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(openAboutScreen(sender:)), for: .touchUpInside)
        let MinimumTargetSize: CGFloat = 44
        infoButton.frame = CGRect(x: 0, y: 0, width: MinimumTargetSize, height: MinimumTargetSize)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)

        if userLoggedIn {
            let cardBarButtonItem: UIBarButtonItem
            if #available(iOS 13.0, *) {
                cardBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "creditcard"), style: .plain, target: self, action: #selector(openCardScreen(sender:)))
            }
            else {
                cardBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Card", comment: ""), style: .plain, target: self, action: #selector(openCardScreen(sender:)))
            }

            navigationItem.rightBarButtonItems = [infoBarButtonItem, cardBarButtonItem]
        }
        else {
            navigationItem.rightBarButtonItems = [infoBarButtonItem]
        }
        #endif
    }

    func refreshIfNecessary() {
        guard let lastRefreshDate else {
            return
        }

        // Refresh every hour
        let minimumRefreshInterval: TimeInterval = (60 * 60)
        if lastRefreshDate.timeIntervalSinceNow < -minimumRefreshInterval {
            refresh(sender: nil)
        }
    }

    // MARK: - Actions

    @objc func openAboutScreen(sender: Any) {
        performSegue(withIdentifier: K.SegueIdentifier.about, sender: nil)
    }

    @objc func openCardScreen(sender: Any) {
        performSegue(withIdentifier: K.SegueIdentifier.card, sender: nil)
    }

    @IBAction func refresh(sender: Any?) {
        guard loader == nil, let credentials = Credentials.sharedCredentials() else {
            return
        }

        presentInfo(NSLocalizedString("Updating Account…", comment: ""))
        refreshButton?.isHidden = true
        refreshLabel?.isHidden = true

        loader = GhostLoader(credentials: credentials, parentView: view, success: { (items) in
            self.refreshButton?.isHidden = false
            self.loader = nil
            self.reloadData(state: .loans(items))

            let itemCache = ItemCache(items: items)
            ItemCache.save(items: itemCache, to: .standard)

            self.refreshControl?.endRefreshing()
            self.presentInfo(nil)
            self.lastRefreshDate = Date()
        }) { (error) in
            self.refreshButton?.isHidden = false
            self.presentLoadingError(error)
            self.refreshControl?.endRefreshing()
            self.presentInfo(nil)
            self.loader = nil
        }
    }

    func openInGoodreads(item: Item) {
        guard let query = item.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://www.goodreads.com/search?q=\(query)") else {
                return
        }

#if targetEnvironment(macCatalyst)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
#else
        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { (result) in
            if result == false {
                self.presentSafariViewController(url)
            }
        }
#endif
    }

    @IBAction func presentLoginScreen(sender: Any?) {
        performSegue(withIdentifier: K.SegueIdentifier.login, sender: sender)
    }

    @objc func presentLibrariesScreen(sender: Any?) {
        performSegue(withIdentifier: K.SegueIdentifier.libraries, sender: sender)
    }

    @objc func presentSearchScreen(sender: Any?) {
        performSegue(withIdentifier: K.SegueIdentifier.search, sender: sender)
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .loans:
            return 1

        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loans(let items):
            switch Section(rawValue: section) {
            case .loans:
                return items.count
            default:
                return 0
            }

        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIdentifier.loan, for: indexPath) as! ItemTableViewCell
        if let item = self.item(at: indexPath) {
            cell.configure(item: item)
        }
        return cell
    }

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = self.item(at: indexPath) else {
            return nil
        }

        let action = UIAction(title: NSLocalizedString("Search on Goodreads", comment: ""), image: UIImage(systemName: "safari")) { action in
            self.openInGoodreads(item: item)
        }

        let actions = [action]
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ -> UIMenu? in
            return UIMenu(title: "", children: actions)
        })

        return configuration
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
            appearance.backgroundColor = .BMRed
            navigationBar.tintColor = .white
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
        }
    }
}

extension UITableViewCell {
    func configure(with item: AccountPageItem) {
        textLabel?.text = item.data.title
        if item.data.statusDescription == "globalErrorLeg_list.ReservationCard.RESV_AVAILABLE" {
            detailTextLabel?.text = NSLocalizedString("Available", comment: "") + " (" + item.data.branch.name + ")"
            if #available(iOS 13.0, *) {
                imageView?.image = UIImage(systemName: "checkmark.circle.fill")
                imageView?.tintColor = .systemGreen
            }
        }
        else {
            detailTextLabel?.text = NSLocalizedString("Not Available Yet", comment: "") + " (" + item.data.branch.name + ")"
            imageView?.image = nil
        }
    }
}
