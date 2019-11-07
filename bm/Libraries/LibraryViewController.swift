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
    @IBOutlet var openingTimeImageView: UIImageView?
    @IBOutlet var addressLabel: UILabel?
    @IBOutlet var addressImageView: UIImageView?
    @IBOutlet var phoneLabel: UILabel?
    @IBOutlet var phoneImageView: UIImageView?
    @IBOutlet var mailLabel: UILabel?
    @IBOutlet var mailImageView: UIImageView?
    @IBOutlet var websiteLabel: UILabel?
    @IBOutlet var websiteImageView: UIImageView?

    @IBOutlet var mapView: MKMapView?
    @IBOutlet var metadataView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        metadataView?.subviews.filter({$0.isKind(of: UIButton.self)}).forEach({$0.configureRoundCorners()})

        if #available(iOS 13.0, *) {
            openingTimeImageView?.image = UIImage(systemName: "clock")
            addressImageView?.image = UIImage(systemName: "mappin.circle")
            phoneImageView?.image = UIImage(systemName: "phone.circle")
            mailImageView?.image = UIImage(systemName: "envelope.circle")
            websiteImageView?.image = UIImage(systemName: "safari")
        }

        if let library = library {
            configure(with: library)
        }
    }

    func configure(with library: Library) {
        title = library.name
        openingTimeLabel?.text = library.openingTime
        addressLabel?.text = library.address
        phoneLabel?.text = library.phoneNumber
        mailLabel?.text = library.mailAddress
        websiteLabel?.text = library.webpage

        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(center: library.location(), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = library.location()
        annotation.title = library.name
        mapView?.addAnnotation(annotation)
    }

    // MARK: - Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return libraryAnnotationView(for: annotation)
    }
}

import SafariServices
import MessageUI

// MARK: - Actions
extension LibraryViewController: MFMailComposeViewControllerDelegate {

    @IBAction func openInMaps(_ sender: Any?) {
        guard let library = library else {
            return
        }

        let placemark = MKPlacemark(coordinate: library.location())
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = library.name
        mapItem.openInMaps(launchOptions: nil)
    }

    @IBAction func call(_ sender: Any?) {
        guard let library = library,
            let phoneURL = URL(string: "tel://\(library.phoneNumber.replacingOccurrences(of: " ", with: ""))") else {
            return
        }

        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
    }

    @IBAction func composeMail(_ sender: Any?) {
        guard let library = library else {
            return
        }

        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: library.mailAddress, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }

        let viewController = MFMailComposeViewController()
        viewController.setToRecipients([library.mailAddress])
        viewController.mailComposeDelegate = self

        present(viewController, animated: true, completion: nil)
    }

    @IBAction func openWebsite(_ sender: Any?) {
        guard let library = library,
            let webpageURL = URL(string: library.webpage) else {
            return
        }

        let viewController = SFSafariViewController(url: webpageURL)
        viewController.preferredControlTintColor = UIColor(named: "BMRed")
        present(viewController, animated: true, completion: nil)
    }

    // Mail compose view controller delegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
