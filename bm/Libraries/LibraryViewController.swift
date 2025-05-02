//
//  LibraryViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 25/10/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import Foundation
import MapKit
#if !targetEnvironment(macCatalyst)
import CoreLocationUI
#endif
import FeedKit
import AlamofireImage

class LibraryViewController: UIViewController, MKMapViewDelegate {

    var library: Library?
    var newBooks: [RSSFeedItem] = []
    let locationManager = CLLocationManager()

    @IBOutlet var openingTimeLabel: UILabel?
    @IBOutlet var openingTimeImageView: UIImageView?
    @IBOutlet var addressLabel: UILabel?
    @IBOutlet var addressAccessibilityLabel: UILabel?
    @IBOutlet var addressImageView: UIImageView?
    @IBOutlet var phoneLabel: UILabel?
    @IBOutlet var phoneImageView: UIImageView?
    @IBOutlet var mailLabel: UILabel?
    @IBOutlet var mailImageView: UIImageView?
    @IBOutlet var websiteLabel: UILabel?
    @IBOutlet var websiteImageView: UIImageView?
    @IBOutlet var newBooksLabel: UILabel?
    @IBOutlet var newBooksImageView: UIImageView?
    @IBOutlet var newBooksScrollView: UIScrollView?

    @IBOutlet var mapView: MKMapView?
    @IBOutlet var metadataView: UIView?
    @IBOutlet var showUserLocationButton: UIButton?
    @IBOutlet var locationButton: UIView? // CLLocationButton
    @IBOutlet var separatorWidth: NSLayoutConstraint?
    @IBOutlet var separatorHeight: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        metadataView?.subviews.filter({$0.isKind(of: UIButton.self)}).forEach({
            $0.configureRoundCorners()
            ($0 as? UIButton)?.titleLabel?.adjustsFontForContentSizeCategory = true
        })

        separatorWidth?.constant = 1.0 / UIScreen.main.scale
        separatorHeight?.constant = 1.0 / UIScreen.main.scale

        if #available(iOS 13.0, *) {
            openingTimeImageView?.image = UIImage(systemName: "clock")
            addressImageView?.image = UIImage(systemName: "mappin.circle")
            phoneImageView?.image = UIImage(systemName: "phone.circle")
            mailImageView?.image = UIImage(systemName: "envelope.circle")
            websiteImageView?.image = UIImage(systemName: "safari")
            newBooksImageView?.image = UIImage(systemName: "book.circle")
        }

        if let library {
            configure(with: library)
        }
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mapView?.showsUserLocation = true
        }

        let largeScreen = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        navigationItem.largeTitleDisplayMode = largeScreen ? .automatic : .never
        
#if !targetEnvironment(macCatalyst)
        /*
        if #available(iOS 16.0, *) {
            showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
            showUserLocationButton?.configureRoundCorners()
        }
        else if #available(iOS 15.0, *) {
            let locationButton = CLLocationButton()
            locationButton.icon = .arrowFilled
            locationButton.cornerRadius = 22
            locationButton.tintColor = .BMRed
            locationButton.backgroundColor = .systemBackground
            locationButton.translatesAutoresizingMaskIntoConstraints = false
            locationButton.addTarget(self, action: #selector(reframeMap(_:)), for: .touchUpInside)

            if let mapView = mapView {
                view.insertSubview(locationButton, aboveSubview: mapView)

                locationButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8).isActive = true
                mapView.trailingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 8).isActive = true
            }

            self.locationButton = locationButton

            showUserLocationButton?.removeFromSuperview()
            showUserLocationButton = nil
        }
        else { */
            if #available(iOS 13.0, *) {
                showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
            }
            showUserLocationButton?.configureRoundCorners()
        // }
#else
    showUserLocationButton?.setImage(UIImage(systemName: "location.fill"), for: .normal)
    showUserLocationButton?.configureRoundCorners()
