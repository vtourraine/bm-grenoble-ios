//
//  LibrariesViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 30/09/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
#if !targetEnvironment(macCatalyst)
import CoreLocationUI
#endif

class LibrariesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    let libraries = Libraries.loadCityLibraries()
    let locationManager = CLLocationManager()

    @IBOutlet var tableView: UITableView?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var showUserLocationButton: UIButton?
    @IBOutlet var locationButton: UIView? // CLLocationButton
    @IBOutlet var separatorWidth: NSLayoutConstraint?
    @IBOutlet var separatorHeight: NSLayoutConstraint?

    struct K {
        static let showSegueIdentifier = "Show"
        static let defaultCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.1793553, longitude: 5.724542), latitudinalMeters: 9000, longitudinalMeters: 9000)
    }

    enum Section: Int, CaseIterable {
        case libraries = 0
        case digital
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.configureCustomAppearance()

        tableView?.tableFooterView = UIView(frame: CGRect.zero)

        separatorWidth?.constant = 1.0 / UIScreen.main.scale
        separatorHeight?.constant = 1.0 / UIScreen.main.scale

        mapView?.setRegion(K.defaultCoordinateRegion, animated: false)

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mapView?.showsUserLocation = true
        }

        if let libraries = libraries?.libraries {
            let annotations = libraries.map { library -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = library.location()
                annotation.title = library.name
                if library.closedForMaintenance {
                    annotation.subtitle = NSLocalizedString("Closed for maintenance", comment: "")
                }
                return annotation
            }

            mapView?.addAnnotations(annotations)
        }

#if !targetEnvironment(macCatalyst)

        // CLLocationButton is crashing with iOS 16

        /* if #available(iOS 16.0, *) {
            showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
            showUserLocationButton?.configureRoundCorners()
        }
        else if #available(iOS 15.0, *) {
            // Experimental fix for iOS 16
            // let locationButton = CLLocationButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            let locationButton = CLLocationButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            locationButton.icon = .arrowFilled
            locationButton.label = .currentLocation
            locationButton.cornerRadius = 22
            locationButton.tintColor = .BMRed
            locationButton.backgroundColor = .systemBackground
            locationButton.translatesAutoresizingMaskIntoConstraints = false
            locationButton.addTarget(self, action: #selector(reframeMap(_:)), for: .touchUpInside)

            if let mapView = mapView {
                view.insertSubview(locationButton, aboveSubview: mapView)

                // Experimental fix for iOS 16
                // locationButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
                // locationButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
                locationButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8).isActive = true
                mapView.trailingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 8).isActive = true
            }

            self.locationButton = locationButton

            showUserLocationButton?.removeFromSuperview()
            showUserLocationButton = nil
        }
        else {*/
            if #available(iOS 13.0, *) {
                showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
            }
            showUserLocationButton?.configureRoundCorners()
        // }
#else
        showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
        showUserLocationButton?.configureRoundCorners()
        mapView?.showsZoomControls = true
#endif
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
        mapView?.setRegion(K.defaultCoordinateRegion, animated: true)

#if !targetEnvironment(macCatalyst)
        if #available(iOS 15.0, *) {
            if sender is CLLocationButton {
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                return
            }
        }
#endif

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

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .libraries:
            return libraries?.libraries.count ?? 0
        case .digital:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        switch Section(rawValue: indexPath.section)! {
        case .libraries:
            if let library = libraries?.libraries[indexPath.row] {
                cell.textLabel?.text = library.name
                cell.detailTextLabel?.text = library.previousName
                cell.imageView?.image = nil

                if library.closedForMaintenance {
                    if #available(iOS 15.0, *) {
                        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
                        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.black, .bmYellow])
                        cell.accessoryView = imageView
                    }
                }
                else {
                    cell.accessoryView = nil
                }
            }

        case .digital:
            cell.textLabel?.text = NSLocalizedString("Digital Library", comment: "")
            cell.detailTextLabel?.text = nil
            cell.accessoryView = nil

            if #available(iOS 13.0, *) {
                cell.imageView?.image = .numoteque.roundedCornerImage(with: 8, destinationSize: CGSize(width: 34, height: 34))
                cell.imageView?.tintColor = .bmPurple
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Section(rawValue: indexPath.section)! == .digital {
            let viewController = DigitalLibraryViewController(style: .plain)
            navigationController?.pushViewController(viewController, animated: true)
        }
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

        performSegue(withIdentifier: K.showSegueIdentifier, sender: library)
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

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = tableView?.indexPathForSelectedRow,
            let section = Section(rawValue: indexPath.section),
            section == .digital {
            return false
        }

        return true
    }
}

extension LibrariesViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Should display user location on map view
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mapView?.showsUserLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView?.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print("\(error)")
    }
}

extension UIViewController {
    func libraryAnnotationView(for annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        view.displayPriority = .required
        view.subtitleVisibility = .visible

        if annotation.isKind(of: MKUserLocation.self) {
            view.markerTintColor = .systemBlue
            if #available(iOS 13.0, *) {
                view.glyphImage = UIImage(systemName: "person.fill")
            }
        }
        else if let subtitle = annotation.subtitle, subtitle?.isEmpty == false {
            view.markerTintColor = .bmYellow
            if #available(iOS 13.0, *) {
                view.glyphImage = UIImage(systemName: "exclamationmark.triangle.fill")
            }
        }
        else {
            view.markerTintColor = .bmRed
            if #available(iOS 13.0, *) {
                view.glyphImage = UIImage(systemName: "book.fill")
            }
        }
        return view
    }
}
