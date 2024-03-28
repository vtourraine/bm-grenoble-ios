//
//  CardViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 07/08/2019.
//  Copyright © 2019-2024 Studio AMANgA. All rights reserved.
//

import UIKit
import BMKit

class CardViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet var cardParentView: UIView?
    @IBOutlet var formView: UIView?
    @IBOutlet var saveSubscriberNumberButton: UIButton?
    @IBOutlet var subscriberNumberTextField: UITextField?

    var originalScreenBrightness: CGFloat?
    let BaseBarCodeLenght = 13

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        cardParentView?.superview?.configureRoundCorners()
        subscriberNumberTextField?.configureRoundCorners()
        saveSubscriberNumberButton?.configureRoundCorners()

        configureCard()

        navigationController?.configureCustomAppearance()

#if targetEnvironment(macCatalyst)
        navigationItem.rightBarButtonItem = nil
#else
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "info.circle")
        }
#endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMainView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        originalScreenBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let brightness = originalScreenBrightness {
            UIScreen.main.brightness = brightness
        }
    }

    private func configureMainView() {
        let isLoggedIn = Credentials.sharedCredentials() != nil
        cardParentView?.superview?.isHidden = !isLoggedIn
        formView?.isHidden = isLoggedIn
    }

    // MARK: - View configuration

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configureCard() {
        guard let barCode = barCode(), let parentView = cardParentView else {
            return
        }

        let barCodeView = BarCodeView(frame: parentView.bounds)
        parentView.addSubview(barCodeView)
        barCodeView.barCode = barCode
    }

    func barCode() -> String? {
        guard let credentials = Credentials.sharedCredentials() else {
            return nil
        }

        let userIdentifier = credentials.username

        if userIdentifier.count == BaseBarCodeLenght {
            return userIdentifier
        }
        else if userIdentifier.count > BaseBarCodeLenght {
            let indexStartOfText = userIdentifier.index(userIdentifier.endIndex, offsetBy: -BaseBarCodeLenght)
            let trimmedIdentifier = userIdentifier[indexStartOfText...]
            return String(trimmedIdentifier)
        }
        else {
            return nil
        }
    }

    // MARK: - Actions

    @IBAction func didTapSaveSubscriberNumberButton(_ sender: UIButton?) {
        subscriberNumberTextField?.resignFirstResponder()
        guard let number = subscriberNumberTextField?.text,
              number.count >= BaseBarCodeLenght,
              number.allSatisfy({ $0.isNumber }) else {
            return
        }

        let credentials = Credentials(username: number, password: "")
        try? credentials.save(to: Credentials.defaultKeychain())
        configureCard()
        configureMainView()
    }
}

extension CardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
