//
//  DigitalLibraryViewController.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 05/09/2022.
//  Copyright © 2022-2025 Studio AMANgA. All rights reserved.
//

import UIKit

class DigitalLibraryViewController: UITableViewController {

    struct Service {
        let title: String
        let systemImageName: String
        let url: URL
    }

    let services = [
        Service(title: "ToutApprendre", systemImageName: "graduationcap", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/ASSARedirect.ashx?url=https%3a%2f%2fbiblio.toutapprendre.com%2fcours%2fArchimed.aspx%3fpke%3d91")!),
        Service(title: "CinéVOD", systemImageName: "film", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/logon.aspx?service=https%3a%2f%2fcinevod.grenoblealpesmetropole.fr%3freferrer%3doai")!),
        Service(title: "Les yeux doc", systemImageName: "film", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/ASSARedirect.ashx?url=https%3a%2f%2fportal.mediatheque-numerique.com%2fsso_login%3freturn_url%3dhttps%3a%2f%2fwww.lesyeuxdoc.fr")!),
        Service(title: "Bibook", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/SearchMinify/1f73772319e01ec96760547ab9cb091b")!),
        Service(title: "Storyplay’r", systemImageName: "book.closed", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/ASSARedirect.ashx?url=https://www.storyplayr.com/api/assa/login?target=/bibliotheque")!),
        Service(title: "musicMe", systemImageName: "music.note.list", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/ASSARedirect.ashx?url=https://numothequegrenoblealpes.mt.musicme.com")!),
        Service(title: "PaGella", systemImageName: "building.columns", url: URL(string: "https://pagella.bm-grenoble.fr/pagella/fr/content/accueil-fr")!),
        Service(title: "ToutApprendre Presse", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/ASSARedirect.ashx?url=https%3a%2f%2fbiblio.toutapprendre.com%2fcours%2fArchimed.aspx%3fpke%3d91%26pkGroup%3dpresse")!),
        Service(title: "EuroPresse", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/redirection-contenu-europresse.aspx")!),
        Service(title: "Place Gre’Net", systemImageName: "newspaper", url: URL(string: "https://numotheque.grenoblealpesmetropole.fr/redirection-contenu-placegrenet.aspx")!)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.configureCustomAppearance(tintColor: .bmYellow, backgroundColor: .bmPurple)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restore defaults
        navigationController?.configureCustomAppearance()
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
            cell.imageView?.tintColor = .bmPurple
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
