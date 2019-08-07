//
//  CardViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 07/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet var cardParentView: UIView?
    @IBOutlet var dismissButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton?.layer.cornerRadius = 8
        cardParentView?.superview?.layer.cornerRadius = 8

        configureCard()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configureCard() {
        guard let credentials = Credentials.load(from: .standard),
            let parentView = cardParentView else {
                return
        }

        let userIdentifier = credentials.userIdentifier
        let indexStartOfText = userIdentifier.index(userIdentifier.endIndex, offsetBy: -13)
        let trimmedIdentifier = userIdentifier[indexStartOfText...]

        let barCodeView = BarCodeView(frame: parentView.bounds)
        parentView.addSubview(barCodeView)
        barCodeView.barCode = String(trimmedIdentifier)
    }

    // MARK: - Actions

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
