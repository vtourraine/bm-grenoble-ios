//
//  AgendaCollectionViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 09/02/2025.
//  Copyright © 2025 Studio AMANgA. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

class AgendaCollectionViewController: UICollectionViewController {

    var agendaItems = [AgendaItem]()
    var isFirstLaunch = true
    let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // refreshControl?.tintColor = .white
        // tableView.dragDelegate = self

        if let cachedItems = AgendaItemCache.load(from: .standard) {
            agendaItems = cachedItems.items
        }

        navigationController?.configureCustomAppearance()

        // updateFilterButton()

        let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        //alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .top
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

    // MARK: - Actions

    @IBAction func refresh(sender: Any?) {
        AgendaParser.fetchAgendaItems { result in
            //self.refreshControl?.endRefreshing()

            switch (result) {
            case .success(let items):
                AgendaItemCache.save(items: items, to: .standard)
                // self.filter(with: self.filterTitle)

            case .failure(let error):
                self.presentLoadingError(error)
            }
        }
    }

    // MARK: - Collection view

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.agendaItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AgendaViewCell
        cell.configure(item: self.agendaItems[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

class AgendaViewCell: UICollectionViewCell {
    @IBOutlet var title: UILabel?
    @IBOutlet var date: UILabel?
    @IBOutlet var library: UILabel?
    @IBOutlet var summary: UILabel?
    @IBOutlet var thumbnail: UIImageView?

    func configure(item: AgendaItem) {
        title?.text = item.title
        summary?.text = item.category
        library?.text = item.library

        thumbnail?.layer.cornerRadius = 8
        if let image = item.image {
            thumbnail?.af.setImage(withURL: image)
        }
        else {
            thumbnail?.image = nil
        }

        switch item.date {
        case .day(let dateComponents):
            let formattedDate = AgendaTableViewCell.formatterDateWithoutYear(dateComponents)
            date?.text = formattedDate?.capitalizingFirstLetter()
        case .range(let startDateComponents, let endDateComponents):
            let formattedDate = AgendaTableViewCell.formatterRangeDateWithoutYear(from: startDateComponents, to: endDateComponents)
            date?.text = formattedDate?.capitalizingFirstLetter()
        case .none:
            date?.text = nil
        }
    }
}
