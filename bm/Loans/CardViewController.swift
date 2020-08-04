//
//  CardViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 07/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet var cardParentView: UIView?
    @IBOutlet var dismissButton: UIButton?

    var originalScreenBrightness: CGFloat?

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton?.titleLabel?.adjustsFontForContentSizeCategory = true
        dismissButton?.configureRoundCorners()
        cardParentView?.superview?.configureRoundCorners()

        configureCard()
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

        let userIdentifier = credentials.userIdentifier
        let BarCodeLenght = 13

        if userIdentifier.count == BarCodeLenght {
            return userIdentifier
        }
        else if userIdentifier.count > BarCodeLenght {
            let indexStartOfText = userIdentifier.index(userIdentifier.endIndex, offsetBy: -BarCodeLenght)
            let trimmedIdentifier = userIdentifier[indexStartOfText...]
            return String(trimmedIdentifier)
        }
        else {
            return nil
        }
    }

    // MARK: - Actions

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
