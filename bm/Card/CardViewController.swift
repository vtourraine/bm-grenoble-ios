//
//  CardViewController.swift
//  bm
//
//  Created by Vincent Tourraine on 07/08/2019.
//  Copyright © 2019-2024 Studio AMANgA. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet var cardParentView: UIView?
    @IBOutlet var formView: UIView?
    @IBOutlet var saveSubscriberNumberButton: UIButton?
    @IBOutlet var subscriberNumberTextField: UITextField?
    @IBOutlet var clearButton: UIButton?

    var originalScreenBrightness: CGFloat?
    var currentTextFieldTopConstraint: NSLayoutConstraint?
    let BaseBarCodeLenght = 13

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        cardParentView?.superview?.configureRoundCorners()
        subscriberNumberTextField?.configureRoundCorners()
        subscriberNumberTextField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        saveSubscriberNumberButton?.configureRoundCorners()
        clearButton?.configureClearButton()

        configureCard()
        validateSaveButton(number: "")

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

    private func validateSaveButton(number: String) {
        let isEnabled = isValidSubscriberNumber(number)
        saveSubscriberNumberButton?.isEnabled = isEnabled
        saveSubscriberNumberButton?.alpha = isEnabled ? 1 : 0.3
    }

    private func isValidSubscriberNumber(_ number: String) -> Bool {
        return (number.count == BaseBarCodeLenght &&
                number.allSatisfy({ $0.isNumber }) &&
                number.hasPrefix("01"))
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
              isValidSubscriberNumber(number) else {
            return
        }

        let credentials = Credentials(username: number, password: "")
        try? credentials.save(to: Credentials.defaultKeychain())
        configureCard()
        configureMainView()
    }

    @IBAction func didTapClearCardButton(_ sender: UIButton?) {
        let alertController = UIAlertController(title: NSLocalizedString("Remove Subscriber Card?", comment: ""), message: NSLocalizedString("You can always add it again later.", comment: ""), preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Remove Card", comment: ""), style: .destructive) { _ in
            try? Credentials.remove(from: Credentials.defaultKeychain())
            self.configureMainView()
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = cardParentView?.superview?.frame ?? .zero
        present(alertController, animated: true)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }

        validateSaveButton(number: text)
    }
}

extension CardViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
#if targetEnvironment(macCatalyst)
        // No need to adjust view to prevent keyboard to hide screen content
#else
        UIView.animate(withDuration: 0.3) {
            self.currentTextFieldTopConstraint = self.formView?.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
            self.currentTextFieldTopConstraint?.isActive = true
        }
#endif
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.currentTextFieldTopConstraint?.isActive = false
            self.currentTextFieldTopConstraint = nil
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
