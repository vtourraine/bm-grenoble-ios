//
//  LibrariesViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/09/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

class LibrariesViewController: UITableViewController {

    let libraries = Libraries.loadCityLibraries()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.configureCustomAppearance()
    }

    // MARK: - Actions

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries?.libraries.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let library = libraries?.libraries[indexPath.row] {
            cell.textLabel?.text = library.name
            cell.detailTextLabel?.text = library.openingTime
        }

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow,
            let libraryViewController = segue.destination as? LibraryViewController,
            let library = libraries?.libraries[indexPath.row] else {
                return
        }

        libraryViewController.library = library
    }
}
