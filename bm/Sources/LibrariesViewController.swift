//
//  LibrariesViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/09/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit
import MapKit

class LibrariesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    let libraries = Libraries.loadCityLibraries()

    @IBOutlet var tableView: UITableView?
    @IBOutlet var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.configureCustomAppearance()

        let regionRadius: CLLocationDistance = 7000
        let center = CLLocationCoordinate2D(latitude: 45.1793553, longitude: 5.724542)
        let coordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)

        if let libraries = libraries?.libraries {
            let annotations = libraries.map { (library) -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = library.location()
                annotation.title = library.name
                return annotation
            }

            mapView?.addAnnotations(annotations)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Id")
        view.displayPriority = .required
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation,
            let libraries = libraries,
            let index = libraries.libraries.firstIndex(where: { $0.name == annotation.title }) else {
                return
        }

        tableView?.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
    }

    // MARK: - Actions

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries?.libraries.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let library = libraries?.libraries[indexPath.row] {
            cell.textLabel?.text = library.name
            cell.detailTextLabel?.text = library.openingTime
        }

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tableView = tableView, let indexPath = tableView.indexPathForSelectedRow,
            let libraryViewController = segue.destination as? LibraryViewController,
            let library = libraries?.libraries[indexPath.row] else {
                return
        }

        libraryViewController.library = library
    }
}
