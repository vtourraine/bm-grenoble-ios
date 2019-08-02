//
//  GhostWebView.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit
import WebKit

class GhostWebView: WKWebView {
    static let LoginURL = "http://catalogue.bm-grenoble.fr/in/faces/account.xhtml"
    static let AccountURL = "http://catalogue.bm-grenoble.fr/in/faces/account.xhtml"
    static let AccountLoansURL = "http://catalogue.bm-grenoble.fr/in/faces/accountLoans.xhtml"

    convenience init() {
        let webConfiguration = WKWebViewConfiguration()
        self.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: webConfiguration)
    }

    func loadGhostPage() {
        let request = URLRequest(url: URL(string: GhostWebView.LoginURL)!)
        load(request)
    }

    func setUsername(_ username: String, completionHandler: @escaping (() -> Void)) {
        setInput(identifier: "stdPage:pagecontentReplaced:msgLogin:j_idt464:j_idt469:userName", value: username, completionHandler: completionHandler)
    }

    func setPassword(_ password: String, completionHandler: @escaping (() -> Void)) {
        setInput(identifier: "stdPage:pagecontentReplaced:msgLogin:j_idt464:j_idt469:password", value: password, completionHandler: completionHandler)
    }

    func setInput(identifier: String, value: String, completionHandler: @escaping (() -> Void)) {
        let js = "document.getElementById('\(identifier)').value=\"\(value)\""
        evaluateJavaScript(js) { (object, error) in
            completionHandler()
        }
    }

    func submitForm(completionHandler: @escaping (() -> Void)) {
        let js = "document.getElementById('loginFormButton').click()"
        evaluateJavaScript(js) { (object, error) in
            completionHandler()
        }
    }

    func getHTML(completionHandler: @escaping ((String) -> Void)) {
        evaluateJavaScript("document.documentElement.innerHTML") { (object, error) in
            completionHandler(String(describing: object))
        }
    }
}