#endif
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let newItemsFeed = library?.newItemsFeed,
           let url = URL(string: newItemsFeed),
           newBooks.isEmpty {
            fetchRSS(url)
        }
        else {
            reloadNewBooks()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let largeScreen = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        navigationItem.largeTitleDisplayMode = largeScreen ? .automatic : .never
    }

    func configure(with library: Library) {
#if targetEnvironment(macCatalyst)
        if let previousName = library.previousName {
            title = library.name + " • " + previousName
        }
        else {
            title = library.name
        }
#else
        title = library.name
        navigationItem.setTitle(library.name, subtitle: library.previousName)
#endif

        if library.closedForMaintenance {
            openingTimeLabel?.text = "⚠️ " + NSLocalizedString("Closed for maintenance", comment: "")
        }
        else {
            openingTimeLabel?.text = library.openingTime
        }
        addressLabel?.text = library.address
        addressAccessibilityLabel?.text = library.accessibility ? NSLocalizedString("♿︎ Accessible PMR", comment: "") : nil
        phoneLabel?.text = library.phoneNumber
        mailLabel?.text = library.mailAddress
        websiteLabel?.text = library.webpage

        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(center: library.location(), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = library.location()
        annotation.title = library.name
        annotation.subtitle = library.closedForMaintenance ? NSLocalizedString("Closed for maintenance", comment: "") : nil
        mapView?.addAnnotation(annotation)
    }

    class TapItemGesture: UITapGestureRecognizer {
        var url: URL?
    }

    func reloadNewBooks() {
        guard let newBooksScrollView else {
            return
        }

        for subview in newBooksScrollView.subviews {
            subview.removeFromSuperview()
        }

        var bookViews: [UIView] = newBooks.map { book in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 200))

            let label = UILabel(frame: CGRect(x: 5, y: 150, width: 110, height: 50))
            label.text = book.title
            label.font = .preferredFont(forTextStyle: .caption1)
            label.textAlignment = .center
            label.numberOfLines = 2
            view.addSubview(label)

            let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 150))
            imageView.contentMode = .scaleAspectFit
            if let imageURLString = book.enclosure?.attributes?.url,
               let imageURL = URL(string: imageURLString) {
                imageView.af.setImage(withURL: imageURL, placeholderImage: UIImage(systemName: "book"))
            }
            view.addSubview(imageView)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 120).isActive = true
            view.heightAnchor.constraint(equalToConstant: 200).isActive = true

            let tgr = TapItemGesture(target: self, action: #selector(self.didTapItem))
            if let link = book.link {
                tgr.url = URL(string: link)
            }
            view.addGestureRecognizer(tgr)

            return view
        }

        if bookViews.isEmpty {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
            label.text = NSLocalizedString("New Documents Unavailable", comment: "")
            label.font = .preferredFont(forTextStyle: .body)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            label.heightAnchor.constraint(equalToConstant: 200).isActive = true
            bookViews.append(label)
        }

        let stackView = UIStackView(arrangedSubviews: bookViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.frame = newBooksScrollView.bounds
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        newBooksScrollView.addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: newBooksScrollView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: newBooksScrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: newBooksScrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: newBooksScrollView.bottomAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: newBooksScrollView.heightAnchor).isActive = true
    }

    // MARK: - Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return libraryAnnotationView(for: annotation)
    }
}

// MARK: - Actions
extension LibraryViewController {

    func fetchRSS(_ url: URL) {
        let parser = FeedParser(URL: url)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            // Do your thing, then back to the Main thread
            DispatchQueue.main.async {
                switch result {
                case .success(let feed):
                    if let newItems = feed.rssFeed?.items {
                        self.newBooks = newItems
                    }

                    self.reloadNewBooks()
                case.failure(let error):
                    print("\(error)")
                    self.reloadNewBooks()
                }
            }
        }
    }

    @objc func didTapItem(sender: TapItemGesture) {
        if let url = sender.url {
            presentSafariViewController(url)
        }
    }

    @IBAction func reframeMap(_ sender: Any?) {
        guard let library else {
            return
        }

        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(center: library.location(), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView?.setRegion(coordinateRegion, animated: true)

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

    @IBAction func openInMaps(_ sender: Any?) {
        guard let library else {
            return
        }

        let placemark = MKPlacemark(coordinate: library.location())
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = library.name
        mapItem.openInMaps(launchOptions: [:])
    }

    @IBAction func call(_ sender: Any?) {
        guard let library,
            let phoneURL = URL(string: "tel://\(library.phoneNumber.replacingOccurrences(of: " ", with: ""))") else {
            return
        }

        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
    }

    @IBAction func composeMail(_ sender: Any?) {
        guard let library, let url = URL(string: "mailto:\(library.mailAddress)") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func openWebsite(_ sender: Any?) {
        guard let library, let webpageURL = URL(string: library.webpage) else {
            return
        }

#if targetEnvironment(macCatalyst)
        UIApplication.shared.open(webpageURL, options: [:], completionHandler: nil)
#else
        presentSafariViewController(webpageURL)
#endif
    }
}

extension LibraryViewController: CLLocationManagerDelegate {

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
