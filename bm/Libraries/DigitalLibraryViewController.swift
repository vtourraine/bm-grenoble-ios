//
//  DigitalLibraryViewController.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 05/09/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import UIKit

class DigitalLibraryViewController: UITableViewController {

    struct Service {
        let title: String
        let systemImageName: String
        let url: URL
    }

    let services = [
        Service(title: "Bibliostream", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/bibliostream")!),
        Service(title: "Bibook", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/bibook")!),
        Service(title: "Storyplay’r", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/storyplayr")!),
        Service(title: "Tënk", systemImageName: "film", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/tenk")!),
        Service(title: "CinéVOD", systemImageName: "film", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/cinevod")!),
        Service(title: "diMusic", systemImageName: "music.note.list", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/dimusic")!),
        Service(title: "EuroPresse", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/europresse")!),
        Service(title: "Cafeyn", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/cafeyn")!),
        Service(title: "MyCow français", systemImageName: "graduationcap", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/mycow")!),
        Service(title: "PaGella", systemImageName: "building.columns", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/pagella")!),
        Service(title: "Place Gre’Net", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/place-grenet")!),
        Service(title: "Toutapprendre", systemImageName: "graduationcap", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/toutapprendre")!)
    ]

    struct K {
        static let cellIdentifier = "Cell"
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Digital Library", comment: "")

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.cellIdentifier)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        let service = services[indexPath.row]
        cell.textLabel?.text = service.title
        if #available(iOS 13.0, *) {
            cell.imageView?.image = UIImage(systemName: service.systemImageName)
            cell.imageView?.tintColor = .BMRed
        }
        return cell
    }

    // MARK: Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = services[indexPath.row]
        UIApplication.shared.open(service.url, options: [:], completionHandler: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
