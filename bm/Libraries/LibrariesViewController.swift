//
//  LibrariesViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/09/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LibrariesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {

    let libraries = Libraries.loadCityLibraries()
    let locationManager = CLLocationManager()
    let defaultcoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.1793553, longitude: 5.724542), latitudinalMeters: 9000, longitudinalMeters: 9000)

    let ShowSegueIdentifier = "Show"

    @IBOutlet var tableView: UITableView?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var showUserLocationButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.configureCustomAppearance()

        tableView?.tableFooterView = UIView(frame: CGRect.zero)

        mapView?.setRegion(defaultcoordinateRegion, animated: false)

        if let libraries = libraries?.libraries {
            let annotations = libraries.map { (library) -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = library.location()
                annotation.title = library.name
                return annotation
            }

            mapView?.addAnnotations(annotations)
        }

        if #available(iOS 13.0, *) {
            showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
        showUserLocationButton?.configureRoundCorners()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRow(at: selectedIndexPath, animated: animated)
        }

        if let selectedAnnotation = mapView?.selectedAnnotations.first {
            mapView?.deselectAnnotation(selectedAnnotation, animated: animated)
        }
    }

    // MARK: - Actions

    @IBAction func reframeMap(_ sender: Any?) {
        mapView?.setRegion(defaultcoordinateRegion, animated: true)

        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }

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

    // MARK: - Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return libraryAnnotationView(for: annotation)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation,
            let libraries = libraries,
            let library = libraries.libraries.first(where: { $0.name == annotation.title }) else {
                return
        }

        performSegue(withIdentifier: ShowSegueIdentifier, sender: library)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let libraryViewController = segue.destination as? LibraryViewController else {
                return
        }

        if let library = sender as? Library {
            libraryViewController.library = library
        }
        else if let tableView = tableView,
            let indexPath = tableView.indexPathForSelectedRow,
            let library = libraries?.libraries[indexPath.row] {
            libraryViewController.library = library
        }
    }

    // MARK: - Location manager delegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Should display user location on map view
    }
}

extension UIViewController {
    func libraryAnnotationView(for annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        view.displayPriority = .required

        if annotation.isKind(of: MKUserLocation.self) {
            view.markerTintColor = .systemBlue
            if #available(iOS 13.0, *) {
                view.glyphImage = UIImage(systemName: "person.fill")
            }
        }
        else {
            view.markerTintColor = .BMRed
            if #available(iOS 13.0, *) {
                view.glyphImage = UIImage(systemName: "book.fill")
            }
        }
        return view
    }
}
