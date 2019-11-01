//
//  LibraryViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 25/10/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation
import MapKit

class LibraryViewController: UIViewController {

    var library: Library?

    @IBOutlet var openingTimeLabel: UILabel?
    @IBOutlet var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()

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
}
