//
//  GhostWebView.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import UIKit
import WebKit

class GhostLoader: NSObject, WKNavigationDelegate {
    let credentials: Credentials
    let webView: GhostWebView
    let success: ([Item]) -> Void
    let failure: (Error?) -> Void
    var items: [Item] = []

    init(credentials: Credentials, parentView: UIView, success: @escaping ([Item]) -> Void, failure: @escaping (Error?) -> Void) {
        self.credentials = credentials
        self.success = success
        self.failure = failure

        let webView = GhostWebView()
        self.webView = webView

        super.init()

        parentView.addSubview(webView)
        webView.navigationDelegate = self
        webView.loadGhostPage()
    }

    func cleanup() {
        webView.removeFromSuperview()
    }

    // MARK: - Web view navigation delegate

    var hasLoggedIn = false

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else {
                return
        }

        let absoluteURLString = url.absoluteString

        if absoluteURLString == GhostWebView.AccountURL {
            if hasLoggedIn {
                let request = URLRequest(url: URL(string: GhostWebView.AccountLoansURL)!)
                webView.load(request)
            }
            else {
                self.webView.setUsername(self.credentials.userIdentifier) {
                    self.webView.setPassword(self.credentials.password) {
                        self.hasLoggedIn = true
                        self.webView.submitForm {}
                    }
                }
            }
        }
        else if absoluteURLString.hasPrefix(GhostWebView.AccountLoansURL) {
            self.webView.getHTML { (html) in
                if let loans = PageParser.parseLoans(html: html) {
                    self.items.append(contentsOf: loans.items)

                    if let nextPage = loans.pagination.nextPage,
                        let nextPageFullURL = URL(string: GhostWebView.RootURL.appending(nextPage.absoluteString)) {
                            let request = URLRequest(url: nextPageFullURL)
                            webView.load(request)
                    }
                    else {
                        self.success(self.items)
                        self.cleanup()
                    }
                }
                else {
                    self.failure(nil)
                    self.cleanup()
                }
            }
        }
        else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Invalid subscriber number or password", comment: "")])
            failure(error)
            cleanup()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled {
            // Cancelled
        }
        else {
            failure(error)
            cleanup()
        }
    }
}

class GhostWebView: WKWebView {
    static let RootURL = "http://catalogue.bm-grenoble.fr"
    static let AccountURL = "http://catalogue.bm-grenoble.fr/in/faces/account.xhtml"
    static let AccountLoansURL = "http://catalogue.bm-grenoble.fr/in/faces/accountLoans.xhtml"

    struct TagIdentifier: RawRepresentable, Hashable, Codable {
      let rawValue: String
    }

    private let UsernameTextField = TagIdentifier(rawValue: "stdPage:pagecontentReplaced:msgLogin:j_idt464:j_idt469:userName")
    private let PasswordTextField = TagIdentifier(rawValue: "stdPage:pagecontentReplaced:msgLogin:j_idt464:j_idt469:password")

    convenience init() {
        let webConfiguration = WKWebViewConfiguration()
        self.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: webConfiguration)
    }

    func loadGhostPage() {
        let request = URLRequest(url: URL(string: GhostWebView.AccountURL)!)
        load(request)
    }

    func setUsername(_ username: String, completionHandler: @escaping (() -> Void)) {
        setInput(identifier: UsernameTextField, value: username, completionHandler: completionHandler)
    }

    func setPassword(_ password: String, completionHandler: @escaping (() -> Void)) {
        setInput(identifier: PasswordTextField, value: password, completionHandler: completionHandler)
    }

    func setInput(identifier: TagIdentifier, value: String, completionHandler: @escaping (() -> Void)) {
        let js = "document.getElementById('\(identifier.rawValue)').value=\"\(value)\""
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
