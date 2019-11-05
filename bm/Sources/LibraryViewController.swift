//
//  LibraryViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 25/10/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation
import MapKit

class LibraryViewController: UIViewController, MKMapViewDelegate {

    var library: Library?

    @IBOutlet var openingTimeLabel: UILabel?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var metadataView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        metadataView?.subviews.filter({$0.isKind(of: UIButton.self)}).forEach({$0.configureRoundCorners()})

        if let library = library {
            configure(with: library)
        }
    }

    func configure(with library: Library) {
        title = library.name
        openingTimeLabel?.text = library.openingTime

        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(center: library.location(), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = library.location()
        annotation.title = library.name
        mapView?.addAnnotation(annotation)
    }

    // MARK: - Actions

    @IBAction func openInMaps(_ sender: Any?) {
        guard let library = library else {
            return
        }

        let placemark = MKPlacemark(coordinate: library.location())
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = library.name
        mapItem.openInMaps(launchOptions: nil)
    }

    // MARK: - Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return libraryAnnotationView(for: annotation)
    }
}
