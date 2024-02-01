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
        Service(title: "ToutApprendre", systemImageName: "graduationcap", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/toutapprendre")!),
        Service(title: "CinéVOD", systemImageName: "film", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/cinevod")!),
        Service(title: "Tënk", systemImageName: "film", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/tenk")!),
        Service(title: "Bibook", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/bibook")!),
        Service(title: "Storyplay’r", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/storyplayr")!),
        Service(title: "diMusic", systemImageName: "music.note.list", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/dimusic")!),
        Service(title: "PaGella", systemImageName: "building.columns", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/pagella")!),
        Service(title: "ToutApprendre Presse", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/toutapprendrePresse")!),
        Service(title: "EuroPresse", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/europresse")!),
        Service(title: "Place Gre’Net", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/place-grenet")!)
    ]

    struct K {
        static let cellIdentifier = "Cell"
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Digital Library", comment: "")

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.cellIdentifier)
        tableView.cellLayoutMarginsFollowReadableWidth = true
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
